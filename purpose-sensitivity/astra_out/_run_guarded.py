"""Run the unchanged supplied runner with a shared operational-stop gate.

Deviation from astra_runner.py: queued jobs and new ledger reservations stop at
_STOP.json; already-running work may finish its ordinary result bookkeeping.
The original request construction, answer handling, cap accounting, and resume
semantics are unchanged. The launcher uses one attempt per invocation and a
cumulative cap no greater than 2600. It never clears a stop marker.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
import threading


sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parent


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class StopGuard:
    """Coordinate with capture's STOP lock and the runner's ledger lock."""

    def __init__(self, runner, capture, stop_path):
        self.runner = runner
        self.capture = capture
        self.stop_path = Path(stop_path)
        self.marker = None
        self.marker_lock = threading.Lock()
        self.local = threading.local()
        self.original_print = getattr(runner, 'print', print)
        guard = self

        class OperationalStop(runner.CapReached):
            pass

        self.OperationalStop = OperationalStop
        original_ledger = runner.Ledger

        class GuardedLedger(original_ledger):
            def reserve(self, model):
                guard.local.reserving = True
                try:
                    return super().reserve(model)
                finally:
                    guard.local.reserving = False

            def _update(self, fn):
                if not getattr(guard.local, 'reserving', False):
                    return super()._update(fn)

                def guarded_update(ledger):
                    # This executes under the original thread and file locks.
                    guard.require_running()
                    return fn(ledger)

                # Keep the shared STOP lock until the ledger write completes.
                # Capture publishes STOP under this same lock. Thus a new
                # reservation is wholly before STOP publication or is rejected.
                with guard.stop_path.with_suffix('.lock').open('a') as lock:
                    if runner.fcntl:
                        runner.fcntl.flock(lock, runner.fcntl.LOCK_EX)
                    return super()._update(guarded_update)

        original_run_one = runner.run_one

        def guarded_run_one(job, args, outdir, ledger):
            if (Path(outdir) / (job['id'] + '.json')).exists():
                return 'skip'
            guard.require_running()
            return original_run_one(job, args, outdir, ledger)

        runner.Ledger = GuardedLedger
        runner.run_one = guarded_run_one
        runner.print = self.runner_print

    def current_stop(self):
        current = self.capture.read_stop(self.stop_path)
        with self.marker_lock:
            if current:
                if not self.marker or self.marker.get('action') != 'stop':
                    self.marker = current
            # Latch the stop for this invocation. Only a new invocation resumes.
            return dict(self.marker) if self.marker else None

    def require_running(self):
        if self.current_stop():
            raise self.OperationalStop()

    def runner_print(self, *values, **kwargs):
        first = values[0] if values else None
        marker = self.current_stop()
        if marker and isinstance(first, str) and first.startswith('CAP reached'):
            self.original_print(
                'STOPPED: shared operational marker prevents new jobs and reservations; '
                'the cumulative call ledger is retained.', **kwargs)
        elif marker and first == 'DONE':
            self.original_print('STOPPED', *values[1:], **kwargs)
        else:
            self.original_print(*values, **kwargs)

    def exit_code(self, original_code):
        marker = self.current_stop()
        if marker:
            return 75 if marker.get('action') == 'pause' else 77
        return original_code


def main(argv=None):
    arguments = list(sys.argv[1:] if argv is None else argv)
    limits = argparse.ArgumentParser(add_help=False)
    limits.add_argument('--retries', type=int, default=1)
    limits.add_argument('--max-calls', type=int, default=2600)
    selected, _ = limits.parse_known_args(arguments)
    if selected.retries != 1:
        limits.error('the guarded launcher requires --retries 1')
    if not 0 < selected.max_calls <= 2600:
        limits.error('--max-calls must be between 1 and the cumulative ceiling of 2600')
    # Supplying these explicitly avoids the runner's default of five retries.
    arguments += ['--retries', '1', '--max-calls', str(selected.max_calls)]
    runner = load_module('astra_supplied_runner', ROOT.parent / 'handoff/astra_runner.py')
    capture = load_module('astra_capture', ROOT / '_capture_cli.py')
    guard = StopGuard(runner, capture, ROOT / '_STOP.json')
    saved_argv = sys.argv
    try:
        sys.argv = [str(ROOT / '_run_guarded.py'), *arguments]
        marker = guard.current_stop()
        if marker and not any(value in ('-h', '--help') for value in arguments):
            print(json.dumps({'status': 'stopped_before_runner',
                              'action': marker.get('action'), 'reason': marker.get('reason'),
                              'resume_at_unix': marker.get('resume_at_unix')}), flush=True)
            return guard.exit_code(0)
        return guard.exit_code(runner.main())
    finally:
        sys.argv = saved_argv


if __name__ == '__main__':
    raise SystemExit(main())

