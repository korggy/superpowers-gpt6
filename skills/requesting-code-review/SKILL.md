---
name: requesting-code-review
description: Suggest for substantive review against requirements and correctness risks. Invoke only when requested or accepted.
---

Follow the [invocation policy](../using-superpowers/references/invocation-policy.md).
Apply this workflow only when requested or accepted, including its stated supporting steps.

# Requesting Code Review

Dispatch a code reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Establish review scope and evidence:**

Use [review evidence](../subagent-driven-development/review-evidence.md).
Identify the accepted requirements, Decision Record, starting state, and actual
changes. For committed work, use the correct base-to-head range. For uncommitted
or mixed work, include staged, unstaged, and relevant new-file contents, keeping
unrelated pre-existing changes separate. Do not create a commit just to review.

**2. Dispatch code reviewer subagent:**

Use an available, authorized worker with [code-reviewer.md](code-reviewer.md).
Pass a bounded task and the evidence; follow current host model/fork rules.
If delegation is unavailable, perform and label a separate self-review.

**Placeholders:**
- `[DESCRIPTION]` — what was built
- `[PLAN_OR_REQUIREMENTS]` — accepted requirements
- Reviewed state — commit range or identified working-tree snapshot
- `[REVIEW_PACKAGE]` — package covering the actual changes
- `[DECISION_RECORD]` — current authority, retained checkpoints, and rulings

**3. Act on feedback:**
- Distinguish substantiated correctness defects, unresolved product choices,
  and optional improvements against the accepted scope and Decision Record
- Fix Critical and Important defects within existing authority
- Present material product choices with evidence, options, and a recommendation;
  resolve them through existing delegation or the human before affected work
- Continue independent authorized fixes while a choice is pending; do not mark
  required unresolved decisions complete
- Note optional Minor improvements for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  Reviewed state: committed range a7981ec..3df7661
  REVIEW_PACKAGE: <package covering that range>
  DECISION_RECORD: <current approved/delegated decisions>

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Failed repair overwrites the valid index
    Minor: Magic number (100) for reporting interval
  Assessment: Ready after the required fix is verified

You: [Fix failed-repair handling and verify the original index is preserved]
[Continue to Task 3]
```

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I'll skip the selected independent review" | Use the authorized reviewer when available. If the host cannot delegate, label the separate self-review and its limitation. |
| "The reviewer needs my whole session history to understand the change" | Hand it precisely crafted context, never your session's history. That keeps the reviewer on the work product, not your thought process. |

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Treat a reviewer's severity label as authority for a new product requirement
- Declare work complete with unresolved required behavior or material decisions
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: [code-reviewer.md](code-reviewer.md)
