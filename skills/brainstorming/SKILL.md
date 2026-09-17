---
name: brainstorming
description: Resolve material requirements or design choices for new features, subsystems, or architectural changes before implementation.
---

# Brainstorming

Follow the [shared policy](../using-superpowers/references/workflow-policy.md), reading it once if needed.

Inspect enough existing context to identify decisions affecting the result. Do not reopen settled decisions or impose a design discussion on routine edits.

Choose the lightest useful approach:
- **Investigation:** answer a feasibility or diagnosis question with evidence. Create throwaway artifacts only within authorized scope.
- **Bounded implementation:** when requirements and local patterns are clear, state the approach briefly and proceed if implementation is authorized.
- **Architectural design:** explain meaningful alternatives and resolve choices affecting interfaces, compatibility, data, or substantial rework. Write a spec when it provides a useful handoff.

Ask questions whose answers change the result; bundle related questions when helpful. Honor a requested design checkpoint, but do not add one solely because this skill loaded.

Record the outcome, constraints, boundaries, affected interfaces, important failure cases, and verification strategy. Follow existing conventions and avoid unrelated refactoring. Use writing-plans when a durable multi-step plan is useful.

When a visual clarifies a decision, prefer available native tools. Read the optional [visual companion](visual-companion.md) guide only when choosing its local server/browser workflow. It is not a design prerequisite.

Finish with the requested deliverable: findings, design, or continued authorized implementation. Do not automatically commit design documents.
