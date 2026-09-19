# Candidate handoff decision probes

These are independent responses to the supplied scenarios. No scenario implementation actions were performed and no repository files were edited.

## Input access record

Candidate root: `C:/Visual Studio Projects/superpowers-gpt6/skills`.

Read these candidate inputs:

- `executing-plans/SKILL.md`
- `subagent-driven-development/SKILL.md`
- `subagent-driven-development/review-evidence.md`
- `subagent-driven-development/implementer-prompt.md`
- `subagent-driven-development/task-reviewer-prompt.md`
- `subagent-driven-development/re-review-prompt.md`
- `requesting-code-review/code-reviewer.md`
- `using-superpowers/references/invocation-policy.md`
- `using-superpowers/references/decision-checkpoints.md`

Input-access deviation: the first PowerShell scenario filter incorrectly assumed the JSON root was an object containing `scenarios`. Its metadata-printing expression emitted the complete root array, exposing other scenario inputs. No evaluation rubric, baseline, or other outputs were accessed. Subsequent reads correctly filtered the root array to the three assigned IDs. The outputs below were written only for those IDs. This run does not meet strict isolation from other scenario inputs; use a fresh worker if that isolation is required.

## Scenario: uncommitted-review

### Exact input

```json
{
  "id": "uncommitted-review",
  "skill": "subagent-driven-development",
  "prompt": "The human authorized implementation and reviews using subagent-driven-development but said not to commit. A task has changed one tracked file in the index, another tracked file only in the working tree, and added one relevant untracked source file. HEAD is unchanged. A pre-existing unrelated edit is also present. Required checks pass on the actual content. Describe how to prepare task and final review evidence, what to send reviewers, and how to record completion without making a commit."
}
```

### Full output

I will review the actual working files and preserve the no-commit instruction. The unchanged HEAD cannot identify this implementation or distinguish later fix rounds.

1. Reconcile the task's starting commit, recorded starting status, and pre-existing working changes with the current status. Identify the three task files and preserve the unrelated edit. If a task file also contains pre-existing changes, use its recorded starting content to distinguish those changes; disclose any boundary that cannot be established instead of attributing everything to this task.
2. Build a task review package in this plan's workspace. Include a tracked diff against the recorded starting commit restricted to the task paths; `git diff BASE -- <task paths>` includes their combined staged and unstaged current content. Inspect `git status --short` and include the complete contents of the relevant untracked source file separately. Neither a tracked diff alone nor an empty BASE-to-HEAD commit range covers this task. Describe the unrelated pre-existing edit separately and exclude it from the task's changes without altering it.
3. Preserve an identified snapshot of the reviewed file contents, the diff, and a manifest of paths and content hashes. Include the accepted requirements, task boundaries, plan/spec references, current Decision Record, binding Global Constraints, and any relevant rulings. Attach the existing verification commands, scope, results, and output paths, tied to the same content. The checks already passed on that content, so a review boundary alone does not call for another run.
4. Send the task reviewer the current enriched task brief, implementer report, review package path, snapshot identity, relevant current-file paths, and the binding decisions and constraints. Request both spec-compliance and task-quality verdicts. The reviewer reads the actual changes and new-file contents, treats the implementer report as claims, and leaves the checkout, index, HEAD, and branch untouched. Missing evidence is an evidence gap to resolve; committing is unnecessary.
5. Resolve findings through the accepted workflow. Keep the exact snapshot each reviewer saw. For any uncommitted fix round, compare corrected contents against the previous reviewed snapshot, include relevant new files, and attach checks covering the amended content before scoped re-review. HEAD may remain identical through every round. A re-review receives the current brief, findings, appended fix report, prior/current snapshot identities, and fix package.
6. Record task completion directly in the ledger only after accepted requirements, required checks, and review are satisfied. Record its reviewed working-tree snapshot, changed paths, pre-existing-change boundary, test commands/results/scope/output paths, review outcome, and any decisions or nonblocking observations. State that no commit was created and that the current HEAD is only the baseline reference. Do not use a commit-only completion helper or invent a commit range to represent the work.
7. After all tasks are ready, build a final package for the entire authorized change against the plan's recorded starting state. Include all relevant staged and unstaged tracked changes and all relevant new untracked files, with a final snapshot and verification coverage. Send the final reviewer that package, accepted plan/spec, current Decision Record and rulings, review focus when present, and the ledger's deferred findings. Preserve unrelated edits and identify them separately. Record the final reviewed state and disposition of findings without committing.

Preserve the snapshots, reports, and decision evidence for recovery. The ledger's completion entry describes verified uncommitted content, not a backup; the work remains uncommitted and its continued existence must be checked after recovery.

## Scenario: uncommitted-recovery

### Exact input

```json
{
  "id": "uncommitted-recovery",
  "skill": "executing-plans",
  "prompt": "After compaction, an inline plan ledger says Task 1 complete with recorded working-tree evidence, not commits. The record includes the human's accepted scope and inline authorization. HEAD is unchanged, and inspection shows the task's expected uncommitted files no longer match the reviewed snapshot. Give the next actions and completion status. Do not treat recovery as permission to delete files, fabricate commit history, or repeat an unchanged design-approval question."
}
```

### Full output

