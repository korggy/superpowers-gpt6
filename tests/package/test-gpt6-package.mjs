import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../..', import.meta.url));
const read = (filename) => JSON.parse(fs.readFileSync(filename, 'utf8'));
const hash = (filename) => createHash('sha256').update(fs.readFileSync(filename)).digest('hex');
const manifest = read(path.join(root, '.codex-plugin/plugin.json'));
const version = '7.0.2-gpt6.1';
const catalogPath = '.agents/plugins/marketplace.json';

function checkCatalog(directory, expectedPath) {
  const catalog = read(path.join(directory, catalogPath));
  assert.equal(catalog.name, 'bettergood');
  assert.equal(catalog.interface.displayName, 'BetterGood');
  assert.equal(catalog.plugins.length, 1);
  const [entry] = catalog.plugins;
  assert.equal(entry.name, 'superpowers-gpt6');
  assert.equal(entry.category, 'Developer Tools');
  assert.equal(Object.hasOwn(entry, 'pluginId'), false);
  assert.deepEqual(entry.source, {source: 'local', path: expectedPath});
  const plugin = path.resolve(directory, entry.source.path);
  assert.deepEqual(read(path.join(plugin, '.codex-plugin/plugin.json')), manifest);
  return plugin;
}

test('repository catalog resolves the BetterGood plugin with native skill discovery', () => {
  checkCatalog(root, './');
  assert.equal(manifest.name, 'superpowers-gpt6');
  assert.equal(manifest.version, version);
  assert.equal(manifest.skills, './skills/');
  assert.deepEqual(manifest.hooks, {});
  assert.equal(manifest.interface.displayName, 'Superpowers GPT-6 — BetterGood');
  for (const asset of [manifest.interface.logo, manifest.interface.composerIcon]) {
    assert.ok(fs.statSync(path.join(root, asset)).isFile(), asset);
  }
  const registry = read(path.join(root, '.version-bump.json'));
  assert.ok(registry.files.some(({path}) => path === '.hermes-plugin/plugin.yaml'));
  for (const entry of registry.files) {
    const file = path.join(root, entry.path);
    assert.equal(entry.field, 'version');
    if (file.endsWith('.yaml')) {
      const yaml = fs.readFileSync(file, 'utf8');
      assert.ok(yaml.split(/\r?\n/).includes('name: superpowers-gpt6'));
      assert.ok(yaml.split(/\r?\n/).includes('version: ' + version));
    } else {
      assert.equal(read(file).name, manifest.name, entry.path);
      assert.equal(read(file).version, version, entry.path);
    }
  }
});

test('all fifteen skill names match their directories', () => {
  const skills = fs.readdirSync(path.join(root, 'skills')).filter((name) =>
    fs.existsSync(path.join(root, 'skills', name, 'SKILL.md')));
  assert.equal(skills.length, 15);
  for (const name of skills) {
    const body = fs.readFileSync(path.join(root, 'skills', name, 'SKILL.md'), 'utf8');
    assert.match(body, new RegExp('^---\\r?\\nname: ' + name + '\\r?\\n'));
  }
});

function archiveHashes(filename) {
  // .NET is already available with the PowerShell build tool, including on Windows.
  const command = [
    '$ErrorActionPreference = "Stop"',
    '$archive = [IO.Compression.ZipFile]::OpenRead($env:GPT6_VERIFY_ARCHIVE)',
    'try {',
    '  $rows = foreach ($entry in $archive.Entries) {',
    '    $stream = $entry.Open()',
    '    try { [ordered]@{path=$entry.FullName;sha256=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($stream)).ToLowerInvariant()} }',
    '    finally { $stream.Dispose() }',
    '  }',
    '  ConvertTo-Json -InputObject @($rows) -Compress',
    '} finally { $archive.Dispose() }',
  ].join('\n');
  const rows = JSON.parse(execFileSync('pwsh', ['-NoProfile', '-NonInteractive', '-Command', command], {
    encoding: 'utf8', env: {...process.env, GPT6_VERIFY_ARCHIVE: filename},
  }));
  const hashes = Object.fromEntries(rows.map(({path, sha256}) => [path, sha256]));
  assert.equal(Object.keys(hashes).length, rows.length, 'duplicate ZIP entries');
  return hashes;
}

const marketplace = process.env.GPT6_TEST_MARKETPLACE;
test('generated catalog, complete ZIP entries, source and archive digests agree', {skip: !marketplace}, () => {
  const plugin = checkCatalog(marketplace, './plugins/superpowers-gpt6');
  const record = read(path.join(plugin, 'PROVENANCE.json'));
  assert.equal(record.upstreamRevision, '22f0b463e7a5e579904dd6211a520321035526f7');
  assert.equal(record.priorCustomization, 'a202a7e8dbeed17bf650d262cae661822b67a4d8');
  assert.equal(record.priorCatalogFix, '822d51227aab80d68d102ed0cf25cb178732b6a1');
  assert.match(record.candidate.baseRevision, /^[a-f0-9]{40}$/);
  assert.equal(record.candidate.kind, 'working-tree');
  assert.equal(record.version, version);
  const source = {};
  for (const row of record.candidate.sourceFiles) {
    assert.equal(hash(path.join(root, row.path)), row.sha256, row.path);
    source[row.path] = row.sha256;
  }
  const expected = {};
  for (const row of record.packagedFiles) {
    assert.ok(path.resolve(plugin, row.path).startsWith(plugin + path.sep), row.path);
    assert.doesNotMatch(row.path, /(^|\/)(?:\.git|\.codex|\.superpowers|\.agents|auth\.json|config\.toml|credentials|\.env(?:\..+)?|tests|dist|node_modules|__pycache__|marketplace\.json)(?:\/|$)/i);
    assert.equal(hash(path.join(plugin, row.path)), row.sha256, row.path);
    assert.equal(source[row.path], row.sha256, row.path);
    expected[row.path] = row.sha256;
  }
  assert.equal(Object.keys(expected).length, record.packagedFiles.length);
  for (const runtime of ['index.js', 'skills/subagent-driven-development/scripts/sdd-repo',
    'skills/subagent-driven-development/scripts/sdd-repo.ps1', 'hooks/session-start', 'LICENSE']) {
    assert.ok(expected[runtime], runtime);
  }
  for (const name of fs.readdirSync(path.join(root, 'skills'))) {
    assert.ok(expected['skills/' + name + '/SKILL.md'], name);
  }
  expected['PROVENANCE.json'] = hash(path.join(plugin, 'PROVENANCE.json'));
  const dist = path.dirname(path.resolve(marketplace));
  const pluginZip = manifest.name + '-' + version + '.zip';
  const marketZip = 'bettergood-marketplace-' + version + '.zip';
  assert.deepEqual(archiveHashes(path.join(dist, pluginZip)), expected);
  const marketExpected = {[catalogPath]: hash(path.join(marketplace, catalogPath))};
  for (const [name, digest] of Object.entries(expected)) marketExpected['plugins/superpowers-gpt6/' + name] = digest;
  assert.deepEqual(archiveHashes(path.join(dist, marketZip)), marketExpected);
  const sums = fs.readFileSync(path.join(dist, 'SHA256SUMS.txt'), 'utf8').trim().split(/\r?\n/);
  assert.deepEqual(sums.sort(), [pluginZip, marketZip].map((name) => hash(path.join(dist, name)) + '  ' + name).sort());
});
