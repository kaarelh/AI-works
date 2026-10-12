"""Isolated fake-CLI checks. No model calls, study inputs, or credentials."""
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time
import unittest


SOURCE = Path(__file__).with_name('_capture_cli.py')
SPEC = importlib.util.spec_from_file_location('capture_cli', SOURCE)
CAPTURE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CAPTURE)

FAKE = r'''
import json, os, signal, sys, time
from pathlib import Path
mode, answer_path = sys.argv[1:]
answer = "  Synthetic delivery fixture: café.\n\n"
def event(kind, **fields):
    print(json.dumps(dict(type=kind, **fields)), flush=True)
if mode in ('stall', 'ignore_term'):
    if mode == 'ignore_term':
        signal.signal(signal.SIGTERM, signal.SIG_IGN)
    os.write(1, b'{"partial":')
    time.sleep(15)
    raise SystemExit(0)
if mode == 'auth':
    os.write(2, b'Access token cannot be refreshed. Please sign in again.')
    time.sleep(15)
    raise SystemExit(1)
if mode == 'rate':
    event('item.completed', item=dict(id='warning', type='error', message='Usage limit reached; retry after 12 seconds'))
    time.sleep(15)
    raise SystemExit(1)
if mode == 'failure':
    event('turn.failed', error={'message': 'Synthetic individual failure'})
    raise SystemExit(1)
event('thread.started', thread_id='synthetic-thread')
event('turn.started')
if mode == 'tools':
    event('item.started', item=dict(id='tool1', type='command_execution', status='in_progress'))
    event('item.completed', item=dict(id='tool1', type='command_execution', status='failed'))
if mode == 'answer_mentions_limit':
    answer = 'Synthetic answer text says usage limit and please sign in again.'
if mode == 'malformed':
    print('not-json', flush=True)
event('item.completed', item=dict(id='answer', type='agent_message', text=answer))
if mode != 'no_turn':
    event('turn.completed', usage=dict(input_tokens=1, output_tokens=1))
if mode != 'missing':
    Path(answer_path).write_bytes((answer + ('changed' if mode == 'mismatch' else '')).encode('utf-8'))
'''


class CaptureTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='_capture_test_', dir=SOURCE.parent)
        self.root = Path(self.tmp.name)
        self.helper = self.root / '_capture_cli.py'
        shutil.copyfile(SOURCE, self.helper)
        self.fake = self.root / 'fake_cli.py'
        self.fake.write_text(FAKE)
        self.work = self.root / 'work'
        self.work.mkdir()
        self.answer = self.work / 'answer.txt'

    def tearDown(self):
        self.tmp.cleanup()

    def command(self, mode):
        return [sys.executable, str(self.helper), str(self.work), 'synthetic-model',
                str(self.answer), sys.executable, str(self.fake), mode, str(self.answer)]

    def audit(self):
        return json.loads((self.root / '_events/synthetic-model/work.audit.json').read_text())

    def run_fake(self, mode, timeout=None):
        env = None if timeout is None else dict(os.environ, ASTRA_CLI_TIMEOUT_SECONDS=str(timeout))
        result = subprocess.run(self.command(mode), stdin=subprocess.DEVNULL,
                                capture_output=True, timeout=6, env=env)
        return result, self.audit()

    def test_valid_answer_preserves_exact_bytes_and_trace(self):
        result, audit = self.run_fake('valid')
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self.answer.read_bytes(), '  Synthetic delivery fixture: café.\n\n'.encode())
        self.assertTrue(audit['answer_matches_final_agent_message'])
        raw = Path(audit['events_path']).read_bytes()
        self.assertTrue(result.stdout.startswith(raw))
        self.assertNotIn(b'capture.audit', raw)
        self.assertEqual(audit['thread_ids'], ['synthetic-thread'])

    def test_answer_content_does_not_trigger_operational_stop(self):
        result, audit = self.run_fake('answer_mentions_limit')
        self.assertEqual(result.returncode, 0)
        self.assertIsNone(audit['stop_reason'])
        self.assertFalse((self.root / '_STOP.json').exists())

    def test_missing_answer_never_accepts_stdout_fallback(self):
        result, audit = self.run_fake('missing')
        self.assertEqual(result.returncode, 65)
        self.assertIn('missing_or_empty_answer_file', audit['validation_errors'])
        self.assertFalse((self.root / '_STOP.json').exists())

    def test_mismatch_fails_without_modifying_answer(self):
        result, audit = self.run_fake('mismatch')
        self.assertEqual(result.returncode, 65)
        self.assertTrue(self.answer.read_bytes().endswith(b'changed'))
        self.assertFalse(audit['answer_matches_final_agent_message'])

    def test_no_completed_turn_fails(self):
        result, audit = self.run_fake('no_turn')
        self.assertEqual(result.returncode, 65)
        self.assertFalse(audit['turn_completed'])

    def test_malformed_trace_fails(self):
        result, audit = self.run_fake('malformed')
        self.assertEqual(result.returncode, 65)
        self.assertEqual(audit['malformed_event_lines'], 1)

    def test_item_error_rate_warning_pauses(self):
        start = time.monotonic()
        result, audit = self.run_fake('rate')
        self.assertLess(time.monotonic() - start, 3)
        self.assertEqual(result.returncode, 75)
        self.assertEqual(audit['stop_action'], 'pause')
        marker = json.loads((self.root / '_STOP.json').read_text())
        self.assertEqual(marker['retry_after_seconds'], 12)
        self.assertFalse(marker['human_auth_required'])

    def test_auth_warning_without_newline_stops_promptly(self):
        start = time.monotonic()
        result, audit = self.run_fake('auth')
        self.assertLess(time.monotonic() - start, 3)
        self.assertEqual(result.returncode, 77)
        self.assertTrue(audit['human_auth_required'])
        self.assertEqual(audit['stop_reason'], 'human_auth_required')

    def test_individual_failure_does_not_stop_batch(self):
        result, audit = self.run_fake('failure')
        self.assertEqual(result.returncode, 1)
        self.assertIsNone(audit['stop_reason'])
        self.assertFalse((self.root / '_STOP.json').exists())
        self.assertIn(audit['audit_path'].encode(), result.stderr)

    def test_started_completed_tool_is_counted_once(self):
        result, audit = self.run_fake('tools')
        self.assertEqual(result.returncode, 0)
        self.assertEqual(audit['observed_tool_items'], 1)
        self.assertEqual(audit['item_event_types']['command_execution'], 2)

    def stop_running_fake(self, mode):
        proc = subprocess.Popen(self.command(mode), stdin=subprocess.DEVNULL,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            trace = self.root / '_events/synthetic-model/work.jsonl'
            deadline = time.monotonic() + 4
            while not trace.exists() or not trace.stat().st_size:
                self.assertLess(time.monotonic(), deadline)
                time.sleep(0.02)
            start = time.monotonic()
            (self.root / '_STOP.json').write_text(json.dumps({'reason': 'account_warning', 'action': 'stop'}))
            proc.communicate(timeout=5)
            return proc.returncode, self.audit(), time.monotonic() - start
        finally:
            if proc.poll() is None:
                proc.terminate()
                proc.communicate(timeout=5)

    def test_shared_stop_interrupts_partial_stdout(self):
        code, audit, elapsed = self.stop_running_fake('stall')
        self.assertEqual(code, 77)
        self.assertLess(elapsed, 1.5)
        self.assertEqual(audit['stop_reason'], 'account_warning')

    def test_uncooperative_child_is_killed(self):
        code, audit, elapsed = self.stop_running_fake('ignore_term')
        self.assertEqual(code, 77)
        self.assertLess(elapsed, 4)
        self.assertEqual(audit['cli_exit_code'], -9)

    def test_internal_timeout_kills_child_without_global_stop(self):
        result, audit = self.run_fake('ignore_term', timeout=0.2)
        self.assertEqual(result.returncode, 124)
        self.assertEqual(audit['cli_exit_code'], -9)
        self.assertTrue(audit['timed_out'])
        self.assertIn('cli_timeout', audit['validation_errors'])
        self.assertFalse((self.root / '_STOP.json').exists())

    def test_existing_stop_prevents_spawn(self):
        (self.root / '_STOP.json').write_text(json.dumps({'reason': 'provider_warning', 'action': 'stop'}))
        result, audit = self.run_fake('valid')
        self.assertEqual(result.returncode, 77)
        self.assertIsNone(audit['cli_exit_code'])
        self.assertFalse(self.answer.exists())

    def test_rate_pause_cannot_overwrite_account_stop(self):
        path = self.root / '_STOP.json'
        CAPTURE.publish_stop(path, {'reason': 'account_warning', 'action': 'stop'})
        result = CAPTURE.publish_stop(path, {'reason': 'usage_or_rate_limit', 'action': 'pause'})
        self.assertEqual(result['action'], 'stop')

    def test_relative_and_absolute_resets_and_provider_warning(self):
        self.assertEqual(CAPTURE.reset_metadata('retry after 2 minutes', 100)['resume_at_unix'], 220)
        self.assertEqual(CAPTURE.reset_metadata('retry in 1 hour 20 minutes', 100)['resume_at_unix'], 4900)
        self.assertEqual(CAPTURE.reset_metadata('resets at 2030-01-01T00:00:00Z', 100)['resume_at_unix'], 1893456000)
        self.assertEqual(CAPTURE.classify_operational('Provider warning: service restriction')['reason'], 'provider_warning')


if __name__ == '__main__':
    unittest.main()
