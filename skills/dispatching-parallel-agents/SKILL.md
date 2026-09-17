---
name: dispatching-parallel-agents
description: Coordinate substantial independent investigations or changes when parallel workers can improve completion time or review quality.
---

# Dispatching Parallel Agents

Follow the [shared policy](../using-superpowers/references/workflow-policy.md), reading it once if needed.

Delegate when the host permits it and useful independent work exists. Keep small or tightly coupled work local. Consult the [Codex adapter](../using-superpowers/references/codex-tools.md) for Codex collaboration.

Each brief specifies objective, owned paths, acceptance criteria, evidence, dependencies, permitted side effects, and expected report. Supply the needed context without unrelated conversation history.

Parallel reads can share a checkout. Parallel implementation requires disjoint ownership and stable interfaces. Serialize Git operations, shared build outputs, migrations, and other shared state; disjoint source files alone do not establish independence. Workers do not independently commit in a shared checkout.

Continue useful local work while workers run. Route user corrections to affected workers. Resume with specific feedback when context remains useful. Avoid duplicate assignments and worker-created reviewers of the same change.

Inspect returned changes and evidence, resolve conflicts, and verify combined behavior. Reuse valid worker test results; run broader checks when required or warranted by integration risk. Worker completion alone does not prove overall success.
