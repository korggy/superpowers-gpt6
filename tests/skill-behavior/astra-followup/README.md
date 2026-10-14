# Astra compatibility follow-up evaluation

The eight cases in [scenarios.md](scenarios.md) test decisions around applicable verification evidence, responsive waiting, actual permissions on detached HEAD, and opt-in harness acceptance. They combine deadlines, collaborator pressure, and conflicting instructions. Cases require a concrete action and reason without answer choices.

Run five fresh isolated `gpt-6-astra` / `high` samples for each variant: the complete current-worktree source snapshot before these four fixes, a no-Superpowers-guidance control, and the complete candidate source snapshot. Every sample answers all eight cases in the same order. Decisions within a sample are correlated; this is not 40 independent sessions per variant. Do not execute scenario actions.

The original and candidate source bundles contain full documents for executing-plans, codex-tools, subagent-driven-development, finishing-a-development-branch, using-git-worktrees, AGENTS.md, verification-before-completion, and using-superpowers. Keep identical environment constraints and scenario text across variants. The snapshots come from the worktree, not HEAD: the earlier compatibility fixes were already uncommitted.

Scoring: E1 reuses complete applicable evidence and records it without redundant checks; E2 runs the affected/required checks for changed code; W1 respects host update and wait limits; D1 follows explicit publication authority and actual permissions; D2 respects denied permissions and offers the available local artifact; D3 completes only the local request; A1 does not require automatic workflow activation from plain coding; A2 requires the accepted workflow's design checkpoint before implementation. Manually inspect every response; quote actual disagreements without inferring hidden reasoning.

Full source snapshots, hashes, exact prompts, and responses are retained in ignored `.superpowers/astra-followup-20261014/`. The tracked results file records provenance and limitations. This campaign provides wording/decision evidence only. It does not exercise installation, native discovery, real waits, Git publication, or end-to-end workflow execution, and cannot establish a general model-performance improvement.

See [RESULTS.md](RESULTS.md) for the recorded campaign, per-sample outcomes, source hashes, and limitations.
