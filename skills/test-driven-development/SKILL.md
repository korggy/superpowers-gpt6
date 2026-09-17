---
name: test-driven-development
description: Add meaningful regression protection when implementing behavioral changes or fixing reproducible defects.
---

# Test-Driven Development

Follow the [shared policy](../using-superpowers/references/workflow-policy.md), reading it once if needed.

For a behavioral defect, capture the observable failure with a focused test or reproducible check. Confirm it fails for the intended reason, implement a coherent fix, and run affected checks. Setup or dependency failure does not prove the test detects the defect.

For new behavior, specify acceptance cases before implementation when practical. Cover significant edge cases and failure paths. Refactor within scope while keeping checks valid.

Use the project's test framework and conventions. Assert behavior and contracts rather than implementation details. Identify a real defect each new test could catch. Read [writing-good-tests.md](writing-good-tests.md) when designing tests involving mocks or difficult isolation.

Documentation, generated files, and reversible low-impact configuration may need inspection, syntax validation, or smoke checks instead of new tests. Choose the appropriate check without extra permission unless the user or project explicitly requires a particular approach.

If implementation exists, preserve it. Add regression protection and demonstrate that tests detect previous behavior in an isolated or safely reversible way when useful. Do not delete work to recreate test-first ordering.

Run required checks and affected tests. Reuse still-valid results; broaden coverage for concrete risks or unexplained failures. Separate baseline failures from new regressions and report untested behavior accurately.
