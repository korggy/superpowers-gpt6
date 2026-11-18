# Final Review and Finish

Part of superpowers-gpt6:subagent-driven-development. Every task in the plan is
complete.

The final whole-change review gets a package of the actual candidate:
follow [review-snapshot.md](review-snapshot.md), choosing the committed or
uncommitted route before invoking a helper. Include its file path in the
dispatch. Follow SKILL.md's current tool and model-inheritance contracts, using
superpowers-gpt6:requesting-code-review's
[code-reviewer.md](../../requesting-code-review/code-reviewer.md). Point it at
the ledger's deferred-minor and parked lines so it can triage which must be
fixed before merge.

For an uncommitted candidate, add its working-tree diff, the contents of new
files, and exact file hashes to the review package. `MERGE_BASE..HEAD` alone
does not cover those changes. State the reviewed snapshot and provide the
actual evidence for it; do not treat the base revision as the candidate.

Verify production regressions with meaningful RED-to-GREEN tests in accepted
TDD workflows, static artifacts by inspection/validation, and skill behavior
with writing-skills evaluations. Reuse valid evidence and report exact scope.

If the final whole-branch review returns findings, reuse or dispatch ONE fix subagent
with the complete findings list — not one fixer per finding.
Per-finding fixers each rebuild context and re-run suites; a real
session's final-review fix wave cost more than all its tasks combined.
Inspect the fix diff and applicable evidence. Reuse the original implementer
when practical. Preserve required review gates; use a scoped re-review only
for a specific unresolved concern or mandatory check. See
[re-review-prompt.md](../re-review-prompt.md) for that focused review.
Adjudicate any residual findings as in the fix loop's breaker
(references/fix-loop.md): park with rulings, or rule on the load-bearing
ones and ledger what you decided. Preserve the authorization and checkpoint
boundaries at the top of SKILL.md. There is no automatic second fix wave —
residual load-bearing findings surface to your human partner when
finishing-a-development-branch presents the options.

### Finish

Before you delete anything, collect every ledger line containing `Ruling:` —
preflight rulings, parked findings, breaker adjudications, all of them — into
your final message under "Rulings I made", in the order you made them, each
with what it costs if wrong. The list is exhaustive: if the ledger holds a
ruling, the list holds it. That list is the only place the decisions you
took on your human partner's behalf reach them — they read it and rework
whatever you got wrong. A ruling that dies with the workspace was a decision
made in secret.

Preserve the ledger, rulings, reports and evidence through the handoff.
Clean only authorized task-owned scratch after preserving needed files.
Do not infer that Git contains ignored or untracked evidence. Native
worktree cleanup follows finishing-a-development-branch; never remove a
managed checkout with a scratch-directory deletion command.

Use superpowers-gpt6:finishing-a-development-branch.
