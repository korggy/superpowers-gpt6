---
name: writing-plans
description: Write a durable implementation plan when a multi-step change needs coordination, recovery, or handoff.
---

# Writing Plans

Follow the [shared policy](../using-superpowers/references/workflow-policy.md), reading it once if needed.

Simple changes can use an in-chat checklist. Use a file for durable handoffs, long tasks, or coordinated workers; honor the user's location preference (default: `docs/superpowers/plans/YYYY-MM-DD-topic.md`).

Include goal, relevant spec, shared constraints, dependencies, affected files, interfaces, acceptance criteria, and verification. State unresolved material decisions. Provide exact signatures or code examples for fragile interfaces; do not prewrite the whole implementation to satisfy a template.

Split independently judgeable deliverables and batch mechanical changes of the same kind. Identify dependencies and write ownership before proposing parallel work. Avoid fixed step durations and mandatory per-step commits.

For the bundled task-brief extractor, use this shape:

```markdown
# Feature Implementation Plan
Goal: Describe the requested outcome.
Spec: Link an existing design when relevant.

## Global Constraints
Requirements shared by every task.

## Task 1: Deliverable
Files: Affected paths.
Dependencies: Earlier deliverables.
Interfaces: Contracts other tasks rely on.
Acceptance: Observable success.
Verification: Checks and risks they cover.
```

Check request coverage, interface consistency, and whether each brief supplies enough context to execute. Correct plan defects when new evidence warrants it.

For plan-only requests, return the plan. When implementation is already authorized, continue with executing-plans or subagent-driven-development according to independence and available tools. Do not add an execution-choice approval gate unless it materially affects user constraints.
