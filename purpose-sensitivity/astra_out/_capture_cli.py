"""Capture complete CLI event streams and count metadata without interpreting answers."""
import collections
import json
import os
from pathlib import Path
import re
import selectors
import signal
import subprocess
import sys
import time

workdir, model, answer_file, *command = sys.argv[1:]
root = Path(__file__).resolve().parent
slug = re.sub(r'[^A-Za-z0-9._-]+', '_', model)
stem = Path(workdir).name
logdir = root / '_events' / slug
logdir.mkdir(parents=True, exist_ok=True)
stop = root / '_STOP.json'
if stop.exists():
    raise SystemExit('A prior operational stop marker prevents further model calls.')
proc = None

def terminate(signum=None, frame=None):
    if proc is not None and proc.poll() is None:
        os.killpg(proc.pid, signal.SIGTERM)
    if signum is not None:
        raise SystemExit(128 + signum)

signal.signal(signal.SIGTERM, terminate)
signal.signal(signal.SIGINT, terminate)
rate = re.compile(r'\brate[ _-]?limit|\busage[ _-]?limit|\b429\b|\bquota (?:exceeded|exhausted)', re.I)
account = re.compile(r'account.{0,100}(?:suspended|deactivated|warning)|warning.{0,100}account', re.I)
stop_reason = None
try:
    proc = subprocess.Popen(command, stdin=sys.stdin, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, start_new_session=True)
    poller = selectors.DefaultSelector()
    poller.register(proc.stdout, selectors.EVENT_READ, 'stdout')
    poller.register(proc.stderr, selectors.EVENT_READ, 'stderr')
    with (logdir / (stem + '.jsonl')).open('wb') as events, (logdir / (stem + '.stderr.log')).open('wb') as errors:
        while poller.get_map():
            for key, _ in poller.select(timeout=1):
                line = key.fileobj.readline()
                if not line:
                    poller.unregister(key.fileobj)
                    continue
                if key.data == 'stdout':
                    events.write(line)
                    events.flush()
                    sys.stdout.buffer.write(line)
                    sys.stdout.buffer.flush()
                    operational = ''
                    try:
                        event = json.loads(line)
                        if event.get('type') in ('error', 'turn.failed'):
                            operational = json.dumps(event)
                    except (ValueError, AttributeError):
                        pass
                else:
                    errors.write(line)
                    errors.flush()
                    sys.stderr.buffer.write(line)
                    sys.stderr.buffer.flush()
                    operational = line.decode(errors='replace')
                reason = 'account_warning' if account.search(operational) else ('usage_or_rate_limit' if rate.search(operational) else None)
                if reason and stop_reason is None:
                    stop_reason = reason
                    stop.write_text(json.dumps({'reason': reason, 'model': model, 'stream': str(logdir / stem), 'timestamp': time.time()}))
                    terminate()
        code = proc.wait()
finally:
    terminate()

tool_types = {'command_execution', 'file_change', 'mcp_tool_call', 'collab_tool_call', 'web_search', 'todo_list'}
known = tool_types | {'agent_message', 'reasoning', 'error'}
counts = collections.Counter()
item_counts = collections.Counter()
observed = {}
unknown = set()
malformed = 0
last_agent_nonempty = False
for line in (logdir / (stem + '.jsonl')).read_text(errors='replace').splitlines():
    try:
        event = json.loads(line)
        counts[event.get('type', '<missing>')] += 1
        item = event.get('item') or {}
        kind = item.get('type')
        if kind:
            item_counts[kind] += 1
            if kind not in known:
                unknown.add(kind)
            if kind in tool_types:
                observed[str(item.get('id', '<missing-id>'))] = kind
            if event.get('type') == 'item.completed' and kind == 'agent_message':
                last_agent_nonempty = isinstance(item.get('text'), str) and bool(item['text'].strip())
    except (ValueError, AttributeError):
        malformed += 1
answer = Path(answer_file)
audit = {
    'model': model, 'cli_exit_code': code, 'event_types': dict(counts),
    'item_event_types': dict(item_counts), 'observed_tool_items': len(observed),
    'observed_tool_items_by_type': dict(collections.Counter(observed.values())),
    'unknown_item_types': sorted(unknown), 'malformed_event_lines': malformed,
    'turn_completed': counts['turn.completed'] > 0,
    'last_agent_message_nonempty': last_agent_nonempty,
    'answer_file_nonempty': answer.exists() and answer.stat().st_size > 0,
    'stop_reason': stop_reason,
    'limitation': 'Codex 0.159.2 JSON formatter omits some tool kinds, including clock; these are observed items, not verified total tool calls.'
}
(logdir / (stem + '.audit.json')).write_text(json.dumps(audit, indent=2) + '\n')
print(json.dumps({'type': 'capture.audit', **audit}), flush=True)
raise SystemExit(code if code >= 0 else 128 - code)
