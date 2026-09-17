---
name: using-superpowers
description: Select a Superpowers GPT-6 workflow for substantial coding work spanning design, implementation, debugging, or review.
---

# Superpowers GPT-6

Read the [shared workflow policy](references/workflow-policy.md) once per task. It governs scope, authorization, verification, and completion.

Load only a skill that helps the current task or was explicitly requested. A factual question, typo correction, or routine bounded edit does not require a process chain.

- Unresolved design decisions: brainstorming.
- A durable implementation handoff: writing-plans.
- An existing plan to implement: executing-plans.
- Substantial independent tasks with available delegation: subagent-driven-development or dispatching-parallel-agents.
- Unexpected behavior: systematic-debugging.
- Behavioral changes needing regression protection: test-driven-development.
- Substantive review: requesting-code-review or receiving-code-review.
- Requested isolation or integration: using-git-worktrees or finishing-a-development-branch.

For Codex delegation and workspace operations, consult [codex-tools.md](references/codex-tools.md). Trust the actual tools exposed by the host. A delegated worker stays within its assigned task and uses relevant skills without restarting the full workflow.
