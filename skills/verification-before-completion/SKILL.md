---
name: verification-before-completion
description: Suggest when work needs an evidence-based completion check. Invoke only when requested or accepted.
---

# Verification Before Completion

Follow the [invocation policy](../using-superpowers/references/invocation-policy.md).

**Core principle:** Evidence before claims. Match each claim to what was
actually checked, on the relevant code and environment.

## Choose the Evidence

Before reporting completion:

1. Identify the requested outcome and the checks that establish it.
2. Inspect existing evidence: command, working directory, tested revision or
   relevant working-tree content, dependencies, environment, result, and limits.
3. Run missing checks and checks invalidated by relevant changes.
4. Read the results and report the supported outcome, failures, and gaps.

Evidence remains valid when the relevant code, dependencies, inputs, and
environment are unchanged. A new message, commit with identical tested
content, or reviewer does not invalidate it. Reuse readable evidence from
another worker after checking its provenance and relevance. Investigate a
specific contradiction instead of automatically rerunning their suite.

## Scale Verification

Run checks covering the changed behavior and all required repository checks.
Use broader suites for cross-cutting changes, integration risks, or unresolved
failures. Once the relevant checks pass, repeat or broaden them only for a
new change, failure, concrete concern, or project requirement.

Behavioral fixes usually need a regression test or reproducible demonstration.
Documentation, generated files, and low-impact configuration may need
inspection, parsing, validation, or a focused smoke check. Do not add tests
that simply duplicate implementation or delete valid work because the test
was written after it.

## Interpret Results

| Claim | Evidence needed | Limit |
|---|---|---|
| Tests pass | Relevant command completed with zero failures | Name the suite; do not imply unrun suites passed |
| Build succeeds | Relevant build exited successfully | Lint alone does not establish a build |
| Bug fixed | Original failure reproduced, then corrected | A changed diff alone is insufficient |
| Regression protection | Test or demonstration distinguishes broken and fixed behavior | Test timing alone does not prove quality |
| Requirements met | Requested outcomes checked against artifacts | Passing tests may leave untested requirements |
| Ready to integrate | Required checks on the integration candidate | Local success is not deployment proof |

Separate failures introduced by this change from pre-existing, dependency,
and environmental failures. Fix failures within the authorized scope and
report the others by name. An unrelated baseline failure does not erase
valid targeted evidence or authorize unrelated repairs. A required check
that cannot run remains a disclosed limitation; do not claim full validation.

Inspect unexpected warnings for relevance. Report consequential ones without
requiring unrelated warning cleanup as a completion gate.

## Report

State what changed, which checks ran and their results, any valid evidence
reused, and remaining limitations. Never say a check passed unless its output
supports that claim. Do not perform another run merely to make the evidence
appear in the final message.
