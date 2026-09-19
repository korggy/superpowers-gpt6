---
name: test-driven-development
description: Suggest for new behavior or reproducible defects needing regression protection. Invoke only when requested or accepted.
---

# Test-Driven Development

Follow the [invocation policy](../using-superpowers/references/invocation-policy.md).

Write a focused behavioral test, observe the intended failure, implement the
smallest correct change, then verify it passes. The point is regression
protection and feedback about the design.

## Decide What Needs a Test

Use the cycle for new behavior, bug fixes, and risky refactoring. Before
writing a test, name the production defect or change that would make it
fail. Read [writing-good-tests.md](writing-good-tests.md) when designing or
changing tests.

Documentation, generated output, throwaway probes, and low-impact configuration
may be better checked by inspection, parsing, or a smoke check. Choose the
check that establishes the requested outcome; no extra permission is needed
to choose a suitable check unless the human specified a test-first checkpoint.
Avoid tests that mirror implementation without checking an observable result.

## RED: Demonstrate the Missing Behavior

Write the smallest test that exercises the relevant production behavior.
Use a clear name, realistic inputs, and assertions on the outcome. Use
mocks when needed to isolate a boundary, not as the behavior being tested.

Run the focused test. Confirm it fails because of the missing behavior.
Fix test setup, syntax, or environment problems before interpreting a failure.
If it passes unexpectedly, determine whether the behavior already exists or
the test fails to distinguish it; do not manufacture a failure.

## GREEN: Implement and Verify

Implement only what the requested behavior needs. Run the focused checks,
read their output, and compare it with the intended result.

Run the repository's required checks and any additional checks justified by
the affected components or an unresolved risk. A full suite is appropriate
when required by the project or needed to cover cross-cutting behavior; it
is not automatically required for every edit or task.

If a test fails, investigate whether the implementation, test expectation,
dependency, or environment is responsible. Fix failures caused by the change.
Report unrelated failures by name without silently broadening the task.
Inspect warnings for consequences; do not demand unrelated cleanup.

## REFACTOR: Preserve Behavior

Simplify the changed code when it serves the task. Rerun the checks affected
by refactoring. Keep unrelated improvements out of scope.

Reuse existing results while the relevant code, dependencies, inputs, and
environment remain unchanged. Another message, reviewer, or completion step
does not require another identical run. Verification-before-completion
governs the evidence and claims in this workflow.

## Existing Implementation

Do not delete valid code solely because it preceded the test. Add the missing
regression protection and, when useful, demonstrate that the test rejects the
prior defective behavior in a disposable fixture or through a safe temporary
reversal of only your own change. Preserve unrelated work. Record honestly
whether the test was written before or after the implementation.

## Completion Check

- The test or demonstration distinguishes the defect from correct behavior.
- Requested behavior works and required checks have been completed.
- Results correspond to the current relevant code and environment.
- Failures and unrun checks are reported with their practical limits.
- No test exists solely to restate a constant or reproduce the implementation.

Stop repeating checks once this evidence is sufficient. Ask a focused question
only when a missing requirement would change the expected behavior.
