# Scoped Re-Review Prompt Template

Use this template when dispatching a re-review after a fix round. The
re-reviewer verifies the findings were addressed and checks the fix diff for
new breakage. It is not a fresh review — the full review already happened.

**Purpose:** Verify each finding from the previous review was addressed, and
that the fix itself broke nothing.

```
Subagent (general-purpose):
  description: "Re-review Task N fix round R"
  model: [Optional supported override chosen per SKILL.md Model Selection;
          otherwise inherit the host default and follow its fork rules]
  prompt: |
    You are re-reviewing one task's fix round. A previous review produced
    findings; an implementer has attempted to fix them. Your job is to
    verdict each finding and inspect the fix diff — nothing else.

    ## The Task

    Read the task brief: [BRIEF_FILE]
    Read its current Decision Record, Global Constraints, and relevant rulings.
    Distinguish approved changes from proposals and worker assumptions; do not
    treat a worker's claim as authority to change acceptance criteria.

    ## The Findings Under Verification

    [FINDINGS]

    ## The Fix

    Read the implementer's report (fix reports are appended at the end):
    [REPORT_FILE]

    **Prior reviewed state:** [commit or retained working-tree snapshot]
    **Current state:** [commit or working-tree snapshot]
    **Review package:** [DIFF_FILE]

    Read the fix diff and relevant new-file contents against the prior reviewed
    state. HEAD may be unchanged across uncommitted fix rounds. If the package
    is missing or incomplete, request the correct evidence under
    review-evidence.md; do not substitute an empty commit range.

    Your review is read-only on this checkout. Do not mutate the working
    tree, the index, HEAD, or branch state in any way.

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

    ## Verification

    Treat the fix report as unverified claims. Check that its method, evidence,
    and result cover the actual fix diff. Behavioral changes need meaningful
    regression coverage and required checks; low-impact prose or metadata may
    use inspection or parsing evidence. For inspection, confirm the artifact,
    check performed, and observed result. For executed checks, inspect the
    command and relevant output. Accept reused results only when they still
    cover the unchanged code, configuration, and environment.

    Do not require test files or a new test run solely because a fix round
    occurred. Run a focused check only for a concrete doubt the existing
    evidence does not answer. If broader validation is required or warranted,
    report the gap to the controller instead of independently running a suite.

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
- Model override — optional, supported by the host and appropriate to the task
- `[BRIEF_FILE]` — the task brief file (same file the implementer worked from)
- `[FINDINGS]` — the Critical/Important findings and spec gaps from the
  previous review, copied verbatim, one per bullet
- `[REPORT_FILE]` — the implementer's report file (fix reports appended)
- Prior/current reviewed states — commits or retained working-tree snapshots
- `[DIFF_FILE]` — fix package against the prior reviewed state under
  [review-evidence.md](review-evidence.md)

**Re-reviewer returns:** per-finding verdicts (ADDRESSED / NOT ADDRESSED),
new breakage in the fix diff, out-of-scope observations, and a round verdict.
