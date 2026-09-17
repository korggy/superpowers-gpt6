#!/usr/bin/env python3
"""Prepare isolated Codex skill trials; --run explicitly enables model calls.

Raw traces stay outside the project. Automated checks never replace human review.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

from codex_contract import safe_path
from package_codex_plugin import git, read_git_archive, working_files

ROOT = Path(__file__).resolve().parents[1]
FEATURES = ('plugins', 'remote_plugin', 'apps', 'hooks', 'memories', 'skill_mcp_dependency_install')


def digest(data):
    return hashlib.sha256(data).hexdigest()


def snapshot(root):
    return {p.relative_to(root).as_posix(): digest(p.read_bytes()) for p in root.rglob('*')
            if p.is_file() and '.git' not in p.relative_to(root).parts and '__pycache__' not in p.parts}


def command(executable, fixture, model, effort):
    args = [str(executable), '-a', 'never', 'exec', '--ephemeral', '--ignore-user-config',
            '--model', model, '--sandbox', 'workspace-write', '--cd', str(fixture),
            '--json', '--color', 'never', '-c', f'model_reasoning_effort="{effort}"']
    if os.name == 'nt':
        # Ignoring user config also drops the native sandbox implementation.
        args.extend(('-c', 'windows.sandbox="elevated"'))
    for feature in FEATURES:
        args.extend(('--disable', feature))
    return args + ['-']


def classify(events, stderr, returncode):
    messages = '\n'.join(str(e.get('message', '')) + str(e.get('error', '')) for e in events)
    diagnostic = messages + stderr
    if '401' in diagnostic or 'Not logged in' in diagnostic:
        return 'blocked_authentication'
    if 'UnknownIssuer' in diagnostic or 'invalid peer certificate' in diagnostic:
        return 'blocked_tls'
    if 'CreateProcess' in stderr and 'blocked by policy' in stderr:
        return 'blocked_execution_policy'
    if any(e.get('type') == 'turn.completed' for e in events) and returncode == 0:
        return 'completed_needs_review'
    return 'execution_failed'


def invoke(executable, fixture, prompt, output, model, effort, timeout, ca_bundle=None):
    env = os.environ.copy()
    env['PYTHONDONTWRITEBYTECODE'] = '1'
    env['PATH'] = str(Path(sys.executable).parent) + os.pathsep + env.get('PATH', '')
    if ca_bundle:
        env['CODEX_CA_CERTIFICATE'] = str(Path(ca_bundle).resolve())
    args = command(executable, fixture, model, effort)
    start = time.monotonic()
    timed_out = False
    with (output / 'events.jsonl').open('w', encoding='utf-8') as out, (output / 'stderr.txt').open('w', encoding='utf-8') as err:
        try:
            result = subprocess.run(args, input=prompt, text=True, encoding='utf-8', stdout=out, stderr=err,
                                    env=env, timeout=timeout)
            code = result.returncode
        except subprocess.TimeoutExpired:
            timed_out, code = True, None
    elapsed = round(time.monotonic() - start, 3)
    events = []
    for line in (output / 'events.jsonl').read_text(encoding='utf-8').splitlines():
        try:
            events.append(json.loads(line))
        except ValueError:
            pass
    stderr = (output / 'stderr.txt').read_text(encoding='utf-8')
    status = classify(events, stderr, code)
    if timed_out and not status.startswith('blocked_'):
        status = 'timed_out'
    usage = next((e.get('usage') for e in reversed(events) if e.get('type') == 'turn.completed'), None)
    items = [e.get('item', {}) for e in events if e.get('type') == 'item.completed']
    final = '\n'.join(i.get('text', '') for i in items if i.get('type') == 'agent_message')
    (output / 'final.txt').write_text(final, encoding='utf-8')
    return {'status': status, 'returncode': code, 'elapsed_seconds': elapsed, 'usage': usage,
            'cost': None, 'requested_model': model, 'requested_effort': effort,
            'actual_model_snapshot': None,
            'command_items': sum(i.get('type') == 'command_execution' for i in items),
            'final': final}


def run_checks(case, fixture, before):
    checks = case.get('checks', {})
    results = {}
    after = snapshot(fixture)
    if checks.get('unchanged'):
        results['unchanged'] = after == before
    for name, expected in checks.get('exact_files', {}).items():
        path = fixture / name
        results[f'exact:{name}'] = path.is_file() and path.read_text(encoding='utf-8') == expected
    if checks.get('exact_files') or 'allowed_changed_files' in checks:
        allowed = set(checks.get('allowed_changed_files', checks.get('exact_files', {})))
        results['only_requested_files_changed'] = {n for n in before.keys() | after.keys() if before.get(n) != after.get(n)} <= allowed
    if checks.get('python_tests'):
        try:
            checked = subprocess.run([sys.executable, '-B', '-m', 'unittest', 'discover'], cwd=fixture,
                                     capture_output=True, text=True, timeout=30)
            results['python_tests'] = checked.returncode == 0
            results['test_output'] = checked.stdout + checked.stderr
        except (subprocess.TimeoutExpired, OSError) as error:
            results['python_tests'] = False
            results['verification_error'] = str(error)
    return results


def matrix_status(trials):
    if any(t['status'] != 'completed_needs_review' or any(v is False for v in t.get('checks', {}).values()) for t in trials):
        return 'execution_or_checks_failed', 1
    return 'needs_human_review', 0


def prepare_fixture(case, target, skills):
    target.mkdir(parents=True)
    subprocess.run(['git', 'init', '-q', str(target)], check=True, capture_output=True)
    for name, content in case['files'].items():
        safe_path(name)
        path = target / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding='utf-8', newline='\n')
    for name, data in skills.items():
        path = target / '.agents' / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
    if case.get('setup') == 'verified_checkpoint':
        checked = subprocess.run([sys.executable, '-B', '-m', 'unittest', 'discover'], cwd=target,
                                 capture_output=True, text=True, timeout=30)
        if checked.returncode:
            raise ValueError('checkpoint setup failed before model evaluation')
        evidence = {'command': [sys.executable, '-B', '-m', 'unittest', 'discover'], 'directory': str(target),
                    'python': sys.version, 'returncode': checked.returncode,
                    'files': {n: digest((target / n).read_bytes()) for n in case['files']},
                    'output': checked.stdout + checked.stderr}
        (target / 'CHECKPOINT.md').write_text('The approved cancellation fix is implemented. The following check just passed against the unchanged files. Finish review and report accurately.\n\n' + json.dumps(evidence, indent=2), encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--codex', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--baseline-ref', required=True)
    parser.add_argument('--cases', default='factual-negative,typo-negative,approved-fix,read-only-audit,valid-evidence-reuse,bounded-delegation,checkpoint-recovery')
    parser.add_argument('--arms', default='control,baseline,candidate')
    parser.add_argument('--model', default='gpt-6-astra')
    parser.add_argument('--effort', choices=('low', 'medium', 'high', 'xhigh', 'max', 'ultra'), default='low')
    parser.add_argument('--timeout', type=int, default=120)
    parser.add_argument('--ca-bundle', type=Path)
    parser.add_argument('--run', action='store_true', help='Run the prepared trials after successful inference preflight')
    args = parser.parse_args()
    output = args.output.resolve()
    if output.is_relative_to(ROOT) or output.exists():
        parser.error('--output must be a new directory outside the checkout')
    if not args.codex.is_file() or args.timeout < 1:
        parser.error('provide an existing Codex executable and a positive timeout')
    cases = json.loads((ROOT / 'tests/gpt6/cli-scenarios.json').read_text(encoding='utf-8'))['cases']
    selected = args.cases.split(',')
    if set(selected) - {c['id'] for c in cases}:
        parser.error('unknown case')
    arms = args.arms.split(',')
    if len(arms) != len(set(arms)) or set(arms) - {'control', 'baseline', 'candidate'}:
        parser.error('arms must be unique control, baseline, or candidate values')
    revision = git(ROOT, 'rev-parse', '--verify', '--end-of-options', args.baseline_ref + '^{commit}').decode().strip()
    baseline = read_git_archive(git(ROOT, 'archive', '--format=tar', revision, '--', 'skills'))
    candidate = {n: data for n, data in working_files(ROOT).items() if n.startswith('skills/')}
    guidance = {'control': {}, 'baseline': baseline, 'candidate': candidate}
    output.mkdir(parents=True)
    summary = {'cli_version': subprocess.check_output([str(args.codex), '--version'], text=True).strip(),
               'requested_model': args.model, 'requested_effort': args.effort, 'baseline_revision': revision,
               'candidate_files': {n: digest(data) for n, data in candidate.items()},
               'limitations': ['Repository-local discovery, not installed-plugin activation.',
                              'User/admin/system skills can remain ambient; control means no added workflow suite.',
                              'Checkpoint recovery is not an actual mid-turn steering or compaction test.',
                              'CLI JSONL may omit worker prompts/events; parent usage is not complete delegation telemetry.',
                              'Human scoring of skill selection, questions, boundaries, and delegation is required.'],
               'trials': []}
    for case in cases:
        if case['id'] not in selected:
            continue
        for arm in arms:
            trial = output / f"{case['id']}--{arm}"
            fixture = trial / 'fixture'
            prepare_fixture(case, fixture, guidance[arm])
            # The worker receives task and safety boundaries, never rubric/checks.
            prompt = case['request'] + '\nWork only in this fixture. Do not publish, commit, install dependencies, or change account configuration.'
            (trial / 'prompt.txt').write_text(prompt, encoding='utf-8')
            summary['trials'].append({'case': case['id'], 'arm': arm, 'path': str(trial), 'status': 'prepared',
                                      'before': snapshot(fixture), 'human_review': case['review']})
    result_path = output / 'summary.json'
    def save():
        result_path.write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
    save()
    if args.run:
        preflight = output / 'preflight'
        prepare_fixture({'files': {'README.md': 'Inference preflight.\n'}}, preflight / 'fixture', {})
        summary['preflight'] = invoke(args.codex, preflight / 'fixture',
            'Read README.md, then create ready.txt containing exactly 323 with no newline. '
            'Use workspace tools to do this. Work only in this fixture. Do not change configuration.',
            preflight, args.model, args.effort, min(args.timeout, 45), args.ca_bundle)
        if summary['preflight']['status'] == 'completed_needs_review':
            marker = preflight / 'fixture' / 'ready.txt'
            ready = marker.is_file() and marker.read_bytes() == b'323'
            summary['preflight']['workspace_write_verified'] = ready
            if not ready:
                summary['preflight']['status'] = 'blocked_workspace_preflight'
        summary['status'] = summary['preflight']['status']
        save()
        if summary['preflight']['status'] != 'completed_needs_review':
            print(json.dumps({'status': summary['preflight']['status'], 'summary': str(result_path)}))
            return 2
        lookup = {c['id']: c for c in cases}
        for trial in summary['trials']:
            folder = Path(trial['path'])
            result = invoke(args.codex, folder / 'fixture', (folder / 'prompt.txt').read_text(encoding='utf-8'), folder,
                            args.model, args.effort, args.timeout, args.ca_bundle)
            trial.update(result)
            save()
            if result['status'] == 'completed_needs_review':
                trial['checks'] = run_checks(lookup[trial['case']], folder / 'fixture', trial['before'])
                expected = lookup[trial['case']].get('checks', {}).get('answer_contains')
                if expected:
                    trial['checks']['answer_contains'] = expected in result['final']
            save()
            print(f"{trial['case']}/{trial['arm']}: {trial['status']}", flush=True)
            if result['status'].startswith('blocked_'):
                summary['status'] = result['status']
                save()
                return 2
    status, code = matrix_status(summary['trials']) if args.run else ('prepared', 0)
    summary['status'] = status
    save()
    print(json.dumps({'status': status, 'trials': len(summary['trials']), 'summary': str(result_path)}))
    return code


if __name__ == '__main__':
    raise SystemExit(main())
