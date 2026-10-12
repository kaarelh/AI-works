"""Controller tests with synthetic metadata, mocked runners and mocked publication."""
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


SOURCE = Path(__file__).with_name('_run_study.py')
SPEC = importlib.util.spec_from_file_location('study_controller', SOURCE)
STUDY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(STUDY)


class Clock:
    def __init__(self):
        self.now = 100.0
        self.waits = []

    def time(self):
        return self.now

    def sleep(self, seconds):
        self.waits.append(seconds)
        self.now += seconds


class FakeController(STUDY.StudyController):
    def __init__(self, root, clock=None):
        self.test_clock = clock or Clock()
        super().__init__(root, clock=self.test_clock.time, sleeper=self.test_clock.sleep)
        self.scripted = {}
        self.invoked = []
        self.published = []
        self.messages = []

    def progress(self, **fields):
        self.messages.append(fields)

    def checkpoint(self, status):
        self.save_state(status)
        self.published.append((status, len(self.invoked), self.calls()))

    def checked(self, command, label):
        raise AssertionError('Tests must not invoke Git, credential checks or other subprocesses.')

    def invoke(self, name, model, display):
        self.invoked.append((name, model, self.test_clock.time()))
        self.assert_unpaused()
        outcomes = self.scripted.get((name, model), [])
        outcome = outcomes.pop(0) if outcomes else {'code': 0, 'save': True}
        missing = [job_id for job_id in self.job_ids[name]
                   if not (self.root / model / (job_id + '.json')).exists()]
        reserved = min(len(missing), STUDY.CAP - self.calls())
        STUDY.atomic_json(self.root / '_ledger.json', {'calls': self.calls() + reserved})
        if outcome.get('save'):
            for job_id in missing[:min(reserved, outcome.get('save_count', reserved))]:
                directory = self.root / model
                directory.mkdir(exist_ok=True)
                STUDY.atomic_json(directory / (job_id + '.json'),
                                  {'result': '' if outcome.get('api_block') else 'Synthetic transport fixture',
                                   'refused_by_api': bool(outcome.get('api_block'))})
        if outcome.get('marker'):
            STUDY.atomic_json(self.stop_path, outcome['marker'])
        return outcome['code']

    def assert_unpaused(self):
        if self.read_stop():
            raise AssertionError('A model invocation started while shared STOP existed.')


class ControllerTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='_controller_test_', dir=SOURCE.parent)
        self.root = Path(self.temporary.name) / 'repo/purpose-sensitivity/astra_out'
        self.root.mkdir(parents=True)
        handoff = self.root.parent / 'handoff'
        handoff.mkdir()
        for name in ['s2_smoke', *STUDY.MAIN_FILES]:
            (handoff / (name + '.jsonl')).write_text(json.dumps({'id': name + '_0', 'block': 'synthetic'}) + '\n')
        (self.root / '_command.txt').write_text('synthetic-command {model} {out_file}\n')
        STUDY.atomic_json(self.root / '_ledger.json', {'calls': 0})
        self.controller = FakeController(self.root)

    def tearDown(self):
        self.temporary.cleanup()

    def test_file_outer_model_inner_and_rungs_last(self):
        ctl = self.controller
        self.assertEqual(ctl.run(), 0)
        expected = [(name, model) for name in ['s2_smoke', *STUDY.MAIN_FILES]
                    for model, _ in STUDY.MODELS]
        self.assertEqual([(name, model) for name, model, _ in ctl.invoked], expected)
        self.assertEqual(ctl.calls(), len(expected))
        self.assertGreaterEqual(len(ctl.published), len(expected))
        # Every next invocation has a prior publication for all preceding calls.
        self.assertEqual({n for _, n, _ in ctl.published}, set(range(len(expected) + 1)))

    def test_resume_skips_existing_complete_smoke(self):
        model = STUDY.MODELS[0][0]
        directory = self.root / model
        directory.mkdir()
        STUDY.atomic_json(directory / 's2_smoke_0.json', {'result': 'Synthetic fixture', 'refused_by_api': False})
        self.assertEqual(self.controller.run(), 0)
        self.assertEqual(self.controller.invoked[0][1], STUDY.MODELS[1][0])
        self.assertNotIn(('s2_smoke', model), [(name, slug) for name, slug, _ in self.controller.invoked])

    def test_zero_smoke_answers_after_two_invocations_skips_model(self):
        ctl = self.controller
        model = STUDY.MODELS[0][0]
        ctl.scripted[('s2_smoke', model)] = [{'code': 1}, {'code': 1}]
        self.assertEqual(ctl.run(), 0)
        self.assertEqual(ctl.state['model_status'][model], 'smoke_zero_answers')
        self.assertEqual([(name, slug) for name, slug, _ in ctl.invoked if slug == model],
                         [('s2_smoke', model), ('s2_smoke', model)])

    def test_api_blocks_do_not_count_as_smoke_answers(self):
        ctl = self.controller
        model = STUDY.MODELS[0][0]
        ctl.scripted[('s2_smoke', model)] = [{'code': 0, 'save': True, 'api_block': True}]
        self.assertEqual(ctl.run(), 0)
        self.assertEqual(ctl.state['model_status'][model], 'smoke_zero_answers')

    def test_individual_main_failure_gets_one_immediate_retry_then_later_repair(self):
        ctl = self.controller
        model = STUDY.MODELS[0][0]
        ctl.scripted[('s2_ctx4', model)] = [{'code': 1}, {'code': 1}, {'code': 0, 'save': True}]
        self.assertEqual(ctl.run(), 0)
        self.assertEqual(sum(name == 's2_ctx4' and slug == model for name, slug, _ in ctl.invoked), 3)
        self.assertEqual(ctl.pending('s2_ctx4', model), 0)
        self.assertTrue(ctl.state['main'][f's2_ctx4/{model}']['retry_complete'])
        self.assertEqual(ctl.state['repair'][f's2_ctx4/{model}']['invocations'], 1)
        self.assertEqual(ctl.invoked[-1][0], 's2_ctx1_rungs')

    def test_partial_smoke_retries_missing_jobs_once(self):
        ctl = self.controller
        model = STUDY.MODELS[0][0]
        ctl.job_ids['s2_smoke'].append('s2_smoke_1')
        ctl.scripted[('s2_smoke', model)] = [{'code': 1, 'save': True, 'save_count': 1}]
        self.assertEqual(ctl.run(), 0)
        self.assertEqual(sum(name == 's2_smoke' and slug == model for name, slug, _ in ctl.invoked), 2)
        self.assertEqual(ctl.pending('s2_smoke', model), 0)

    def test_recurring_failure_uses_repair_allowance_and_preserves_rung_budget(self):
        ctl = self.controller
        model = STUDY.MODELS[0][0]
        ctl.scripted[('s2_ctx4', model)] = [{'code': 1}] * 20
        with patch.object(STUDY, 'CAP', 40):
            self.assertEqual(ctl.run(), 0)
        self.assertEqual(ctl.calls(), 40)
        self.assertEqual(ctl.pending('s2_ctx4', model), 1)
        self.assertEqual([name for name, _, _ in ctl.invoked[-4:]], ['s2_ctx1_rungs'] * 4)
        self.assertGreater(ctl.state['repair'][f's2_ctx4/{model}']['invocations'], 0)

    def test_unexpected_guarded_exit_stops_safely(self):
        ctl = self.controller
        model = STUDY.MODELS[0][0]
        ctl.scripted[('s2_smoke', model)] = [{'code': 3}]
        with self.assertRaises(STUDY.ControllerError):
            ctl.run()
        self.assertEqual(len(ctl.invoked), 1)

    def test_retry_reserves_initial_attempt_budget_for_later_files(self):
        ctl = self.controller
        for model, _ in STUDY.MODELS:
            ctl.state['model_status'][model] = 'eligible'
            (self.root / model).mkdir()
            STUDY.atomic_json(self.root / model / 's2_smoke_0.json',
                              {'result': 'Synthetic fixture', 'refused_by_api': False})
            for name in STUDY.MAIN_FILES:
                ctl.state['main'][f'{name}/{model}'] = {'primary_complete': True, 'finished': True}
        first, second = [model for model, _ in STUDY.MODELS[:2]]
        for model in (first, second):
            ctl.state['main'][f's2_ctx4/{model}'] = {}
        STUDY.atomic_json(self.root / '_ledger.json', {'calls': STUDY.CAP - 2})
        ctl.scripted[('s2_ctx4', first)] = [{'code': 1}]
        self.assertEqual(ctl.run(), 0)
        self.assertEqual([(name, model) for name, model, _ in ctl.invoked], [('s2_ctx4', first), ('s2_ctx4', second)])
        self.assertEqual(ctl.calls(), STUDY.CAP)
        self.assertEqual(ctl.state['main'][f's2_ctx4/{first}']['retry_skipped'], 'initial_attempt_budget_reserved')

    def test_global_warning_stops_before_other_models_or_rungs(self):
        ctl = self.controller
        model = STUDY.MODELS[0][0]
        ctl.scripted[('s2_smoke', model)] = [
            {'code': 77, 'marker': {'action': 'stop', 'reason': 'human_auth_required'}}]
        self.assertEqual(ctl.run(), 77)
        self.assertEqual(len(ctl.invoked), 1)
        self.assertTrue(ctl.stop_path.exists())
        self.assertEqual(ctl.published[-1][1], 1)

    def test_pause_waits_for_explicit_reset_without_new_reservations(self):
        ctl = self.controller
        model = STUDY.MODELS[0][0]
        ctl.scripted[('s2_smoke', model)] = [
            {'code': 75, 'marker': {'action': 'pause', 'reason': 'usage_or_rate_limit', 'resume_at_unix': 165}}]
        self.assertEqual(ctl.run(), 0)
        self.assertEqual(ctl.test_clock.waits, [30, 30, 5])
        self.assertEqual(ctl.invoked[0][2], 100)
        self.assertEqual(ctl.invoked[1][2], 165)
        self.assertFalse(ctl.stop_path.exists())
        self.assertEqual(ctl.state['smoke'][model]['completed_invocations'], 1)
        self.assertTrue(any(n == 1 for _, n, _ in ctl.published))

    def test_unknown_reset_blocks_without_clearing_marker(self):
        ctl = self.controller
        model = STUDY.MODELS[0][0]
        ctl.scripted[('s2_smoke', model)] = [
            {'code': 75, 'marker': {'action': 'pause', 'reason': 'usage_or_rate_limit'}}]
        self.assertEqual(ctl.run(), 75)
        self.assertEqual(len(ctl.invoked), 1)
        self.assertFalse(ctl.test_clock.waits)
        self.assertTrue(ctl.stop_path.exists())

    def test_existing_stop_or_cap_starts_no_calls(self):
        ctl = self.controller
        STUDY.atomic_json(ctl.stop_path, {'action': 'stop', 'reason': 'provider_warning'})
        self.assertEqual(ctl.run(), 77)
        self.assertEqual(ctl.invoked, [])
        ctl.stop_path.unlink()
        STUDY.atomic_json(self.root / '_ledger.json', {'calls': STUDY.CAP})
        self.assertEqual(ctl.run(), 2)
        self.assertEqual(ctl.invoked, [])

    def test_completed_controller_resume_makes_no_more_calls(self):
        self.assertEqual(self.controller.run(), 0)
        calls = self.controller.calls()
        resumed = FakeController(self.root)
        self.assertEqual(resumed.run(), 0)
        self.assertEqual(resumed.invoked, [])
        self.assertEqual(resumed.calls(), calls)

    def test_guarded_command_preserves_constraints(self):
        model, display = STUDY.MODELS[0]
        cmd = self.controller.runner_command('s2_ctx4', model, display)
        self.assertEqual(cmd[1], '-B')
        self.assertTrue(cmd[2].endswith('_run_guarded.py'))
        for flag, value in [('--workers', '2'), ('--retries', '1'), ('--max-calls', '2600'),
                            ('--reasoning-effort', 'default'), ('--cmd-stdin', 'prompt')]:
            self.assertEqual(cmd[cmd.index(flag) + 1], value)
        self.assertIn('--ordered', cmd)
        self.assertNotIn('--max-output-tokens', cmd)
        self.assertNotIn('--provider', cmd)

    def test_publication_failure_prevents_further_calls(self):
        def fail(_):
            raise STUDY.ControllerError('Synthetic publication failure')
        self.controller.checkpoint = fail
        with self.assertRaises(STUDY.ControllerError):
            self.controller.run()
        self.assertEqual(self.controller.invoked, [])

    def test_git_whitespace_checks_preserve_raw_evidence_but_reject_authored_errors(self):
        ctl = self.controller

        def git(*args):
            return subprocess.run(['git', *args], cwd=ctl.repo, capture_output=True)

        self.assertEqual(git('init', '--quiet').returncode, 0)
        self.assertEqual(git('config', 'core.whitespace', 'blank-at-eof,blank-at-eol').returncode, 0)
        raw = self.root / '_events/synthetic/fixture.stderr.log'
        raw.parent.mkdir(parents=True)
        original = b'Synthetic diagnostic\n\n'
        raw.write_bytes(original)
        # Even a text suffix under raw event/model directories stays untouched.
        nested = self.root / '_events/synthetic/raw.txt'
        nested.write_bytes(b'Synthetic raw text   \n')
        model_data = self.root / 'synthetic-model/fixture.json'
        model_data.parent.mkdir()
        model_data.write_bytes(b'{"synthetic": true}   \n')
        authored = self.root / '_authored.py'
        authored.write_bytes(b'synthetic = True\n')
        self.assertEqual(git('add', '-A', '--', 'purpose-sensitivity/astra_out').returncode, 0)
        # First prove this fixture reproduces the original all-staged failure.
        self.assertNotEqual(git('diff', '--cached', '--check').returncode, 0)
        self.assertEqual(subprocess.run(ctl.whitespace_check_command(staged=True),
                                       cwd=ctl.repo, capture_output=True).returncode, 0)
        self.assertEqual(raw.read_bytes(), original)
        authored.write_bytes(b'synthetic = True   \n')
        self.assertNotEqual(subprocess.run(ctl.whitespace_check_command(),
                                          cwd=ctl.repo, capture_output=True).returncode, 0)
        self.assertEqual(git('add', '--', str(authored.relative_to(ctl.repo))).returncode, 0)
        self.assertNotEqual(subprocess.run(ctl.whitespace_check_command(staged=True),
                                          cwd=ctl.repo, capture_output=True).returncode, 0)
        self.assertEqual(raw.read_bytes(), original)

    def test_whitespace_scope_does_not_narrow_credential_guard_or_staging(self):
        ctl = self.controller
        checked = []

        def record_command(command, label):
            checked.append((command, label))
            return b'synthetic-branch\n' if label == 'Branch lookup' else b''

        ctl.checked = record_command
        # Mock publication completely: no credential read, commit or push.
        with patch.object(STUDY.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0)):
            STUDY.StudyController.checkpoint(ctl, 'Synthetic publication fixture')
        guard = [command for command, label in checked if label == 'Credential publication check']
        self.assertEqual(guard, [[STUDY.sys.executable, '-B', str(self.root / '_check_publish.py')]])
        staging = [command for command, label in checked if label == 'Scoped staging'][0]
        self.assertIn('purpose-sensitivity/astra_out', staging)
        self.assertFalse(any('_events' in item or 'synthetic-model' in item for item in staging))
        self.assertIn((ctl.whitespace_check_command(staged=True), 'Staged authored-file diff verification'), checked)


if __name__ == '__main__':
    unittest.main()
