"""Synthetic supervision tests: no study inputs, model calls, or credentials."""
import contextlib
import io
import json
from pathlib import Path
import tempfile
import threading
from types import SimpleNamespace
import unittest
from unittest import mock

from _run_guarded import ROOT, StopGuard, load_module


class GuardTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='astra_guard_test_')
        self.root = Path(self.temporary.name)
        self.stop = self.root / '_STOP.json'
        self.runner = load_module('synthetic_runner', ROOT.parent / 'handoff/astra_runner.py')
        self.capture = load_module('synthetic_capture', ROOT / '_capture_cli.py')
        self.guard = StopGuard(self.runner, self.capture, self.stop)
        self.args = SimpleNamespace(model='synthetic-model', max_calls=2600, max_cost=None,
                                    price_in=None, price_out=None, identity=None, summary=False,
                                    retries=1, backend='synthetic', provider='synthetic',
                                    reasoning_effort='default', max_output_tokens=None,
                                    git_commit='synthetic', jobs_sha256='synthetic')
        self.ledger = self.runner.Ledger(str(self.root / '_ledger.json'), self.args)
        self.outdir = self.root / 'synthetic-model'
        self.outdir.mkdir()
        self.runner.BACKENDS['synthetic'] = lambda *args: {'result': 'Synthetic answer.'}

    def tearDown(self):
        self.temporary.cleanup()

    def publish_stop(self, action='stop'):
        self.capture.publish_stop(self.stop, {'action': action, 'reason': 'synthetic_operational_stop'})

    def job(self, name):
        return {'id': name, 'system': 'Synthetic system.', 'prompt': 'Synthetic input.'}

    def test_stop_rejects_reservation_without_changing_count(self):
        self.assertTrue(self.ledger.reserve('synthetic-model'))
        before = (self.root / '_ledger.json').read_bytes()
        self.publish_stop()
        with self.assertRaises(self.guard.OperationalStop):
            self.ledger.reserve('synthetic-model')
        self.assertEqual((self.root / '_ledger.json').read_bytes(), before)

    def test_queued_job_after_stop_has_no_reservation_or_backend_call(self):
        self.publish_stop()
        self.runner.BACKENDS['synthetic'] = lambda *args: self.fail('backend must not run')
        with self.assertRaises(self.guard.OperationalStop):
            self.runner.run_one(self.job('queued'), self.args, str(self.outdir), self.ledger)
        self.assertFalse((self.root / '_ledger.json').exists())

    def test_inflight_job_can_save_after_stop(self):
        started = threading.Event()
        finish = threading.Event()
        results = []

        def backend(*args):
            started.set()
            if not finish.wait(5):
                raise RuntimeError('synthetic test timed out')
            return {'result': 'Synthetic answer.'}

        self.runner.BACKENDS['synthetic'] = backend
        thread = threading.Thread(target=lambda: results.append(
            self.runner.run_one(self.job('inflight'), self.args, str(self.outdir), self.ledger)))
        thread.start()
        try:
            self.assertTrue(started.wait(3))
            self.publish_stop()
            with self.assertRaises(self.guard.OperationalStop):
                self.runner.run_one(self.job('queued'), self.args, str(self.outdir), self.ledger)
        finally:
            finish.set()
            thread.join(5)
        self.assertFalse(thread.is_alive())
        self.assertEqual(results, ['ok'])
        self.assertTrue((self.outdir / 'inflight.json').exists())
        ledger = json.loads((self.root / '_ledger.json').read_text())
        self.assertEqual(ledger['calls'], 1)
        self.assertEqual(ledger['by_model']['synthetic-model']['ok'], 1)

    def test_individual_failure_does_not_stop_later_job(self):
        def backend(job, *args):
            if job['id'] == 'failure':
                raise RuntimeError('Synthetic individual failure')
            return {'result': 'Synthetic answer.'}

        self.runner.BACKENDS['synthetic'] = backend
        self.assertEqual(self.runner.run_one(self.job('failure'), self.args, str(self.outdir), self.ledger), 'fail')
        self.assertEqual(self.runner.run_one(self.job('success'), self.args, str(self.outdir), self.ledger), 'ok')
        ledger = json.loads((self.root / '_ledger.json').read_text())
        self.assertEqual(ledger['calls'], 2)
        self.assertEqual(ledger['by_model']['synthetic-model']['error'], 1)
        self.assertEqual(ledger['by_model']['synthetic-model']['ok'], 1)
        self.assertFalse(self.stop.exists())

    def test_existing_result_skips_without_reading_or_reserving(self):
        (self.outdir / 'complete.json').write_text('Synthetic existing record; deliberately not JSON.')
        self.publish_stop()
        self.assertEqual(self.runner.run_one(self.job('complete'), self.args, str(self.outdir), self.ledger), 'skip')
        self.assertFalse((self.root / '_ledger.json').exists())

    def test_cap_is_still_enforced(self):
        self.args.max_calls = 1
        self.assertTrue(self.ledger.reserve('synthetic-model'))
        self.assertFalse(self.ledger.reserve('synthetic-model'))
        self.assertEqual(self.ledger.calls(), 1)

    def test_pause_latches_and_summaries_do_not_misreport_cap(self):
        self.publish_stop('pause')
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.runner.print('CAP reached (--max-calls 2600)')
            self.runner.print('DONE', 'synthetic-model', {'ok': 0})
        self.assertNotIn('CAP reached', output.getvalue())
        self.assertEqual(output.getvalue().count('STOPPED'), 2)
        self.assertEqual(self.guard.exit_code(1), 75)
        self.stop.unlink()
        with self.assertRaises(self.guard.OperationalStop):
            self.ledger.reserve('synthetic-model')

    def test_stop_upgrades_pause_and_exit_code(self):
        self.publish_stop('pause')
        self.assertEqual(self.guard.exit_code(1), 75)
        self.publish_stop('stop')
        self.assertEqual(self.guard.exit_code(1), 77)

    def test_bad_marker_fails_closed(self):
        self.stop.write_text('{')
        with self.assertRaises(self.guard.OperationalStop):
            self.ledger.reserve('synthetic-model')
        self.assertEqual(self.guard.exit_code(0), 77)

    def test_runner_drains_queued_work_and_saves_inflight_result(self):
        jobs = self.root / 'synthetic-jobs.jsonl'
        jobs.write_text(''.join(json.dumps(self.job(f'synthetic-{n}')) + '\n' for n in range(6)))

        def backend(*args):
            self.publish_stop('pause')
            return {'result': 'Synthetic answer.'}

        self.runner.BACKENDS['synthetic'] = backend
        args = ['synthetic-runner', str(jobs), str(self.root), '--model', 'synthetic-model',
                '--backend', 'synthetic', '--workers', '1', '--retries', '1', '--max-calls', '2600',
                '--ordered']
        output = io.StringIO()
        with mock.patch('sys.argv', args), contextlib.redirect_stdout(output):
            code = self.guard.exit_code(self.runner.main())
        self.assertEqual(code, 75)
        ledger = json.loads((self.root / '_ledger.json').read_text())
        self.assertEqual(ledger['calls'], 1)
        self.assertEqual(ledger['by_model']['synthetic-model']['ok'], 1)
        self.assertEqual(len(list(self.outdir.glob('synthetic-*.json'))), 1)
        self.assertIn('STOPPED', output.getvalue())
        self.assertNotIn('CAP reached', output.getvalue())


if __name__ == '__main__':
    unittest.main()
