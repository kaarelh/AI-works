"""Capture CLI traces and validate delivery without interpreting subject answers.

The supervisor owns clearing _STOP.json: action=pause may resume after the
recorded reset; action=stop requires resolving the account/provider problem.
This helper never clears a shared stop or changes the answer file.
"""
import collections
import datetime
import fcntl
import hashlib
import json
import math
import os
from pathlib import Path
import re
import selectors
import signal
import subprocess
import sys
import time


RATE = re.compile(
    r'\brate[ _-]?limit|\busage[ _-]?limit|\b429\b|too many requests|'
    r'\bquota.{0,60}(?:exceeded|exhausted)|(?:weekly|daily|monthly).{0,40}limit', re.I)
AUTH = re.compile(
    r'(?:sign|log)[ -]?in (?:again|required)|please (?:sign|log)[ -]?in|'
    r'logged out|not authenticated|authentication.{0,60}(?:required|failed)|'
    r'(?:access|refresh|authentication) token.{0,100}(?:expired|invalid|refresh|revoked)|'
    r'credentials.{0,60}(?:expired|invalid|missing)|unauthori[sz]ed|\b401\b', re.I)
ACCOUNT = re.compile(
    r'account.{0,100}(?:suspended|deactivated|warning|disabled|locked|restricted|blocked)|'
    r'warning.{0,100}account|billing.{0,60}(?:warning|failed|required|limit)|'
    r'payment.{0,60}(?:failed|required|overdue)|insufficient (?:credits|funds)|\b402\b', re.I)
PROVIDER = re.compile(r'provider.{0,100}warning|warning.{0,100}provider', re.I)
TOOL_TYPES = {'command_execution', 'file_change', 'mcp_tool_call',
              'collab_tool_call', 'web_search', 'todo_list'}
KNOWN_ITEMS = TOOL_TYPES | {'agent_message', 'reasoning', 'error'}
KNOWN_EVENTS = {'thread.started', 'turn.started', 'turn.completed', 'turn.failed',
                'item.started', 'item.updated', 'item.completed', 'error'}


def reset_metadata(text, now):
    """Use explicit relative/absolute reset information; do not invent a reset."""
    match = re.search(r'(?:retry[_ -]?after(?:[_ -]?seconds)?[\s\":=]+|'
                      r'(?:try again|reset(?:s)?|retry) in\s+)(\d+(?:\.\d+)?)'
                      r'\s*(seconds?|secs?|s|minutes?|mins?|m|hours?|hrs?|h)?\b', text, re.I)
    if match:
        unit = (match.group(2) or 's').lower()
        seconds = float(match.group(1)) * (3600 if unit.startswith('h') else
                                          60 if unit.startswith('m') else 1)
        # Include subsequent units so "1 hour 20 minutes" cannot resume early.
        remainder = text[match.end():]
        while True:
            extra = re.match(r'\s*(?:(?:,|and)\s*)?(\d+(?:\.\d+)?)\s*'
                             r'(hours?|hrs?|h|minutes?|mins?|m|seconds?|secs?|s)\b', remainder, re.I)
            if not extra:
                break
            unit = extra.group(2).lower()
            seconds += float(extra.group(1)) * (3600 if unit.startswith('h') else
                                                60 if unit.startswith('m') else 1)
            remainder = remainder[extra.end():]
        return {'retry_after_seconds': seconds, 'resume_at_unix': now + seconds}
    match = re.search(r'(?:reset(?:s)?(?:[_ -]?at)?|try again at)[\s\":=]+'
                      r'(\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}(?::\d{2})?'
                      r'(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2}))', text, re.I)
    if match:
        try:
            timestamp = datetime.datetime.fromisoformat(match.group(1).replace('Z', '+00:00')).timestamp()
            return {'resume_at_unix': timestamp,
                    'retry_after_seconds': max(0.0, timestamp - now)}
        except ValueError:
            pass
    return {}


