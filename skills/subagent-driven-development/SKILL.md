---
name: subagent-driven-development
description: Execute a substantial plan with bounded workers and independent review when delegation is available and useful.
---

# Subagent-Driven Development

Follow the [shared policy](../using-superpowers/references/workflow-policy.md), reading it once if needed.

Use this for tasks whose scope justifies dispatch and review overhead. Keep small or tightly coupled changes local. The controller owns scope, integration, and completion.

Read the [execution reference](references/execution.md) for briefs, recovery records, evidence, and fix loops. On Codex, also read the [runtime adapter](../using-superpowers/references/codex-tools.md) if needed.

Dispatch a self-contained brief with requirements, constraints, interfaces, owned paths, allowed side effects, and acceptance checks. Select model/context settings from live host capabilities without forcing overrides.

Parallel implementation requires disjoint ownership and safe shared-state boundaries. Serialize Git mutations and shared builds. The controller assigns review; workers do not duplicate reviewers.

For substantive changes, use [task-reviewer-prompt.md](task-reviewer-prompt.md) to check scope and correctness. A focused controller inspection can suffice for small mechanical work.

Address valid material findings and adjudicate disputes from evidence without mandatory retry rounds. Use [re-review-prompt.md](re-review-prompt.md) for amended areas. Retry limits constrain churn; they never make unmet requirements complete.

Continue authorized work without inter-task approval requests. Honor explicit checkpoints and material scope questions. Integration and publication follow the user's instructions and shared policy.
