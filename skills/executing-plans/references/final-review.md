# Inline Execution Final Review

Part of superpowers-gpt6:executing-plans. Load after the last task is complete.


Prepare the actual candidate with
[review-snapshot.md](../../subagent-driven-development/references/review-snapshot.md).
Select the committed or uncommitted route before invoking a helper; an empty
BASE..HEAD range is not a review package. Resolve helper paths from the installed
skill directory and run Git in the task checkout.

**With a subagent tool:** dispatch the final reviewer using
superpowers-gpt6:requesting-code-review's [template](../../requesting-code-review/code-reviewer.md).
Provide the review package, plan, spec, review focus and ledger rulings.
Inherit session settings by default; an authorized model override must follow
[the current Codex contracts](../../using-superpowers/references/codex-tools.md).
For uncommitted work include its actual diff, new files, and hashes, not only
BASE..HEAD. Preserve this required review gate.

**Without a subagent tool:** read code-reviewer.md and perform that review
yourself against the package, as a separate pass after the last task's
ledger line. Write `Final review: self-review (no subagent tool)` to the
ledger, and say so in your final message: a self-review by the author is
weaker than a fresh reviewer, and your human partner decides whether that
is enough before merge.

Sort the findings before you act on any of them. The reviewer's severity
labels are advice; the gate is yours. Its "Declined to judge" list is
yours too: every line there is a ruling you make and ledger, exactly like
a plan conflict — `Final: Ruling: <behavior the reviewer set aside> —
<what a reasonable person using this software gets, and why that stands
or why it is now a finding> — <cost if wrong>`. Re-grade first, by effect: the
spec is a vision document, and a finding's grade is what a reasonable
person using this software gets if it ships, not whether the spec names
the input that triggers it — a reviewer who set a finding at Minor
because the spec was silent has graded the spec, not the effect. Then:

- **Critical and Important** enter the fix pass.
- **Minor** goes to the ledger as `Final: minor (deferred): <one-liner>`
  and to your final message under "Deferred minors". Minors never enter
  the fix pass, and never become rulings — a ruling is a decision about a
  conflict, not a note that you declined a polish suggestion.

Fix the Critical and Important findings yourself — you are the
implementer here — in ONE pass. Choose verification by what changed:

- **Production behavior or a regression:** use TDD to reproduce the
  finding, observe the expected failure, make it pass, then run affected
  tests and required project checks.
- **Documentation or a static artifact:** inspect or validate the changed
  artifact against the finding and complete required checks. Do not
  manufacture a failing unit test that merely repeats its text.
- **Behavior-shaping instructions or skills:** use the applicable behavior
  evaluation workflow, such as superpowers-gpt6:writing-skills. Record actual
  baseline and candidate results; if both pass, report no demonstrated
  behavioral improvement rather than inventing a RED result.

Record each in the ledger as
`Final: fixed <finding> — <verification method>, <scope>, <observed result>, <evidence path>`.
Include RED→GREEN evidence for behavioral regression tests. Evidence must
cover the final code or artifact, inputs, and environment; reuse results
that remain applicable. Missing or failing required checks leave the fix
unverified and must be reported.

Do not dispatch a routine re-review once the evidence answers the finding
and the relevant regression risks. A specific unresolved concern calls
for the appropriate focused validation or review; do not claim it was
resolved merely because unrelated tests passed.

A finding you decide not to fix is a ruling — `Final: Ruling: <finding> —
<why the code stands> — <cost if wrong>` — and reaches your human partner
in the rulings list. There is no second fix pass.