Task 1's current files no longer match its reviewed state, so I cannot carry its earlier completion claim forward. The accepted scope and inline authorization still apply. I will reconcile the file changes and restore verified progress within that agreement.

1. Confirm the ledger belongs to this plan and read its task brief, Decision Record, recorded snapshot, changed-file manifest, review findings, and verification evidence. Preserve the previous completion entry as a historical record; append a recovery entry stating that current Task 1 completion is unverified because the working content differs.
2. Compare the current tracked and untracked task files with the retained reviewed contents and hashes. Check status and task-scoped diffs, including missing files and any new changes. An unchanged HEAD provides no evidence that uncommitted work survived. Establish whether files disappeared, were modified after review, or now contain another person's changes. If the retained artifact holds only hashes, report that it identifies the old state but cannot reconstruct file contents.
3. Preserve current files and unrelated work while investigating. Do not reset, clean, delete, overwrite intervening changes, or fabricate commits. Do not automatically restore a snapshot: it may discard legitimate later work. If the differences can be reconciled from the accepted requirements and available evidence, make the necessary bounded corrections under the existing implementation authorization. If conflicting user changes or missing evidence expose a material choice, present that specific conflict and hold only the affected correction; do not reopen unchanged design approval.
4. Keep Task 1 pending reconciliation and re-verification, and hold work that depends on its completion. Continue independent authorized tasks. Do not repeat tasks already shown to remain complete merely because the session compacted.
5. Verify the reconciled current implementation against Task 1's acceptance criteria. Reuse old results only where their relevant content and assumptions still match; run checks covering the changed or reconstructed content and any required integration surface. Review the changed state as required by the accepted inline workflow, including its final whole-change review, without inventing an additional per-task review gate.
6. Capture the reconciled working-tree snapshot and append evidence of the changed paths, recovery decisions, verification commands/results/scope, and review coverage. Mark Task 1 complete again only when current evidence supports that status. If needed content cannot be recovered or required checks remain unsatisfied, leave it pending and name that concrete limitation.

Current completion status: Task 1 was verified at its recorded historical snapshot; its present working-tree state is pending reconciliation and verification. Existing approval remains valid, and no new implementation approval is needed for unchanged scope.

## Scenario: decision-handoff

### Exact input

```json
{
  "id": "decision-handoff",
  "skill": "subagent-driven-development",
  "prompt": "The approved plan originally said 30-day retention. The human later approved 90 days and its stated cost, with evidence in the current Decision Record. A task-brief helper extracts only Task N from the plan and overwrites its output on each run, omitting the header Decision Record. You must dispatch an implementer, task reviewer, and then a fresh fix worker. Describe how each gets the current requirement and authority without reopening the settled decision or treating the worker's own report as approval."
}
```

### Full output

The operative requirement is 90-day retention at the cost the human approved. The current Decision Record supplies that authority and supersedes the plan's older 30-day requirement. Changing workers does not reopen the decision.

For every generation of the task brief, I will first run the extraction, then enrich its output before dispatch. The enrichment will carry the task-relevant Decision Record, its actual approval-message reference, the 90-day requirement and approved cost, binding Global Constraints, relevant rulings, execution authority, and any retained checkpoints. I will reconcile stale operative 30-day instructions in the generated task text and acceptance criteria with the approved 90-day change, retaining a clear note about what was superseded and why. I will read back the finished brief to confirm it contains no unresolved conflict about the retention value. An earlier append is insufficient because the helper overwrites its output.

The enriched brief will be the shared source of task requirements. I will preserve the version supplied to each actor, record its identity in the ledger, and avoid changing an in-flight brief invisibly. If the helper runs again, I will repeat the enrichment and verification before sending the new version. Exact requirement values belong in that brief; dispatch messages point to it and its authority rather than maintaining a competing task specification.

- **Implementer:** Send the enriched brief with instructions to read it first, plus the task's project context, relevant interfaces, report-file path, and task boundaries. The worker implements the current requirement under the recorded human authorization. It may resolve routine details, but must surface any new material conflict through the controller. Its report records implementation and test evidence; it is not permission to change retention or cost.
- **Task reviewer:** Send the same current enriched brief, implementer report, and package covering the actual implementation, together with the binding constraints and relevant rulings. The reviewer reads the approval source in the Decision Record and assesses the code against the current accepted requirement. The report's claims do not establish authority. Require both spec-compliance and task-quality verdicts, and do not instruct the reviewer to suppress findings about the approved approach.
- **Fresh fix worker:** After any necessary brief regeneration and enrichment, send the fresh worker the current brief, the original report with appended fix history, unresolved findings verbatim, relevant reviewed-state evidence, and the bounded fix assignment. Explain what was attempted only as needed to understand those findings. The worker receives the same human authority directly through the brief and Decision Record rather than inheriting it from the earlier implementer's assertions. It appends its fix and covering-test evidence to the report. If a finding appears to conflict with the accepted retention decision, the controller adjudicates it using current authority or raises only the new material choice; a worker does not silently replace 90 days with 30 days or another value.

For the subsequent scoped re-review, send the same enriched brief and authoritative record with the findings, appended report, and the fix diff against the prior reviewed state. Preserve the settled approval and the evidence identifying each handoff throughout the ledger and reports.
