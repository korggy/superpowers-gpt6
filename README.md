# Superpowers GPT-6

A Codex-focused variant of [Superpowers](https://github.com/obra/superpowers), specialized for GPT-6 Astra. Based on upstream 6.3.0 at `b36e082`; see [NOTICE.md](NOTICE.md) and [LICENSE](LICENSE) for attribution.

The 14 skills retain root-cause debugging, meaningful regression checks, scoped reviews, and recovery records. They share one policy for scope, authorization, verification evidence, and completion. Routine authorized work proceeds without repeated design approvals; explicit audit-only, plan-only, and approval checkpoints remain binding.

## Install from a ZIP

Start with [INSTALL.md](INSTALL.md) for extraction, personal installation, verification, and updates. It includes a request you can paste into Codex to perform the setup. ZIP recipients do not need the source repository or the build commands below.

## Workflows

Start with a relevant skill rather than loading the entire suite:

- Design decisions: brainstorming; durable handoffs: writing-plans.
- Execution: executing-plans; substantial independent work: subagent-driven-development or dispatching-parallel-agents.
- Diagnosis and regression protection: systematic-debugging and test-driven-development.
- Evidence and review: verification-before-completion, requesting-code-review, receiving-code-review.
- Requested isolation and integration: using-git-worktrees and finishing-a-development-branch.
- Suite routing and authoring: using-superpowers and writing-skills.

[Shared policy](skills/using-superpowers/references/workflow-policy.md) defines authorization and evidence reuse.
[Codex adapter](skills/using-superpowers/references/codex-tools.md) uses the live tool schema and preserves the user's workspace.
The plugin does not select the top-level model: choose GPT-6 Astra in Codex. Workers inherit settings unless a supported routing policy justifies overrides.

## Packaging (for maintainers)

Build dependencies are Python 3.10+, Git, and PyYAML. Install the declared dependency with `python -m pip install -r requirements-dev.txt`. The installed skills do not require PyYAML.
Skill metadata is maintained in this repository. No previous official package is required.

```text
python scripts/package_codex_plugin.py --output ../superpowers-gpt6.zip
```

Default packaging reads committed HEAD and rejects a dirty checkout. After local edits, explicitly preview the working tree with:

```text
python scripts/package_codex_plugin.py --working-tree --output ../superpowers-gpt6-preview.zip
```

Use `--ref REVISION` for a committed version and `--allow-dirty` only to package that committed ref despite unrelated working-tree changes. Output must be outside the checkout and must not already exist unless `--overwrite` is explicit. ZIP and tar.gz are supported.

The archive contains the Codex manifest, assets, maintained skills, README, license, attribution, and an explicit inventory in `packaging/codex-files.json`. New source files do not ship unless added to that list. Every selected Markdown document, YAML metadata file, and declared resource is validated before packaging. It excludes source-only hooks, tests, historical docs, and other harness integrations. Source `hooks: {}` suppresses inherited Claude hook discovery in repository installs; the archive omits that source-only setting because it contains no hooks.

The repository marketplace identifies the fork as `superpowers-gpt6`. Packaging does not install, publish, or alter account configuration. Avoid enabling upstream and fork workflows together for the same task. Confirm discovery in a new Codex session after any separately authorized installation.

## Validation and status

```text
python scripts/validate_gpt6.py
python scripts/validate_gpt6.py --archive ../superpowers-gpt6-preview.zip
python -m unittest discover -s tests/codex -p "test_*.py"
```

In the source checkout, see `docs/testing.md`, `tests/gpt6/scenarios.json`, `docs/gpt6-evaluation-results.md`, and `docs/gpt6-specialization.md`. These development records are excluded from the portable archive.
Behavioral smoke probes and static validation are distinct from installed-plugin activation and performance benchmarks. No general performance improvement is claimed.

Legacy harness integrations and historical design documents remain in the source tree for provenance; only Codex is targeted by this fork's package. Upstream contribution guidance is archived in `docs/upstream/CONTRIBUTING.md` in the source checkout.

## Guidance

- [GPT-6 Astra prompting best practices](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6-astra#prompting-best-practices)
- [Rethinking skills and prompts for GPT-6 Astra](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra)

Upstream's optional visual companion remains available. Its upstream branding request can be disabled using `SUPERPOWERS_DISABLE_TELEMETRY=1`; see its guide before use.
