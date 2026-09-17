# Testing Superpowers GPT-6

## Local checks

Python 3.10+, Git, and PyYAML are required. From the repository root:

```text
python -m pip install -r requirements-dev.txt
python scripts/validate_gpt6.py
python -m unittest discover -s tests/codex -p "test_*.py"
python scripts/package_codex_plugin.py --working-tree --output ../superpowers-gpt6-preview.zip
python scripts/validate_gpt6.py --archive ../superpowers-gpt6-preview.zip
```

The shared contract validator parses real YAML, rejects duplicate keys and malformed nesting/types, checks skill names and invocation metadata, and validates links in every packaged Markdown file. The explicit inventory declares additional script resources that Markdown links cannot express. Source mode also checks marketplace identity; `--archive` or `--extracted` checks the complete deployed payload, including unexpected files. It does not evaluate natural-language quality or replace the official plugin ingestion validator.

The packaging tests use isolated temporary fixtures. They cover self-contained archives, hook exclusion, executable modes, ZIP/tar reproducibility, committed-ref versus dirty preview behavior, malformed metadata/frontmatter, missing assets/resources, unselected legacy instructions, output safety, and unsafe archive paths/links. Fixtures create their own Git repositories; tests do not commit or clean the project checkout.

For additional official validation, run the installed `skill-creator/scripts/quick_validate.py` on each skill and `plugin-creator/scripts/validate_plugin.py` on an extracted preview archive. These tools require PyYAML. Use their actual local installation paths. The source-only `hooks: {}` override is intentionally absent from the portable archive, so validate the archive against the ingestion contract.

The Bash package entrypoint and its test entrypoint forward to Python for existing callers. On Windows prefer the direct Python commands. Git Bash can run `tests/codex/test-marketplace-manifest.sh` (with Python available as `python3`) and `tests/claude-code/test-sdd-workspace.sh` to check retained helper compatibility.

## Behavior evaluations

[scenarios.json](../tests/gpt6/scenarios.json) defines requests, fixtures, and observable acceptance criteria. [Results](gpt6-evaluation-results.md) separate executed probes from decision review and unexecuted release coverage.

For a controlled comparison:

1. Freeze the baseline skills and fixture before editing candidate instructions.
2. Create independent fixture copies for no-skill control, baseline, and candidate. Keep request, model, host, tools, permissions, and budget comparable.
3. Give the worker only its task, fixture, and assigned guidance. Keep the scoring criteria with the evaluator. Do not imply it is in a real user environment to pressure behavior.
4. Collect tool traces, final artifact/diff, checks, questions, stop reasons, and side effects. Score correctness and scope before process preferences.
5. Record model identifier/settings and token/latency/cost telemetry when available; mark unavailable fields instead of estimating them. Repeat trials before comparative claims.
6. Test top-level activation separately in a fresh session after an explicitly authorized install. Subagent instruction reads cannot validate discovery or startup behavior.

A control that succeeds is evidence against unnecessary instructions. A baseline that also succeeds does not demonstrate candidate improvement. Model failures, fixture failures, and host/tool availability failures need separate classification.

No fixed number of tests establishes general reliability. Extend coverage when a concrete behavior changes or a gap appears, and reuse still-valid evidence.

## Retained upstream tests

The existing `evals/` harness and other `tests/` directories are historical upstream coverage. Several assume other harnesses, old workflow ceremonies, remote sync destinations, or specific paid model access. They are not silently treated as a passing GPT-6 release suite. Run relevant compatible helper tests; migrate behavioral criteria before using historical instruction-compliance scores as quality evidence.

## Fresh-session CLI matrix

`scripts/evaluate_gpt6.py` prepares seven executable cases across no-added-suite control, committed baseline, and candidate: factual and typo negative triggers, approval persistence, read-only audit, valid evidence reuse, bounded delegation, and checkpoint recovery. Cases and evaluator-only criteria are in `tests/gpt6/cli-scenarios.json`. Workers receive only the request and consistent side-effect boundaries.

The recovery checkpoint specifies the approved README wording. Its automated checks require that text, passing existing tests, and changes confined to README.md and the optional checkpoint completion record. This also preserves the finished implementation and test files. Original file hashes remain in the run summary for later scope review. These deterministic checks complement the review of approval persistence and recovery behavior.

Use a new output directory outside the checkout. Pin the installed CLI executable because desktop and PATH versions can differ:

```text
python scripts/evaluate_gpt6.py --codex PATH_TO_CODEX_EXE --output OUTSIDE_REPO_NEW_DIRECTORY --baseline-ref 95d6b8f
```

Preparation freezes candidate skill bytes and copies each arm into independent Git fixtures under `.agents/skills`. It does not invoke a model. Add `--run` to a new invocation/output directory after the CLI is authenticated. The runner first verifies inference and an actual fixture read/write, then executes the matrix with `gpt-6-astra`, `low` effort, ephemeral sessions, workspace-write sandbox, ignored user configuration, and plugins/apps/hooks/memories disabled per invocation. On Windows it explicitly selects the existing elevated native sandbox, because ignoring user configuration also drops that setting. These flags do not edit account configuration. Use `--cases` and `--arms` for focused runs; each session defaults to a 120-second timeout.

Where an existing approved CA bundle is needed, pass `--ca-bundle PATH`. It sets `CODEX_CA_CERTIFICATE` only for child processes and preserves TLS verification. Never disable certificate checking to obtain an evaluation result.

Raw JSONL, stderr, artifacts, prompts, hashes, usage when available, elapsed time, and human-review criteria stay in the external output directory. A completed model call remains `completed_needs_review`; automated artifact checks are insufficient to judge skill selection, unnecessary questions, scope, and delegation. Failed authentication/TLS, rejected process execution, or failed workspace preflight is recorded as an environment blocker and stops the matrix. Unknown dollar cost and actual model snapshot remain null.

Repository-local skill discovery is distinct from installed-plugin activation. Ambient user/admin/system skills may remain; control means no added Superpowers suite, not a pristine prompt. Checkpoint recovery is a reproducible proxy and does not exercise actual host-driven mid-turn steering or compaction. Keep those limitations in comparative reports.

CLI JSONL can omit worker dispatch arguments and events. A final message claiming delegation plus correct artifacts does not fully verify worker ownership or serialized shared operations. Parent token usage and command counts also need not include worker activity. Mark missing delegation evidence explicitly. Fixtures begin with untracked input files, so use their saved hashes and actual artifacts for change scope; an empty Git diff alone proves nothing.

Launch the runner as the user who completed CLI login. A desktop sandbox account can report "Not logged in" while the signed-in user succeeds; check status in the actual runner context without reading or copying credentials. On Windows, a sandboxed shell also needs the [native sandbox implementation](https://learn.chatgpt.com/docs/windows/windows-sandbox#configure-the-windows-sandbox), independently of `--sandbox workspace-write`. See the evaluation results for executed coverage and setup failures.
