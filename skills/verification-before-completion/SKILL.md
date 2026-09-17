---
name: verification-before-completion
description: Check evidence before reporting that implementation, tests, or requested behavior is complete.
---

# Verification Before Completion

Follow the [shared policy](../using-superpowers/references/workflow-policy.md), reading it once if needed.

Match claims to evidence:
- Build success needs the build result; lint alone does not establish it.
- A fixed bug needs evidence covering its original symptom.
- Tests establish only the behavior and environment exercised.
- Worker reports need inspection of actual changes and cited results.
- Requirements completion needs comparison against acceptance criteria.

Reuse results for unchanged relevant code, dependencies, inputs, and environment. A new turn, reviewer, or final response does not itself require another run. Determine which evidence a working-tree change invalidates and rerun affected checks.

Record command, directory, code state, environment, outcome, and limits. Code state can be a revision or identified uncommitted diff; do not force a commit to record evidence.

Inspect the final diff for unintended changes. Report failed or unavailable checks distinctly from new regressions. Avoid claiming full-suite, deployment, or live-system success from narrower local evidence.