def classify_operational(text):
    if not text:
        return None
    if AUTH.search(text):
        return {'reason': 'human_auth_required', 'action': 'stop', 'human_auth_required': True}
    if ACCOUNT.search(text):
        return {'reason': 'account_warning', 'action': 'stop', 'human_auth_required': False}
    if RATE.search(text):
        return {'reason': 'usage_or_rate_limit', 'action': 'pause', 'human_auth_required': False,
                **reset_metadata(text, time.time())}
    if PROVIDER.search(text):
        return {'reason': 'provider_warning', 'action': 'stop', 'human_auth_required': False}
    return None


def read_stop(path):
    try:
        marker = json.loads(path.read_text())
        if not isinstance(marker, dict) or marker.get('action') not in ('pause', 'stop'):
            return {'reason': 'prior_operational_stop', 'action': 'stop',
                    'human_auth_required': bool(isinstance(marker, dict) and marker.get('human_auth_required'))}
        return marker
    except FileNotFoundError:
        return None
    except (ValueError, OSError):
        return {'reason': 'unreadable_stop_marker', 'action': 'stop', 'human_auth_required': False}


def publish_stop(path, marker):
    """Publish atomically; a rate pause must never replace an account stop."""
    with path.with_suffix('.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        previous = read_stop(path)
        if previous and (previous.get('action') == 'stop' or marker['action'] == 'pause'):
            if previous.get('action') == 'pause' and marker.get('resume_at_unix', 0) > previous.get('resume_at_unix', 0):
                previous.update(resume_at_unix=marker['resume_at_unix'],
                                retry_after_seconds=marker.get('retry_after_seconds'))
                marker = previous
            else:
                return previous
        temporary = path.with_name(path.name + f'.{os.getpid()}.tmp')
        temporary.write_text(json.dumps(marker, indent=2) + '\n')
        os.replace(temporary, path)
        return marker


def operational_event(event):
    kind = event.get('type')
    if kind in ('error', 'turn.failed'):
        # These event payloads are operational errors, not subject messages.
        return json.dumps(event)
    item = event.get('item')
    if kind in ('item.started', 'item.updated', 'item.completed') and isinstance(item, dict) and item.get('type') == 'error':
        return str(item.get('message', ''))
    return ''


def main(argv):
    if len(argv) < 4:
        raise SystemExit('usage: _capture_cli.py WORKDIR MODEL ANSWER COMMAND [ARGS...]')
    workdir, model, answer_file, *command = argv
    root = Path(__file__).resolve().parent
    slug = re.sub(r'[^A-Za-z0-9._-]+', '_', model)
    stem = Path(workdir).name
    logdir = root / '_events' / slug
    logdir.mkdir(parents=True, exist_ok=True)
    events_path = logdir / (stem + '.jsonl')
    errors_path = logdir / (stem + '.stderr.log')
    audit_path = logdir / (stem + '.audit.json')
    stop_path = root / '_STOP.json'
    stop_marker = read_stop(stop_path)
    timeout_seconds = float(os.environ.get('ASTRA_CLI_TIMEOUT_SECONDS', '1150'))
    if not math.isfinite(timeout_seconds) or timeout_seconds <= 0:
        raise SystemExit('ASTRA_CLI_TIMEOUT_SECONDS must be a positive finite number.')
    proc = None
    interrupted = None
    termination_started = None
    killed = False
    code = None
    wrapper_error = None
    timed_out = False
    started = time.time()
    started_monotonic = time.monotonic()
    stdout_last_byte = b'\n'
    counts = collections.Counter()
    item_counts = collections.Counter()
    observed = {}
    unknown_items = set()
    unknown_events = set()
    malformed = 0
    missing_item_ids = 0
    thread_ids = []
    last_agent = None
    last_terminal = None
    buffers = {'stdout': bytearray(), 'stderr': bytearray()}

    def terminate_group(force=False):
        nonlocal termination_started
        if proc is None:
            return
        if termination_started is None:
            termination_started = time.monotonic()
        try:
            os.killpg(proc.pid, signal.SIGKILL if force else signal.SIGTERM)
        except ProcessLookupError:
            pass

    def on_signal(signum, frame):
        nonlocal interrupted
        interrupted = signum
        terminate_group()

    def check_operational(text, stream):
        nonlocal stop_marker
        marker = classify_operational(text)
        if marker:
            marker.update(model=model, stream=stream, events_path=str(events_path),
                          audit_path=str(audit_path), timestamp=time.time())
            stop_marker = publish_stop(stop_path, marker)
            terminate_group()

    def consume_line(raw, stream):
        nonlocal malformed, missing_item_ids, last_agent, last_terminal
        if stream == 'stderr':
            check_operational(raw.decode('utf-8', errors='replace'), stream)
            return
        try:
            event = json.loads(raw)
            if not isinstance(event, dict) or not isinstance(event.get('type'), str):
                raise ValueError('event must have a string type')
        except (ValueError, UnicodeDecodeError):
            malformed += 1
            return
        kind = event['type']
        counts[kind] += 1
        if kind not in KNOWN_EVENTS:
            unknown_events.add(kind)
        if kind == 'thread.started' and isinstance(event.get('thread_id'), str):
            thread_ids.append(event['thread_id'])
        if kind in ('turn.completed', 'turn.failed'):
            last_terminal = kind
        item = event.get('item')
        if isinstance(item, dict) and isinstance(item.get('type'), str):
            item_kind = item['type']
            item_counts[item_kind] += 1
            if item_kind not in KNOWN_ITEMS:
                unknown_items.add(item_kind)
            if item_kind in TOOL_TYPES:
                item_id = item.get('id')
                if not isinstance(item_id, str):
                    missing_item_ids += 1
                    item_id = f'<missing-id-event-{sum(counts.values())}>'
                observed[item_id] = item_kind
            if kind == 'item.completed' and item_kind == 'agent_message':
                last_agent = item.get('text') if isinstance(item.get('text'), str) else None
        check_operational(operational_event(event), 'stdout')

    signal.signal(signal.SIGTERM, on_signal)
    signal.signal(signal.SIGINT, on_signal)
    with events_path.open('wb') as events, errors_path.open('wb') as errors:
        try:
            if stop_marker is None:
                proc = subprocess.Popen(command, stdin=sys.stdin, stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE, start_new_session=True)
                with selectors.DefaultSelector() as poller:
                    for pipe, stream in ((proc.stdout, 'stdout'), (proc.stderr, 'stderr')):
                        os.set_blocking(pipe.fileno(), False)
                        poller.register(pipe, selectors.EVENT_READ, stream)
                    while poller.get_map() or proc.poll() is None:
                        shared = read_stop(stop_path)
                        if shared:
                            stop_marker = shared
                        if time.monotonic() - started_monotonic >= timeout_seconds:
                            timed_out = True
                        if stop_marker or interrupted or timed_out:
                            if termination_started is None:
                                terminate_group()
                            elif not killed and time.monotonic() - termination_started > 2:
                                terminate_group(force=True)
                                killed = True
                        for key, _ in poller.select(timeout=0.1):
                            stream = key.data
                            try:
                                chunk = os.read(key.fd, 65536)
                            except BlockingIOError:
                                continue
                            if not chunk:
                                poller.unregister(key.fileobj)
                                if buffers[stream]:
                                    consume_line(bytes(buffers[stream]), stream)
                                    buffers[stream].clear()
                                key.fileobj.close()
                                continue
                            target = events if stream == 'stdout' else errors
                            output = sys.stdout.buffer if stream == 'stdout' else sys.stderr.buffer
                            target.write(chunk)
                            target.flush()
                            output.write(chunk)
                            output.flush()
                            if stream == 'stdout':
                                stdout_last_byte = chunk[-1:]
                            buffers[stream].extend(chunk)
                            while b'\n' in buffers[stream]:
                                line, _, remaining = buffers[stream].partition(b'\n')
                                buffers[stream] = bytearray(remaining)
                                consume_line(bytes(line), stream)
                            # A CLI may emit an authentication warning without a newline.
                            if stream == 'stderr' and buffers[stream]:
                                check_operational(buffers[stream].decode('utf-8', errors='replace'), stream)
                    code = proc.wait()
        except (OSError, BrokenPipeError) as exc:
            wrapper_error = type(exc).__name__
            terminate_group()
        finally:
            if proc is not None and proc.poll() is None:
                terminate_group()
                try:
                    proc.wait(timeout=2)
                except subprocess.TimeoutExpired:
                    terminate_group(force=True)
                    proc.wait()
            if proc is not None:
                code = proc.returncode

    answer = Path(answer_file)
    try:
        answer_bytes = answer.read_bytes()
    except FileNotFoundError:
        answer_bytes = None
    except OSError as exc:
        answer_bytes = None
        wrapper_error = type(exc).__name__
    agent_bytes = last_agent.encode('utf-8') if last_agent is not None else None
    answer_nonempty = answer_bytes is not None and bool(answer_bytes.strip())
    agent_nonempty = last_agent is not None and bool(last_agent.strip())
    answer_matches = answer_bytes is not None and agent_bytes is not None and answer_bytes == agent_bytes
    validation = []
    if last_terminal != 'turn.completed' or counts['turn.completed'] != 1 or counts['turn.failed']:
        validation.append('one_successful_completed_turn_required')
    if malformed:
        validation.append('malformed_event_lines')
    if not answer_nonempty:
        validation.append('missing_or_empty_answer_file')
    if not agent_nonempty:
        validation.append('missing_or_empty_final_agent_message')
    if not answer_matches:
        validation.append('answer_does_not_match_final_agent_message')
    if wrapper_error:
        validation.append('capture_error')
    if timed_out:
        validation.append('cli_timeout')
    if interrupted:
        exit_code = 128 + interrupted
    elif stop_marker:
        exit_code = 75 if stop_marker.get('action') == 'pause' else 77
    elif timed_out:
        exit_code = 124
    elif code:
        exit_code = code if code > 0 else 128 - code
    elif validation or code is None:
        exit_code = 65
    else:
        exit_code = 0
    audit = {
        'model': model, 'capture_id': stem, 'thread_ids': thread_ids,
        'events_path': str(events_path), 'stderr_path': str(errors_path), 'audit_path': str(audit_path),
        'cli_exit_code': code, 'capture_exit_code': exit_code,
        'event_types': dict(counts), 'item_event_types': dict(item_counts),
        'observed_tool_items': len(observed),
        'observed_tool_items_by_type': dict(collections.Counter(observed.values())),
        'unknown_item_types': sorted(unknown_items), 'unknown_event_types': sorted(unknown_events),
        'malformed_event_lines': malformed, 'tool_events_without_item_ids': missing_item_ids,
        'turn_completed': last_terminal == 'turn.completed',
        'last_agent_message_nonempty': agent_nonempty, 'answer_file_nonempty': answer_nonempty,
        'answer_matches_final_agent_message': answer_matches,
        'answer_bytes': len(answer_bytes) if answer_bytes is not None else None,
        'answer_sha256': hashlib.sha256(answer_bytes).hexdigest() if answer_bytes is not None else None,
        'validation_errors': validation, 'wrapper_error': wrapper_error,
        'timed_out': timed_out, 'cli_timeout_seconds': timeout_seconds,
        'stop_reason': stop_marker.get('reason') if stop_marker else None,
        'stop_action': stop_marker.get('action') if stop_marker else None,
        'human_auth_required': bool(stop_marker and stop_marker.get('human_auth_required')),
        'resume_at_unix': stop_marker.get('resume_at_unix') if stop_marker else None,
        'started_at_unix': started, 'finished_at_unix': time.time(),
        'limitation': 'Codex 0.159.2 JSON formatter omits some tool kinds, including clock; these are observed items, not verified total tool calls.'
    }
    audit_path.write_text(json.dumps(audit, indent=2) + '\n')
    if stdout_last_byte != b'\n':
        sys.stdout.buffer.write(b'\n')
        sys.stdout.buffer.flush()
    print(json.dumps({'type': 'capture.audit', **audit}), flush=True)
    if exit_code:
        # The supplied cmd runner retains stderr, but discards stdout on failure.
        print(f'Capture failed: exit={exit_code}; reason={audit["stop_reason"] or "individual_cli_or_delivery_failure"}; '
              f'audit={audit_path}', file=sys.stderr, flush=True)
    return exit_code


if __name__ == '__main__':
    raise SystemExit(main(sys.argv[1:]))
