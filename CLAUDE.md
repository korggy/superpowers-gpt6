# Superpowers GPT-6 contributor guidance

This repository maintains a Codex-focused GPT-6 Astra variant of Superpowers.
The user controls scope and authorization; implement accepted work without reopening routine approvals.
Preserve the selected checkout and branch. Push, installation, publication, and cleanup are separate actions.

Read the applicable skill and its shared workflow policy when changing behavior.
Keep entry points concise and use supporting references for conditional detail.
Current host tool schemas take precedence over adapter examples.

For significant skill changes, compare realistic control, baseline, and candidate scenarios.
Use independent subagents for bounded forward-testing when available.
Do not claim reliability or efficiency gains from structural checks or a single smoke case.
Keep raw credentials and session traces out of tracked reports.

Run `python -m unittest discover -s tests/codex -p 'test_*.py'` for portable packaging checks.
Run `python scripts/validate_gpt6.py` for metadata, links, and package structure.
Behavioral cases and limitations are documented in `docs/testing.md`.
Use the project's existing languages and test tools; this repository is a skill/plugin project.

Upstream submission rules are preserved in `docs/upstream/CONTRIBUTING.md`.
They apply to submissions to upstream, not to local implementation of this fork.
Do not automatically sync this fork to upstream.
