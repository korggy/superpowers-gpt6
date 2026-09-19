---
name: systematic-debugging
description: Suggest for unexplained failures requiring root-cause investigation. Invoke only when requested or accepted.
---

Follow the [invocation policy](../using-superpowers/references/invocation-policy.md).
Apply this workflow only when requested or accepted, including its stated supporting steps.

# Systematic Debugging

## Overview

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

Use for ANY technical issue:
- Test failures
- Bugs in production
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work
- You don't fully understand the issue

**Don't skip when:**
- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (rushing guarantees rework)
- Manager wants it fixed NOW (systematic is faster than thrashing)

## The Four Phases

Use these phases to establish the cause, choose a supported correction, and
verify the result. Reuse relevant evidence already available; do not repeat a
phase or add diagnostics merely to satisfy the sequence.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully**
   - Don't skip past errors or warnings
   - They often contain the exact solution
   - Read stack traces completely
   - Note line numbers, file paths, error codes

2. **Reproduce Consistently**
   - Can you trigger it reliably?
   - What are the exact steps?
   - Does it happen every time?
   - If not reproducible → gather more data, don't guess

3. **Check Recent Changes**
   - What changed that could cause this?
   - Git diff, recent commits
   - New dependencies, config changes
   - Environmental differences

4. **Gather Evidence in Multi-Component Systems**

   **WHEN system has multiple components (CI → build → signing, API → service → database):**

   Start with existing logs, traces, reproductions, and configuration. If they
   already identify the failing boundary and cause, investigate that component
   directly. Otherwise, add the smallest diagnostic that distinguishes the
   remaining hypotheses, within the task's logging and environment permissions:
   ```
   At the boundary still in question:
     - Compare relevant inputs and outputs
     - Check environment/config propagation or state as needed

   Gather evidence that locates the failure
   Investigate the identified component
   Expand diagnostics only if a specific uncertainty remains
   ```

   **Example (multi-layer system):**
   ```bash
   # Layer 1: Workflow
   echo "=== Secrets available in workflow: ==="
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

   # Layer 2: Build script
   echo "=== Env vars in build script: ==="
   env | grep IDENTITY || echo "IDENTITY not in environment"

   # Layer 3: Signing script
   echo "=== Keychain state: ==="
   security list-keychains
   security find-identity -v

   # Layer 4: Actual signing
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```

   **This reveals:** Which layer fails (secrets → workflow ✓, workflow → build ✗)

5. **Trace Data Flow**

   **WHEN error is deep in call stack:**

   See `root-cause-tracing.md` in this directory for the complete backward tracing technique.

   **Quick version:**
   - Where does bad value originate?
   - What called this with bad value?
   - Keep tracing up until you find the source
   - Fix at source, not at symptom

### Phase 2: Pattern Analysis

**Find the pattern before fixing:**

1. **Find Working Examples**
   - Locate similar working code in same codebase
   - What works that's similar to what's broken?

2. **Compare Against References**
   - If implementing pattern, read reference implementation COMPLETELY
   - Don't skim - read every line
   - Understand the pattern fully before applying

3. **Identify Differences**
   - What's different between working and broken?
   - List every difference, however small
   - Don't assume "that can't matter"

4. **Understand Dependencies**
   - What other components does this need?
   - What settings, config, environment?
   - What assumptions does it make?

### Phase 3: Hypothesis and Testing

**Scientific method:**

1. **Form Single Hypothesis**
   - State clearly: "I think X is the root cause because Y"
   - Write it down
   - Be specific, not vague

2. **Test Minimally**
   - Make the SMALLEST possible change to test hypothesis
   - One variable at a time
   - Don't fix multiple things at once

3. **Verify Before Continuing**
   - Did it work? Yes → Phase 4
   - Didn't work? Form NEW hypothesis
   - DON'T add more fixes on top

4. **When You Don't Know**
   - Say "I don't understand X"
   - Don't pretend to know
   - Ask for help
   - Research more

### Phase 4: Implementation

**Fix the root cause, not the symptom:**

