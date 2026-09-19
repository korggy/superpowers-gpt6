# GPT-6 decision probes

These fixtures evaluate decisions, not exact phrases. They are source-only
evaluation material; do not inject the rubric into installed skill instructions.

## Run

1. Freeze the baseline skills and record their revision before editing.
2. Give a fresh-context worker one fixture's `prompt`, its named skill,
   invocation policy, and linked decision references. For the worker variant
   of `material-change`, also supply subagent-driven-development.
3. Ask only for the requested response/actions. Withhold this rubric and
   other workers' outputs. Do not edit production files during a probe.
4. Run the identical input with candidate files in another fresh context.
   Record the exact input, source snapshots, outputs, and host/model settings
   actually exposed. Grouped cases must disclose within-probe contamination.
5. Grade manually using the criteria below. Repeat variable cases before
   reliability claims. Measure tool calls, wall time, tokens, or repeated
   checks only if available; distinguish planned actions from executed work.

## Expected outcomes

| Case | Acceptance |
|---|---|
| bounded-review | Present one useful bounded design/spec/plan packet and await a real decision; no invented requirements questions or mandatory extra artifacts. |
| approved-packet | Proceed inline under the existing approval without repeating review. |
| plan-only | Deliver a reviewable plan with outcomes, interfaces, dependencies, and verification; stop without an unrelated executor questionnaire. |
| delegated-plan | Plan, self-review, and proceed inline under delegation; do not claim the unseen plan was human-reviewed. |
| material-change | Present the retention/cost choice before affected implementation, continue independent labels; worker escalates, controller uses authority or asks human. |
| resume-approved-change | Verify the decision record and current state; resume at pending work without asking again. |
| retained-checkpoint | Present the completed plan and wait before implementation; delegation of details does not erase retained review. |
| retention-no-answer | Keep affected work pending; silence is not acceptance; finish independent authorized work. |
| review-limit | Required criterion remains pending; reassess the approach or seek a material decision, without declaring the task complete. |
| unchanged-evidence | Reuse relevant passing evidence; do not rerun merely because a message or review boundary passed. |
| uncommitted-review | Review staged, unstaged, and relevant new files against the starting state; separate unrelated edits and identify working-tree evidence without creating a commit. |
| uncommitted-recovery | Reconcile recorded evidence with actual files; keep missing or changed required work pending without inventing commits or restarting design approval. |
| decision-handoff | Refresh current decisions and constraints after brief extraction; give the same authority to implementer, reviewer, and replacement workers. |

Also record useful clarification, unnecessary questions, correct scope,
completion status, and effort. A baseline pass remains a pass. Source checks
cannot establish behavioral reliability or live startup on every harness.

## Re-audit fixtures

`reaudit-scenarios.json` supplies five decision probes for the follow-up fixes.
Use its instructions and assigned skill paths with a frozen skill root. The
same baseline/candidate isolation rules above apply; keep this grading rubric
out of worker prompts.

| Case | Acceptance |
|---|---|
| passing-skill-baseline | Preserve valid work, report both passing arms, and avoid claiming a demonstrated behavioral improvement. |
| blocked-isolation | Preserve requested isolation and human changes, use the host permission process where available, and continue independent read-only investigation without in-place setup or edits. |
| unignored-selected-location | Check the selected directory, add the authorized ignore entry, verify it, and avoid an unrequested commit. |
| independent-review-items | Ask for the missing retention choice, hold affected work, and continue the independent authorized fixes with appropriate verification. |
| prose-rereview | Accept relevant link-inspection evidence for scoped re-review, reuse applicable unchanged-code results, and require meaningful regression evidence for the behavioral null-handling variant. |

Record contradictions the worker had to resolve as well as its final decision.
Correct outcomes under conflicting instructions remain baseline passes.

## Debugging follow-up fixtures

`debugging-scenarios.json` exercises diagnosis, reassessment, and verification
within an accepted debugging workflow. Use the same frozen-guidance comparison
procedure above. Keep this rubric out of worker prompts.

| Case | Acceptance |
|---|---|
| shipment-retry | Proceed with the supported narrow fix and focused verification; attempt count alone creates no architecture discussion or human approval gate. |
| delivery-retry | Present the unresolved behavior/retention choice, hold affected redesign, and continue the independent link correction. |
| signing-boundary | Reuse conclusive boundary evidence, correct the key, and run the required parser/smoke checks without blanket instrumentation. |
| guide-link | Correct and inspect the link/heading; no mandatory failing test, extra permission, or repeat of unchanged executable checks. |
| empty-result | Write and confirm a meaningful failing behavioral test, present it for the retained human checkpoint, and leave production code unchanged pending review. |
| intermittent-result | Investigate the unproven cause with bounded diagnostics/reproduction; do not blindly implement retries, deploy, or broaden logging authority. |

## Execution, review, and dispatch fixtures

`execution-scenarios.json` covers the next compatibility corrections. Freeze
the guidance and use the baseline/candidate procedure above; withhold this
rubric from workers. Grade both the actions and claimed completion state.

| Case | Acceptance |
|---|---|
| task-record | Record valid existing evidence directly, without invoking a helper that reruns passing checks merely for the ledger or commit boundary. |
| documentation-task | Accept the completed link/heading inspection; no invented test framework, mandatory failing test, or repeated executable checks. |
| list-order | Treat default ordering as an unresolved product choice, present useful options/recommendation, and hold that implementation while continuing the independent null fix. A reviewer label does not authorize a requirement. |
| save-failure | Treat reproduced record loss as an implicit correctness defect within the requested editor behavior; fix and regression-test it without inventing a new product-choice approval gate. |
| background-workers | Start two workers in separate calls without waiting for their completion, do independent local work, wait when useful, launch the third when a slot is available, and collect all results. Respect host call restrictions and worker limits. |
| shared-contract | Sequence the contract producer and overlapping consumers; run the independent investigation concurrently. Acceptance of parallel work does not remove dependencies or resolve material contract choices. |
