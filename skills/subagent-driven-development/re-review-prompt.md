# Scoped Re-Review Prompt Template

Use this template when dispatching a re-review after a fix round. The
re-reviewer verifies the findings were addressed and checks the fix diff for
new breakage. It is not a fresh review — the full review already happened.

**Purpose:** Verify each finding from the previous review was addressed, and
that the fix itself broke nothing.

Inherit session model and reasoning settings unless an override is authorized.
Map the role and task to the current tool's supported message field. For Codex,
full-history forks omit both overrides; an authorized override uses a clean
fork with both supported settings. Follow the
[current Codex contracts](../using-superpowers/references/codex-tools.md).

```
Subagent (general-purpose):
  description: "Re-review Task N fix round R"
  prompt: |
    You are re-reviewing one task's fix round. A previous review produced
    findings; an implementer has attempted to fix them. Your job is to
    verdict each finding and inspect the fix diff — nothing else.

    ## The Task

    Read the task brief: [BRIEF_FILE]

    ## The Findings Under Verification

    [FINDINGS]

    ## The Fix

    Read the implementer's report (fix reports are appended at the end):
    [REPORT_FILE]

    **Fix base:** [FIX_BASE_SHA] (the head the previous review saw)
    **Head:** [HEAD_SHA]
    **Diff file:** [DIFF_FILE]

    Read the supplied fix package first: commits where relevant, a stat
    summary, and fix diff with context. For uncommitted work include the
    before/after snapshot identities, staged/unstaged changes, new-file
    contents, and exact candidate file hashes. A FIX_BASE..HEAD range cannot
    identify changes between uncommitted snapshots. Verify the package covers
    this fix without silently substituting a commit-only diff.

    If the package is missing or stale, use read-only Git/file inspection to
    recover the fix boundary from the recorded snapshots, or report the gap.
    Do not expand a scoped re-review to unrelated initial changes because the
    previous uncommitted snapshot is unavailable.

    Your review is read-only on this checkout. Do not mutate the working
    tree, the index, HEAD, or branch state in any way.
    Inspect history with read-only Git commands. Separate checkouts require
    isolation authority and the native worktree lifecycle; a review request
    alone does not authorize creating or deleting worktrees. Report validation
    that cannot fit the read-only scope.

    ## You Do Not Dispatch Subagents

    Do all of this review yourself. Never spawn a subagent to review part
    of the diff, and never spawn another reviewer for a second opinion.
    This process already provides every review seat the work gets; a
    reviewer you spawn duplicates one of them at full cost, and its
    verdict counts for nothing. If the diff feels too large for one
    pass, review it in passes yourself and say so in your report.

    ## Scope

    Your scope is the findings list and the fix diff. Verdict every finding.
    Inspect the fix diff for new problems the fix itself introduced. Do NOT
    re-review code the fix did not touch: if you notice an issue entirely
    outside the fix diff, report it under Out-of-Scope Observations — it
    does not block this task and does not extend the loop. A broad
    whole-branch review happens after all tasks are complete.

    ## Verification Evidence

    Inspect the fix report's actual results against the diff and candidate
    hashes. Behavior fixes need affected tests and required project checks,
    with RED-to-GREEN evidence when TDD applies. Static artifacts need
    inspection/validation; behavior-shaping skills need behavior evaluations.
    A static text fix does not need a manufactured unit test.

    Reuse inspected evidence when the covered code/artifact, inputs, and
    environment are unchanged. Run only missing or invalidated checks for a
    concrete concern or requirement, within read-only scope and permissions.
    Broaden only for required checks or justified risk. If a needed check
    requires writes or is unavailable, name the unverified scope for the
    controller. Do not rerun applicable checks merely because a new review
    began, and do not present focused results as a full-suite pass.

    ## Output Format

    Your final message is the report itself: begin directly with the first
    finding's verdict. Every line is a verdict, a finding with file:line,
    or a check you ran — no preamble, no process narration.

    ### Finding Verdicts

    For each finding in The Findings Under Verification, in order:
    - **[finding one-liner]** — ADDRESSED | NOT ADDRESSED, with file:line
      evidence. "Attempted" is not addressed: the specific defect must no
      longer exist.

    ### New Breakage in the Fix Diff

    Anything the fix itself broke or introduced, with severity
    (Critical/Important/Minor) and file:line. "None" if clean.

    ### Out-of-Scope Observations

    Issues you noticed entirely outside the fix diff. Non-blocking; the
    controller ledgers these for the final review. "None" if none.

    ### Verdict

    **Fix round:** [All findings addressed, no new Critical/Important
    breakage | Findings remain open] — list the open ones.
```

**Placeholders:**
- `[BRIEF_FILE]` — the task brief file (same file the implementer worked from)
- `[FINDINGS]` — the Critical/Important findings and spec gaps from the
  previous review, copied verbatim, one per bullet
- `[REPORT_FILE]` — the implementer's report file (fix reports appended)
- `[FIX_BASE_SHA]` — the commit the previous review saw; include its snapshot
  identity separately when that review covered uncommitted work
- `[HEAD_SHA]` — current commit; include exact candidate file hashes separately
- `[DIFF_FILE]` — the fix package path, including uncommitted before/after
  diffs and new files when applicable; the helper's Git range alone covers commits

**Re-reviewer returns:** per-finding verdicts (ADDRESSED / NOT ADDRESSED),
new breakage in the fix diff, out-of-scope observations, and a round verdict.
