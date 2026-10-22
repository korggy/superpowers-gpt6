import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const read = (p) => JSON.parse(fs.readFileSync(p, 'utf8').replace(/^\uFEFF/, ''));
const manifest = read(path.join(root, '.codex-plugin/plugin.json'));
test('renamed manifests agree and Codex assets resolve inside plugin root', () => {
  for (const dir of ['.codex-plugin','.claude-plugin','.cursor-plugin','.devin-plugin','.kimi-plugin','.antigravity-plugin','.muse-plugin']) {
    const m = read(path.join(root,dir,'plugin.json'));
    assert.equal(m.name,'superpowers-gpt6',dir);
    assert.equal(m.version,manifest.version,dir);
  }
  assert.equal(manifest.version,'7.0.1-gpt6.1');
  assert.deepEqual(manifest.hooks,{});
  assert.equal(manifest.interface.displayName,'Superpowers GPT-6 — BetterGood');
  for (const rel of [manifest.skills,manifest.interface.logo,manifest.interface.composerIcon]) {
    const full = path.resolve(root,rel);
    assert.ok(full.startsWith(root + path.sep));
    assert.ok(fs.existsSync(full),rel);
  }
});
test('all fifteen skill frontmatters map to their actual directory names', () => {
  const skills=fs.readdirSync(path.join(root,'skills')).filter(n=>fs.existsSync(path.join(root,'skills',n,'SKILL.md')));
  assert.equal(skills.length,15);
  for(const name of skills) {
    const s=fs.readFileSync(path.join(root,'skills',name,'SKILL.md'),'utf8');
    assert.match(s,new RegExp(`^---\\r?\\nname: ${name}\\r?\\n`));
    assert.ok(Buffer.byteLength(s)<20000,`${name} exceeds upstream compaction budget`);
  }
});

const marketRoot=process.env.GPT6_TEST_MARKETPLACE;
test('built catalog, payload hashes and provenance agree', {skip:!marketRoot}, () => {
  const catalog=read(path.join(marketRoot,'.agents/plugins/marketplace.json'));
  assert.equal(catalog.name,'bettergood');
  assert.equal(catalog.plugins.length,1);
  assert.deepEqual(catalog.plugins[0].source,{source:'local',path:'./plugins/superpowers-gpt6'});
  assert.equal(catalog.plugins[0].name,'superpowers-gpt6');
  assert.equal(catalog.plugins[0].pluginId,undefined);
  const pluginRoot=path.resolve(marketRoot,catalog.plugins[0].source.path);
  const provenance=read(path.join(pluginRoot,'PROVENANCE.json'));
  assert.equal(provenance.candidate.kind,'uncommitted-working-tree');
  assert.equal(provenance.version,manifest.version);
  assert.ok(provenance.candidate.sourceFiles.length>0);
  for(const row of provenance.packagedFiles) {
    const resolved=path.resolve(pluginRoot,row.path);
    assert.ok(resolved.startsWith(pluginRoot+path.sep),row.path);
    const digest=createHash('sha256').update(fs.readFileSync(resolved)).digest('hex');
    assert.equal(digest,row.sha256,row.path);
    assert.doesNotMatch(row.path,/(^|\/)(\.git|node_modules|\.superpowers|auth\.json|config\.toml|marketplace\.json)(\/|$)/);
  }
  assert.deepEqual(read(path.join(pluginRoot,'.codex-plugin/plugin.json')),manifest);
});
