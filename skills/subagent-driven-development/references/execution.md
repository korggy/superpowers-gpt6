# Coordinated execution

## Setup and recovery

Stay in the authorized workspace. Record plan identity, starting revision, branch, owned paths, and relevant pre-existing changes. For long work, retain completed tasks, evidence, pending work, worker identities, and consequential decisions.

Optional Bash helpers `scripts/sdd-workspace PLAN_FILE` and `scripts/task-brief PLAN_FILE N` create plan-scoped scratch files; resolve these paths relative to the skill directory. Do not reuse another plan's ledger. Without these helpers, write equivalent briefs and records with native file tools.

After compaction, inspect records and Git state before resuming. Preserve completed work and the latest user corrections. A completion entry does not override an unmet requirement.

## Briefs and ownership

Use [the implementer template](../implementer-prompt.md). Supply the objective, acceptance criteria, global constraints, exact shared interfaces, available dependencies, owned files, test scope, and permitted side effects. Batch related mechanical edits with shared acceptance criteria.

Workers do not create their own reviewers. If decomposition becomes necessary, report it to the controller. Parallel workers do not independently commit to a shared Git index.

## Review inputs

Record a baseline before each change. For committed tasks, `scripts/review-package PLAN_FILE BASE HEAD` writes the full multi-commit diff. It does not include uncommitted work. For uncommitted or parallel tasks, collect the owned paths' staged and unstaged changes plus relevant new files. Do not assume `HEAD~1` covers the task.

Provide requirements, actual change boundaries, diff or paths, and evidence. Reviewers may inspect surrounding code and callers for concrete risks. The controller resolves cross-task requirements not verifiable from an isolated diff.

## Fixes and disputes

Classify findings by correctness and acceptance impact. Fix blockers and defer optional polish outside scope. Reject false findings or resolve requirement conflicts immediately with recorded evidence; do not spend mandatory rounds attempting invalid fixes.

Resume the implementer when context remains useful. An unsuccessful attempt should change the hypothesis, evidence, or approach. Use fresh context or another model when the failure warrants it.

After two materially different unsuccessful attempts, reassess diagnosis and decomposition. This is not an automatic approval request or permission to declare success. Continue when evidence supports an in-scope next step; otherwise report the concrete blocker.

Re-review amended behavior and named risks. Reuse valid evidence. Unresolved required findings stay incomplete or blocked; optional deferred findings remain visible.

## Integration and finish

Inspect combined interfaces and shared state. Run required integration checks not covered by existing evidence. Report the outcome, checks, decisions, and remaining limitations.

Preserve recovery artifacts until conclusions and evidence have a durable handoff. Delete only verified task-owned scratch paths. Directory names do not establish ownership. Never discard the sole record of unresolved work. Commit, merge, push, and cleanup only within user authorization.