1. **Choose Evidence That Demonstrates the Fix**
   - For behavioral defects, use a focused regression test or reproducible demonstration that distinguishes the failure from the expected behavior. Use `superpowers:test-driven-development` for that cycle.
   - Documentation and low-impact configuration may be checked by inspection, parsing, or a focused smoke check. Do not invent tests that merely repeat the implementation.
   - Reuse relevant existing reproductions and results. Preserve valid implementation that already exists; add missing regression protection without deleting it solely because the test came later.
   - Honor an explicitly retained test-first or human-review checkpoint. Otherwise choose the appropriate check within existing authority, without asking for an exception.

2. **Implement Single Fix**
   - Address the root cause identified
   - ONE change at a time
   - No "while I'm here" improvements
   - No bundled refactoring

3. **Verify Fix**
   - Does the selected evidence show that the original failure is resolved?
   - Run checks affected by the change and all required repository checks.
   - Reuse results while relevant code, inputs, dependencies, and environment are unchanged. Broaden or repeat checks for a concrete concern, new change, failure, or project requirement.
   - Use the `superpowers:verification-before-completion` skill before claiming success

4. **If Fix Doesn't Work**
   - Stop stacking speculative fixes. Compare the result with the hypothesis and record what the failure rules out.
   - Revisit the relevant investigation with the new evidence; distinguish implementation, dependency, environment, and design causes.
   - Continue with a supported next hypothesis and a bounded check within existing authority. Attempt count alone does not establish an architectural defect or require human approval.

5. **When Evidence Raises a Design Decision**

   **Signals worth investigating:**
   - Each fix reveals new shared state/coupling/problem in different place
   - Fixes require "massive refactoring" to implement
   - Each fix creates new symptoms elsewhere

   **Reassess the evidence and fundamentals:**
   - Is this pattern fundamentally sound?
   - Are we "sticking with it through sheer inertia"?
   - Should we refactor architecture vs. continue fixing symptoms?

   These signals suggest a possible design problem; they do not prove one.
   If the correction requires a material choice not settled by the request or
   established preferences, present the evidence, options, and recommendation
   to your human partner before affected implementation. Continue independent
   authorized work while that decision is pending. Proceed without repeating
   approval when the evidence supports a correction already within scope.

## Red Flags - STOP and Follow Process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip evidence that distinguishes the failure from the fix"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow
- **"One more fix attempt" without new evidence or a distinct hypothesis**
- **Each fix reveals new problem in different place**

**These mean:** Stop speculative changes and revisit the relevant investigation.
Use Phase 4.5 when evidence raises an unresolved design decision; the number of
attempts alone is not an approval gate.

## your human partner's Signals You're Doing It Wrong

**Watch for these redirections:**
- "Is that not happening?" - You assumed without verifying
- "Will it show us...?" - You should have added evidence gathering
- "Stop guessing" - You're proposing fixes without understanding
- "Ultra-think this" - Question fundamentals, not just symptoms
- "We're stuck?" (frustrated) - Your approach isn't working

**When you see these:** STOP. Return to Phase 1.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "It looks fixed, so no evidence is needed" | Use meaningful regression evidence for behavior and suitable inspection or validation for low-impact changes. Preserve any explicit test-first checkpoint. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" without new evidence | Reassess the failed hypothesis. Continue when evidence supports a bounded correction; ask about unresolved material choices, not the attempt count. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare | Identify differences |
| **3. Hypothesis** | Form theory, test minimally | Confirmed or new hypothesis |
| **4. Implementation** | Choose evidence, fix, verify | Original failure resolved; relevant and required checks pass |

## When Process Reveals "No Root Cause"

If systematic investigation reveals issue is truly environmental, timing-dependent, or external:

1. You've completed the process
2. Document what you investigated
3. Implement appropriate handling (retry, timeout, error message)
4. Add monitoring/logging for future investigation

**But:** 95% of "no root cause" cases are incomplete investigation.

## Supporting Techniques

These techniques are part of systematic debugging and available in this directory:

- **`root-cause-tracing.md`** - Trace bugs backward through call stack to find original trigger
- **`defense-in-depth.md`** - Add validation at multiple layers after finding root cause
- **`condition-based-waiting.md`** - Replace arbitrary timeouts with condition polling
