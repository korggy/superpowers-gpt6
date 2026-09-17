---
name: requesting-code-review
description: Review substantive changes against requirements, correctness risks, and evidence before integration or handoff.
---

# Requesting Code Review

Follow the [shared policy](../using-superpowers/references/workflow-policy.md), reading it once if needed.

Use an independent reviewer when scope and risk justify it and delegation is permitted. Small mechanical changes can receive focused local inspection. Explicit review requests remain read-only unless implementation is also requested.

Identify the whole change: record its starting revision, use the requested comparison, or derive the correct branch baseline. Do not default to `HEAD~1`, which omits earlier commits in a multi-commit task. Include staged, unstaged, and relevant untracked files.

Provide requirements, boundaries, changed paths or diff, and test evidence using [code-reviewer.md](code-reviewer.md). Do not prescribe a verdict or send unrelated history.

Inspect findings against code. Fix valid material defects within scope, reject incorrect findings with evidence, and record optional out-of-scope improvements separately. Re-review amended behavior when needed, reusing valid test results.

Report actionable findings with location, concrete impact, and severity. If none remain, say so and disclose verification gaps. Review approval does not authorize merge or publication.
