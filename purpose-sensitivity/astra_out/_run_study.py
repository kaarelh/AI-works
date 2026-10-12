"""Sequential, resumable study controller. Prints transport/count metadata only.

Run this controller only after authentication and the single-job probe succeed.
The supplied runner and handoff files are unchanged. Each guarded invocation is
published before the next one; shared operational stops take precedence over
coverage, including the final rung file.
"""
import argparse
import datetime
import fcntl
import json
import math
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

sys.dont_write_bytecode = True

MODELS = [('gpt-6-astra', 'GPT-6 Astra'), ('gpt-6.1-sol', 'GPT-6.1 Sol'),
          ('gpt-6-luna', 'GPT-6 Luna'), ('gpt-5.6-sol', 'GPT-5.6 Sol')]
MAIN_FILES = ['s2_ctx4', 's2_ctx4_probes', 's2_ctx2', 's2_ctx2c',
              's2_ctx3', 'jobs_study1', 's2_ctx1', 's2_ctx1_rungs']
CAP = 2600


def timestamp():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def atomic_json(path, value):
    temporary = path.with_name(path.name + f'.{os.getpid()}.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    os.replace(temporary, path)


class ControllerError(Exception):
    pass


class StudyController:
    def __init__(self, root=None, clock=time.time, sleeper=time.sleep):
        self.root = Path(root or Path(__file__).resolve().parent).resolve()
        self.handoff = self.root.parent / 'handoff'
        self.repo = self.root.parents[1]
        self.clock, self.sleep = clock, sleeper
        self.state_path = self.root / '_controller_state.json'
        self.stop_path = self.root / '_STOP.json'
        self.state = (json.loads(self.state_path.read_text()) if self.state_path.exists() else
                      {'version': 1, 'smoke': {}, 'main': {}, 'model_status': {}, 'invocations': []})
        if self.state.get('version') != 1:
            raise ControllerError('Unsupported controller state version.')
        self.job_ids = {}
        seen_ids = set()
        for name in ['s2_smoke', *MAIN_FILES]:
            ids = [json.loads(line)['id'] for line in (self.handoff / (name + '.jsonl')).read_bytes().splitlines()
                   if line.strip()]
            if any(not isinstance(job_id, str) or Path(job_id).name != job_id or job_id in ('', '.', '..') for job_id in ids):
                raise ControllerError('Invalid job identifier in handoff metadata.')
            if len(set(ids)) != len(ids) or seen_ids.intersection(ids):
                raise ControllerError('Job identifiers collide across handoff files.')
            self.job_ids[name] = ids
            seen_ids.update(ids)

    def progress(self, **fields):
        print(json.dumps(fields, sort_keys=True), flush=True)

    def calls(self):
        path = self.root / '_ledger.json'
        return int(json.loads(path.read_text()).get('calls', 0)) if path.exists() else 0

    def pending(self, name, model):
        return sum(not (self.root / model / (job_id + '.json')).exists() for job_id in self.job_ids[name])

    def answers(self, name, model):
        total = 0
        for job_id in self.job_ids[name]:
            path = self.root / model / (job_id + '.json')
            if path.exists():
                record = json.loads(path.read_text())
                text = record.get('result')
                total += bool(not record.get('refused_by_api') and isinstance(text, str) and text.strip())
        return total

    def save_state(self, status):
        self.state.update(status=status, updated_utc=timestamp(), ledger_calls=self.calls())
        atomic_json(self.state_path, self.state)

    def read_stop(self):
        try:
            marker = json.loads(self.stop_path.read_text())
        except FileNotFoundError:
            return None
        except (OSError, ValueError):
            return {'action': 'stop', 'reason': 'unreadable_stop_marker'}
        if not isinstance(marker, dict) or marker.get('action') not in ('pause', 'stop'):
            return {'action': 'stop', 'reason': 'unrecognized_stop_marker'}
        return marker

    def checked(self, command, label):
        result = subprocess.run(command, cwd=self.repo, capture_output=True)
        if result.returncode:
            # Avoid echoing command output: it may contain provider or Git auth diagnostics.
            raise ControllerError(f'{label} failed (exit {result.returncode}); no further model calls started.')
        return result.stdout

    def whitespace_check_command(self, staged=False):
        # Captured streams and model records are evidence; their bytes must not
        # be rewritten to satisfy source-formatting rules. Glob pathspecs match
        # only authored files directly in astra_out, never nested trace/data.
        prefix = str(self.root.relative_to(self.repo))
        patterns = [f':(glob){prefix}/*.{extension}'
                    for extension in ('py', 'md', 'txt', 'sh', 'toml', 'yaml', 'yml')]
        patterns.append(f':(literal){prefix}/.gitignore')
        return ['git', 'diff', *(['--cached'] if staged else []), '--check', '--', *patterns]

    def checkpoint(self, status):
        self.save_state(status)
        self.checked([sys.executable, '-B', str(self.root / '_refresh_coverage.py'), '--status', status], 'Coverage verification')
        prefix = str(self.root.relative_to(self.repo))
        self.checked(self.whitespace_check_command(), 'Authored-file diff verification')
        self.checked(['git', 'add', '-A', '--', prefix,
                      f':(exclude){prefix}/**/*.lock', f':(exclude){prefix}/*.lock',
                      f':(exclude){prefix}/**/__pycache__/**',
                      f':(exclude){prefix}/__pycache__/**', f':(exclude){prefix}/**/*.pyc'], 'Scoped staging')
        self.checked([sys.executable, '-B', str(self.root / '_check_publish.py')], 'Credential publication check')
        self.checked(self.whitespace_check_command(staged=True), 'Staged authored-file diff verification')
        changed = subprocess.run(['git', 'diff', '--cached', '--quiet'], cwd=self.repo, capture_output=True)
        if changed.returncode not in (0, 1):
            raise ControllerError('Cannot inspect staged changes.')
        if changed.returncode:
            self.checked(['git', 'commit', '-m', f'Record purpose-sensitivity progress ({self.calls()} attempts)'], 'Commit')
        branch = self.checked(['git', 'branch', '--show-current'], 'Branch lookup').decode().strip()
        if not branch:
            raise ControllerError('Publication requires the existing named study branch.')
        self.checked(['git', 'push', '-u', 'origin', branch], 'Push')
        self.progress(event='checkpoint_pushed', calls=self.calls())

    def runner_command(self, name, model, display):
        template = (self.root / '_command.txt').read_text().strip()
        return [sys.executable, '-B', str(self.root / '_run_guarded.py'),
                str(self.handoff / (name + '.jsonl')), str(self.root),
                '--model', model, '--display-name', display, '--developer', 'OpenAI',
                '--backend', 'cmd', '--workers', '2',
                '--max-calls', str(CAP), '--retries', '1', '--ordered',
                '--reasoning-effort', 'default', '--cmd-stdin', 'prompt', '--cmd', template]

    def invoke(self, name, model, display):
        logdir = self.root / '_logs'
        logdir.mkdir(exist_ok=True)
        log = logdir / f'{model}__{name}.log'
        with log.open('ab') as output:
            output.write((f'\nController invocation at {timestamp()}\n').encode())
            output.flush()
            proc = subprocess.Popen(self.runner_command(name, model, display), cwd=self.repo,
                                    stdin=subprocess.DEVNULL, stdout=output, stderr=subprocess.STDOUT,
                                    start_new_session=True)
            try:
                while proc.poll() is None:
                    self.sleep(0.25)
            except KeyboardInterrupt:
                # Every capture process polls this marker, including those with their own session.
                with self.stop_path.with_suffix('.lock').open('a') as lock:
                    fcntl.flock(lock, fcntl.LOCK_EX)
                    atomic_json(self.stop_path, {'action': 'stop', 'reason': 'controller_interrupted',
                                                 'timestamp': self.clock()})
                try:
                    proc.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    os.killpg(proc.pid, signal.SIGTERM)
                    proc.wait(timeout=5)
                return 77
        return proc.returncode

    def settle_pause(self):
        """Called only after the prior guarded runner has exited and been published."""
        while True:
            marker = self.read_stop()
            if not marker:
                return 0
            if marker.get('action') != 'pause':
                self.progress(status='blocked_operational_stop', reason=marker.get('reason'), calls=self.calls())
                return 77
            reset = marker.get('resume_at_unix')
            if not isinstance(reset, (int, float)) or not math.isfinite(reset):
                self.progress(status='blocked_until_reset_known', calls=self.calls())
                return 75
            remaining = reset - self.clock()
            if remaining > 0:
                self.progress(status='paused_for_usage_reset', wait_seconds=round(remaining, 1), calls=self.calls())
                self.sleep(min(30, remaining))
                continue
            with self.stop_path.with_suffix('.lock').open('a') as lock:
                fcntl.flock(lock, fcntl.LOCK_EX)
                current = self.read_stop()
                if not current:
                    return 0
                current_reset = current.get('resume_at_unix')
                if (current.get('action') == 'pause' and isinstance(current_reset, (int, float))
                        and math.isfinite(current_reset) and current_reset <= self.clock()):
                    self.stop_path.unlink()
                    self.progress(event='usage_pause_cleared', calls=self.calls())
                    return 0

    def gate(self):
        marker = self.read_stop()
        if marker:
            self.checkpoint('Paused for a usage reset.' if marker.get('action') == 'pause'
                            else 'Stopped for an account, provider or authentication warning.')
            return self.settle_pause()
        if self.calls() >= CAP:
            self.checkpoint('The cumulative 2,600-attempt cap has been reached; remaining jobs are unstarted.')
            return 2
        return 0

    def attempt(self, name, model, display, phase):
        """Retry a paused partial invocation only after its explicit reset."""
        while True:
            gate = self.gate()
            if gate:
                return gate
            before = self.calls()
            self.progress(event='invocation_started', phase=phase, file=name, model=model,
                          pending=self.pending(name, model), calls=before)
            code = self.invoke(name, model, display)
            marker = self.read_stop()
            if marker:
                code = 75 if marker.get('action') == 'pause' else 77
            self.state['invocations'].append({'file': name, 'model': model, 'phase': phase,
                                               'exit_code': code, 'calls_before': before,
                                               'calls_after': self.calls(), 'finished_utc': timestamp()})
            self.progress(event='invocation_finished', file=name, model=model, exit_code=code,
                          calls=self.calls(), pending=self.pending(name, model))
            if code in (75, 77):
                self.checkpoint('Usage limit paused the run; progress is saved.' if code == 75
                                else 'An account, provider or authentication warning stopped the run; no later files were started.')
                if code == 77:
                    return code
                if not marker:
                    # A pause exit without reset metadata must not trigger an immediate retry.
                    return 75
                settled = self.settle_pause()
                if settled:
                    return settled
                continue
            if code not in (0, 1):
                self.checkpoint(f'Unexpected guarded-runner exit {code}; no further files were started.')
                raise ControllerError(f'Guarded runner returned unexpected exit {code}.')
            # Normal invocations are checkpointed by callers after updating their phase state.
            return code

    def smoke(self):
        for model, display in MODELS:
            entry = self.state['smoke'].setdefault(model, {'completed_invocations': 0})
            answer_count = self.answers('s2_smoke', model)
            if self.state['model_status'].get(model) == 'smoke_zero_answers':
                continue
            if self.pending('s2_smoke', model) == 0 and answer_count:
                self.state['model_status'][model] = 'eligible'
                continue
            if entry['completed_invocations'] >= 2:
                self.state['model_status'][model] = 'eligible' if answer_count else 'smoke_zero_answers'
                continue
            while entry['completed_invocations'] < 2:
                code = self.attempt('s2_smoke', model, display, 'smoke')
                if code in (2, 75, 77):
                    return code
                entry['completed_invocations'] += 1
                answer_count = self.answers('s2_smoke', model)
                if answer_count:
                    self.state['model_status'][model] = 'eligible'
                elif entry['completed_invocations'] == 2:
                    self.state['model_status'][model] = 'smoke_zero_answers'
                self.checkpoint(f'Smoke invocation completed for {model}: {answer_count} answers; individual failures remain recorded.')
                if answer_count and (not self.pending('s2_smoke', model) or entry['completed_invocations'] >= 2):
                    break
        return 0

    def remaining_initial_pending(self):
        return sum(self.pending(name, model) for name in MAIN_FILES for model, _ in MODELS
                   if self.state['model_status'].get(model) == 'eligible'
                   and not self.state['main'].get(f'{name}/{model}', {}).get('primary_complete'))

    def initial_files(self, names):
        for name in names:
            for model, display in MODELS:
                if self.state['model_status'].get(model) != 'eligible':
                    continue
                entry = self.state['main'].setdefault(f'{name}/{model}', {})
                if entry.get('finished'):
                    continue
                if not entry.get('primary_complete'):
                    if self.pending(name, model):
                        code = self.attempt(name, model, display, 'main_initial')
                        if code in (2, 75, 77):
                            return code
                        entry.update(primary_complete=True, primary_exit_code=code)
                        self.checkpoint(f'Initial invocation completed for {name}.jsonl / {model}; individual failures remain recorded.')
                    else:
                        entry['primary_complete'] = True
                missing = self.pending(name, model)
                remaining_initial = self.remaining_initial_pending()
                if missing and not entry.get('retry_complete') and self.calls() + missing + remaining_initial <= CAP:
                    code = self.attempt(name, model, display, 'main_retry')
                    if code in (2, 75, 77):
                        return code
                    entry.update(retry_complete=True, retry_exit_code=code, finished=True)
                    self.checkpoint(f'One immediate retry completed for {name}.jsonl / {model}; later repairs may use spare call budget.')
                else:
                    entry.update(finished=True, retry_skipped=('initial_attempt_budget_reserved' if missing else 'no_missing_jobs'))
                    self.save_state('Continuing ordered files; initial-attempt budget remains reserved.')
        return 0

    def repair_non_rungs(self):
        """Spend usable retry allowance before rungs, preserving their initial calls."""
        while True:
            calls_before_round = self.calls()
            attempted = False
            for name in MAIN_FILES[:-1]:
                for model, display in MODELS:
                    if self.state['model_status'].get(model) != 'eligible':
                        continue
                    missing = self.pending(name, model)
                    if not missing or self.calls() + missing + self.remaining_initial_pending() > CAP:
                        continue
                    attempted = True
                    code = self.attempt(name, model, display, 'main_repair')
                    if code in (2, 75, 77):
                        return code
                    entry = self.state.setdefault('repair', {}).setdefault(f'{name}/{model}', {'invocations': 0})
                    entry['invocations'] += 1
                    entry['last_exit_code'] = code
                    self.checkpoint(f'Repair invocation completed for {name}.jsonl / {model}; initial calls for later files remain reserved.')
            if not attempted:
                return 0
            if self.calls() == calls_before_round:
                raise ControllerError('Repair invocations made no counted attempts; stopped before starting more files.')

    def main_files(self):
        code = self.initial_files(MAIN_FILES[:-1])
        if not code:
            code = self.repair_non_rungs()
        if not code:
            code = self.initial_files(MAIN_FILES[-1:])
        return code

    def run(self):
        # Validate resume records and finish any previously interrupted publication
        # before starting another invocation. The credential guard remains active.
        self.checkpoint('Resuming the authorized ordered study run; existing records were verified.')
        code = self.gate()
        if not code:
            code = self.smoke()
        if not code:
            code = self.main_files()
        if not code and self.read_stop():
            code = self.gate()
        if not code:
            self.checkpoint('All selected ordered file invocations are finished. Individual failures, skipped models and coverage gaps are preserved.')
        self.progress(status='complete' if code == 0 else 'blocked_or_capped', exit_code=code,
                      calls=self.calls(), model_status=self.state['model_status'])
        return code


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dry-run', action='store_true', help='Show counts/order without running models, Git, or credential checks.')
    args = parser.parse_args()
    try:
        controller = StudyController()
        if args.dry_run:
            controller.progress(dry_run=True, calls=controller.calls(), cap=CAP,
                                model_order=[model for model, _ in MODELS], file_order=MAIN_FILES,
                                pending={name: {model: controller.pending(name, model) for model, _ in MODELS}
                                         for name in ['s2_smoke', *MAIN_FILES]})
            return 0
        return controller.run()
    except (ControllerError, OSError, ValueError, KeyError) as exc:
        # Controlled error messages contain stage labels, not captured provider/answer text.
        message = str(exc) if isinstance(exc, ControllerError) else type(exc).__name__
        print(json.dumps({'status': 'controller_error', 'error': message}), flush=True)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
