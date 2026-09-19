import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const root = fileURLToPath(new URL('../../', import.meta.url));
const read = (name) => readFileSync(path.join(root, name), 'utf8');
const bash = process.env.TEST_BASH ?? (process.platform === 'win32'
  ? 'C:/Program Files/Git/bin/bash.exe' : 'bash');
const bashEnv = process.platform === 'win32' ? {
  ...process.env,
  PATH: `${path.dirname(bash)};${path.resolve(path.dirname(bash), '../usr/bin')};${process.env.PATH}`,
} : process.env;
const fixtureDir = (name) => mkdtempSync(path.join(process.env.TEST_TMPDIR ?? tmpdir(), name));

test('every discoverable skill disables implicit invocation in Codex', () => {
  for (const entry of readdirSync(path.join(root, 'skills'), { withFileTypes: true })) {
    if (!entry.isDirectory() || !existsSync(path.join(root, 'skills', entry.name, 'SKILL.md'))) continue;
    assert.match(read(`skills/${entry.name}/agents/openai.yaml`),
      /policy:\s*\n\s+allow_implicit_invocation: false/, entry.name);
  }
});

test('Muse registers the source skill catalog without removed workflows', () => {
  const catalog = readdirSync(path.join(root, 'skills')).filter((name) =>
    existsSync(path.join(root, 'skills', name, 'SKILL.md'))).sort();
  const registered = JSON.parse(read('.muse-plugin/plugin.json')).capabilities.skills;
  assert.deepEqual(registered.map(({ id }) => id).sort(), catalog);
  for (const skill of registered) assert.ok(existsSync(path.join(root, skill.path)), skill.path);
  assert.ok(!catalog.includes('finishing-a-development-branch'));
});

test('Codex startup hook delivers an offer policy, not a workflow', () => {
  const manifest = JSON.parse(read('.codex-plugin/plugin.json'));
  assert.equal(manifest.hooks, './.codex-plugin/hooks.json');
  const hooks = JSON.parse(read(manifest.hooks));
  const entry = hooks.hooks.SessionStart[0];
  for (const source of ['startup', 'resume', 'clear', 'compact']) {
    assert.match(source, new RegExp(entry.matcher));
  }
  const result = spawnSync(entry.hooks[0].command, {
    encoding: 'utf8', shell: true,
    env: { ...process.env, PLUGIN_ROOT: root },
  });
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.hookSpecificOutput.hookEventName, 'SessionStart');
  assert.equal(payload.hookSpecificOutput.additionalContext,
    read('skills/using-superpowers/references/invocation-policy.md').trim());
  assert.doesNotMatch(result.stdout, /1% chance|ALREADY LOADED|Follow it now/);
});

test('Kimi and Gemini load only the workflow choice notice at startup', () => {
  const kimi = JSON.parse(read('.kimi-plugin/plugin.json'));
  assert.equal(kimi.sessionStart, undefined);
  assert.equal(kimi.systemPromptPath, './skills/using-superpowers/references/invocation-policy.md');
  assert.match(read(kimi.systemPromptPath), /opt-in on every harness/);
  assert.match(read('GEMINI.md'), /@\.\/skills\/using-superpowers\/references\/invocation-policy\.md/);
  assert.doesNotMatch(read('GEMINI.md'), /using-superpowers\/SKILL\.md/);
});

