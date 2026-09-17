"""Check evaluation isolation and failure classification without model calls."""
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
import subprocess

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
import evaluate_gpt6 as evaluation


class EvaluationTests(unittest.TestCase):
    def checkpoint_fixture(self, temp):
        cases = json.loads((ROOT / 'tests/gpt6/cli-scenarios.json').read_text(encoding='utf-8'))['cases']
        case = next(case for case in cases if case['id'] == 'checkpoint-recovery')
        fixture = Path(temp) / 'fixture'
        evaluation.prepare_fixture(case, fixture, {})
        return case, fixture, evaluation.snapshot(fixture)

    def test_checkpoint_rejects_unfinished_documentation_despite_passing_tests(self):
        with tempfile.TemporaryDirectory() as temp:
            case, fixture, before = self.checkpoint_fixture(temp)
            checks = evaluation.run_checks(case, fixture, before)
            self.assertTrue(checks['python_tests'])
            self.assertIn(False, checks.values())
            self.assertEqual(('execution_or_checks_failed', 1), evaluation.matrix_status([
                {'status': 'completed_needs_review', 'checks': checks}]))

    def test_checkpoint_accepts_documentation_and_progress_record_updates(self):
        with tempfile.TemporaryDirectory() as temp:
            case, fixture, before = self.checkpoint_fixture(temp)
            (fixture / 'README.md').write_text(case['checks']['exact_files']['README.md'], encoding='utf-8')
            (fixture / 'CHECKPOINT.md').write_text('Completed the approved documentation change.\n', encoding='utf-8')
            checks = evaluation.run_checks(case, fixture, before)
            self.assertTrue(checks['exact:README.md'])
            self.assertTrue(checks['only_requested_files_changed'])
            self.assertTrue(checks['python_tests'])

    def test_checkpoint_rejects_changes_to_completed_code_or_tests(self):
        for name in ('count.py', 'test_count.py'):
            for action in ('edit', 'delete'):
                with self.subTest(file=name, action=action), tempfile.TemporaryDirectory() as temp:
                    case, fixture, before = self.checkpoint_fixture(temp)
                    (fixture / 'README.md').write_text(case['checks']['exact_files']['README.md'], encoding='utf-8')
                    path = fixture / name
                    if action == 'edit':
                        path.write_text(path.read_text(encoding='utf-8') + '\n# Unrequested edit\n', encoding='utf-8')
                    else:
                        path.unlink()
                    checks = evaluation.run_checks(case, fixture, before)
                    self.assertFalse(checks['only_requested_files_changed'])
                    if action == 'edit':
                        self.assertTrue(checks['python_tests'])

    def test_checkpoint_rejects_unrelated_artifacts(self):
        with tempfile.TemporaryDirectory() as temp:
            case, fixture, before = self.checkpoint_fixture(temp)
            (fixture / 'README.md').write_text(case['checks']['exact_files']['README.md'], encoding='utf-8')
            (fixture / 'unrequested.txt').write_text('Unrelated artifact\n', encoding='utf-8')
            checks = evaluation.run_checks(case, fixture, before)
            self.assertFalse(checks['only_requested_files_changed'])
            self.assertTrue(checks['python_tests'])

    def test_authentication_failure_is_not_a_behavior_result(self):
        events = [{'type': 'turn.failed', 'error': {'message': '401 Unauthorized'}}]
        self.assertEqual('blocked_authentication', evaluation.classify(events, '', 1))

    def test_tls_failure_is_not_a_behavior_result(self):
        self.assertEqual('blocked_tls', evaluation.classify([], 'invalid peer certificate: UnknownIssuer', 1))

    def test_rejected_execution_is_not_a_behavior_result(self):
        events = [{'type': 'turn.completed'}]
        self.assertEqual('blocked_execution_policy', evaluation.classify(events, 'CreateProcess: rejected: blocked by policy', 0))

    def test_success_still_requires_human_review(self):
        self.assertEqual('completed_needs_review', evaluation.classify([{'type': 'turn.completed'}], '', 0))
        self.assertEqual('execution_failed', evaluation.classify([{'type': 'thread.started'}], '', 0))

    def test_fixed_session_configuration(self):
        args = evaluation.command(Path('codex.exe'), Path('fixture with spaces'), 'gpt-6-astra', 'low')
        self.assertIn('--ephemeral', args)
        self.assertIn('--ignore-user-config', args)
        self.assertEqual('gpt-6-astra', args[args.index('--model') + 1])
        self.assertEqual('fixture with spaces', args[args.index('--cd') + 1])
        self.assertEqual('-', args[-1])
        self.assertNotIn('--dangerously-bypass-approvals-and-sandbox', args)

    def test_windows_keeps_native_sandbox_when_user_config_is_ignored(self):
        with patch.object(evaluation.os, 'name', 'nt'):
            args = evaluation.command('codex.exe', 'fixture', 'gpt-6-astra', 'low')
        self.assertIn('windows.sandbox="elevated"', args)

    def test_verification_timeout_is_recorded(self):
        with tempfile.TemporaryDirectory() as temp:
            with patch.object(evaluation.subprocess, 'run', side_effect=subprocess.TimeoutExpired('tests', 30)):
                result = evaluation.run_checks({'checks': {'python_tests': True}}, Path(temp), {})
            self.assertFalse(result['python_tests'])
            self.assertIn('verification_error', result)

    def test_failed_trials_and_checks_fail_matrix(self):
        self.assertEqual(('execution_or_checks_failed', 1), evaluation.matrix_status([{'status': 'execution_failed'}]))
        self.assertEqual(('execution_or_checks_failed', 1), evaluation.matrix_status([{'status': 'completed_needs_review', 'checks': {'python_tests': False}}]))
        self.assertEqual(('needs_human_review', 0), evaluation.matrix_status([{'status': 'completed_needs_review', 'checks': {'unchanged': True}}]))

    def test_fixture_discovery_and_unchanged_checks(self):
        with tempfile.TemporaryDirectory() as temp:
            fixture = Path(temp) / 'fixture'
            case = {'files': {'README.md': 'Original\n'}, 'checks': {'unchanged': True}}
            evaluation.prepare_fixture(case, fixture, {'skills/example/SKILL.md': b'fixture skill'})
            self.assertTrue((fixture / '.git').is_dir())
            self.assertEqual(b'fixture skill', (fixture / '.agents/skills/example/SKILL.md').read_bytes())
            before = evaluation.snapshot(fixture)
            self.assertTrue(evaluation.run_checks(case, fixture, before)['unchanged'])
            (fixture / 'README.md').write_text('Modified\n', encoding='utf-8')
            self.assertFalse(evaluation.run_checks(case, fixture, before)['unchanged'])

    def test_fixture_rejects_path_escape(self):
        with tempfile.TemporaryDirectory() as temp:
            with self.assertRaises(ValueError):
                evaluation.prepare_fixture({'files': {'../outside.txt': 'no'}}, Path(temp) / 'fixture', {})
            self.assertFalse((Path(temp) / 'outside.txt').exists())


if __name__ == '__main__':
    unittest.main()
