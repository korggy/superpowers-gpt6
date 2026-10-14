---
name: verification-before-completion
description: Use when your human partner requests a completion evidence check, or an accepted workflow requires verification before reporting completion.
---

# Verification Before Completion

## Overview

**Core principle:** Evidence before claims, always.

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT APPLICABLE VERIFICATION EVIDENCE
```

Evidence must cover the claimed behavior in the current code, inputs, and
environment. Read the command, exit status, and results. A prior run or a
worker's recorded results remain valid when those conditions have not
changed; the message boundary does not invalidate them.

## The Gate Function

```
BEFORE claiming completion or correctness:

1. IDENTIFY: What evidence and required checks prove this claim?
2. CHECK: Inspect existing results and the code/environment they covered.
   RUN missing checks, or rerun affected checks after relevant changes,
   failures, or a specific unresolved concern.
3. READ: Inspect output, exit status, and failures for the claimed scope.
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

If evidence is missing or does not apply, state the limitation.
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Applicable test output: 0 failures, with scope named | "Should pass", results for different code |
| Linter clean | Applicable linter output: 0 errors | Extrapolating a focused check to the whole project |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | Reviewed diff and applicable recorded check results | Agent reports "success" without evidence |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- About to commit/push/PR without verification
- Trusting an agent's bare success report
- Claiming broad success from a narrower check
- Thinking "just this once"
- Tired and wanting work over
- Claiming success without applicable evidence

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | Inspect applicable evidence or run the missing check |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Inspect its diff and actual check results |
| "I'm tired" | Exhaustion ≠ excuse |
| "Focused checks prove everything" | Focused checks support only their tested scope |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Inspect applicable test output: 34/34 pass] "All 34 affected tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check diff and recorded results → Run missing/invalidated checks → Report actual state
❌ Trust agent report
```

## Verification Scope

Complete checks required by the repository and the accepted task. Choose
additional checks for the affected behavior and realistic regression risk.
Once these pass, broaden or repeat only for a relevant change, failure, or
unresolved concern. A merge or dependency/configuration change can
invalidate evidence; rereading logs or entering a new message does not.

Report what passed and what remains unverified. An unavailable required
check prevents claiming that requirement is satisfied; an unavailable
unrelated suite does not erase valid evidence for the completed scope.
Verification does not grant permission to commit, publish, or deploy.