// Exercise the production staging block and sync function in isolation. The
// full archive/sync suites additionally require jq, zip, shasum, and rsync.
test('package staging preserves source policy and fills only legacy gaps', () => {
  const fixture = fixtureDir('superpowers-metadata-');
  try {
    const stage = path.join(fixture, 'payload');
    const legacy = path.join(fixture, 'legacy');
    const metadata = (base, skill) => path.join(base, 'skills', skill, 'agents/openai.yaml');
    for (const [base, skill, content] of [
      [stage, 'current', 'policy:\n  allow_implicit_invocation: false\n'],
      [legacy, 'current', 'policy:\n  allow_implicit_invocation: true\n'],
      [legacy, 'older', 'interface:\n  display_name: Legacy\n'],
    ]) {
      mkdirSync(path.dirname(metadata(base, skill)), { recursive: true });
      writeFileSync(metadata(base, skill), content);
    }
    mkdirSync(path.join(stage, 'skills/older'), { recursive: true });
    const block = read('scripts/package-codex-plugin.sh').match(/missing_metadata=0[\s\S]*?(?=skill_count=)/)?.[0];
    assert.ok(block, 'production staging block');
    const run = () => spawnSync(bash, ['-s', '--', stage, legacy], {
      encoding: 'utf8', env: bashEnv,
      input: 'set -euo pipefail\nSTAGE=$1\nMETADATA_ROOT=$2\ndie() { echo "$*" >&2; exit 1; }\n' + block,
    });
    assert.equal(run().status, 0);
    assert.match(readFileSync(metadata(stage, 'current'), 'utf8'), /allow_implicit_invocation: false/);
    assert.equal(readFileSync(metadata(stage, 'older'), 'utf8'), readFileSync(metadata(legacy, 'older'), 'utf8'));
    // With all source metadata present, no external metadata source is needed.
    rmSync(legacy, { recursive: true });
    assert.equal(run().status, 0);
    mkdirSync(path.join(stage, 'skills/missing'), { recursive: true });
    const missing = run();
    assert.equal(missing.status, 1);
    assert.match(missing.stderr, /Missing OpenAI agent metadata for skill: missing/);
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});

test('sync preserves source policy and legacy metadata only for surviving skills', () => {
  const fixture = fixtureDir('superpowers-sync-metadata-');
  try {
    const source = path.join(fixture, 'source');
    const destination = path.join(fixture, 'destination');
    const rel = 'skills/current/agents/openai.yaml';
    for (const base of [source, destination]) mkdirSync(path.dirname(path.join(base, rel)), { recursive: true });
    writeFileSync(path.join(source, rel), 'policy:\n  allow_implicit_invocation: false\n');
    writeFileSync(path.join(destination, rel), 'policy:\n  allow_implicit_invocation: true\n');
    writeFileSync(path.join(source, 'skills/current/SKILL.md'), '# Current\n');
    const oldRel = 'skills/older/agents/openai.yaml';
    mkdirSync(path.dirname(path.join(destination, oldRel)), { recursive: true });
    writeFileSync(path.join(destination, oldRel), 'legacy metadata\n');
    mkdirSync(path.join(source, 'skills/older'), { recursive: true });
    writeFileSync(path.join(source, 'skills/older/SKILL.md'), '# Older\n');
    const removedRel = 'skills/finishing-a-development-branch/agents/openai.yaml';
    mkdirSync(path.dirname(path.join(destination, removedRel)), { recursive: true });
    writeFileSync(path.join(destination, removedRel), 'removed skill metadata\n');
    const fn = read('scripts/sync-to-codex-plugin.sh').match(/copy_preserved_destination_metadata\(\) \{[\s\S]*?\n\}/)?.[0];
    assert.ok(fn, 'production metadata function');
    const result = spawnSync(bash, ['-s', '--', destination, source], {
      encoding: 'utf8', env: bashEnv,
      input: 'set -euo pipefail\n' + fn + '\ncopy_preserved_destination_metadata "$1" "$2"\n',
    });
    assert.equal(result.status, 0, result.stderr);
    assert.match(readFileSync(path.join(source, rel), 'utf8'), /allow_implicit_invocation: false/);
    assert.equal(readFileSync(path.join(source, oldRel), 'utf8'), 'legacy metadata\n');
    assert.ok(!existsSync(path.join(source, 'skills/finishing-a-development-branch')));
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});

test('Native helpers use Bash for child scripts without relying on their launcher', () => {
  const fixture = fixtureDir('superpowers-native-');
  const run = (command, args) => spawnSync(command, args, {
    cwd: fixture, encoding: 'utf8', timeout: 15000, maxBuffer: 128 * 1024,
    env: bashEnv,
  });
  try {
    cpSync(path.join(root, 'skills/executing-plans'), path.join(fixture, 'skills/executing-plans'), { recursive: true });
    cpSync(path.join(root, 'skills/subagent-driven-development'), path.join(fixture, 'skills/subagent-driven-development'), { recursive: true });
    // A missing launcher makes direct execution fail on Windows too, where
    // chmod -x may not be enforced. Explicit Bash must ignore the shebang.
    for (const name of ['task-brief', 'sdd-workspace']) {
      const script = path.join(fixture, 'skills/subagent-driven-development/scripts', name);
      writeFileSync(script, readFileSync(script, 'utf8').replace(/^#![^\n]*/, '#!/superpowers-missing-interpreter'));
    }
    for (const args of [['init', '-q'], ['config', 'user.name', 'Fixture'], ['config', 'user.email', 'fixture@example.invalid']]) {
      const result = run('git', args);
      assert.equal(result.status, 0, result.stderr);
    }
    writeFileSync(path.join(fixture, 'plan.md'), '# Plan\n\n## Task 1: First\n\nVerify the helper.\n');
    assert.equal(run('git', ['add', 'plan.md']).status, 0);
    const commit = run('git', ['-c', 'commit.gpgsign=false', 'commit', '-qm', 'fixture']);
    assert.equal(commit.status, 0, commit.stderr);
    const base = run('git', ['rev-parse', 'HEAD']).stdout.trim();
    const start = run(bash, ['skills/executing-plans/scripts/task-start', 'plan.md', '1']);
    assert.equal(start.status, 0, start.stderr);
    assert.match(start.stdout, /brief: .*task-1-brief.md/);
    const done = run(bash, ['skills/executing-plans/scripts/task-done', 'plan.md', '1', base, '--', 'bash', '-c', 'echo OK']);
    assert.equal(done.status, 0, done.stderr);
    assert.match(done.stdout, /Task 1: complete/);
    const failed = run(bash, ['skills/executing-plans/scripts/task-done', 'plan.md', '2', base, '--', 'bash', '-c', 'echo FAILED; exit 7']);
    assert.equal(failed.status, 7, failed.stderr);
    const ledger = readFileSync(path.join(fixture, '.superpowers/sdd/plan/progress.md'), 'utf8');
    assert.doesNotMatch(ledger, /Task 2: complete/);
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});
