---
name: executing-plans
description: Suggest for inline execution of an accepted implementation plan. Invoke only when requested or accepted.
---

Follow the [invocation policy](../using-superpowers/references/invocation-policy.md).
Apply this workflow only when requested or accepted, including its stated supporting steps.

# Executing Plans

Execute the plan yourself, task by task, in this session: no implementer
subagent per task, no reviewer per task. One fresh-context review of the
whole branch at the end.

**Why inline:** Subagent-driven development pays for a fresh implementer
and a fresh reviewer on every task, each re-reading the codebase from zero.
Inline execution pays for one context (yours) plus one reviewer at the end.
What it gives up is a fresh context per task and a second pair of eyes per
task. This skill keeps what those two things bought, by other means: the
brief is the spec, the ledger is your memory, TDD is the per-task gate, and
the final reviewer is the second pair of eyes.

**Core principle:** Implement the agreed outcomes and constraints, verify
with evidence appropriate to risk, and leave a record that survives compaction.
Follow the shared [decision checkpoints](../using-superpowers/references/decision-checkpoints.md).

**Narration:** Follow the host's and human's communication preferences. Give
concise progress updates about findings, decisions, and remaining work.

**Continuous execution:** Continue through authorized tasks without routine
"should I continue?" prompts. Honor existing approvals and delegated decisions.

**Decisions within scope.** Resolve routine details using the agreed spec,
current instructions, and repository evidence. Record consequential decisions
as `Ruling: <decision> — <authority and reason> — <cost if wrong>`.
A ledger entry records authority; it does not create it.

If new evidence changes requirements, acceptance criteria, cost, risk, or the
agreed approach beyond delegated discretion, present the affected choice to
your human partner and wait before that implementation. Continue independent
authorized tasks. Preserve explicitly retained review checkpoints. Follow
host permissions for other actions, using authorization already supplied.

## When to Use

- You have a plan from superpowers:writing-plans and your human partner
  chose inline execution at the handoff.
- Your harness has no subagent tool (see the per-platform references in
  `../using-superpowers/references/`). Never fabricate a dispatch; run
  the plan here.
- Tasks are mostly independent — the same precondition as
  superpowers:subagent-driven-development.

Choose inline execution when shared context and direct implementation fit the
work. Cost and review quality depend on the task and available host; do not
promise a universal model tier or savings.

Prefer superpowers:subagent-driven-development when your human partner
wants a review gate on every task, or when the plan is long enough that
its later tasks would run on a compacted context. Inline execution over a
long plan still works — the ledger is what makes it recoverable — but the
last tasks get the least of you.

## The Process

1. Read the accepted plan and decision record; establish the working context.
2. Read each task brief, implement its outcome, and verify required behavior.
3. Resolve routine details within authority; hold affected work for material
   choices while continuing independent tasks.
4. Record completion only when acceptance criteria and required checks pass.
5. Review the complete change, correct substantiated findings, and deliver
   the authorized result. Integrate or clean up only within requested scope.

## Setup

Preserve the named checkout and branch. Use superpowers:using-git-worktrees
when isolation is requested or included in the accepted workflow. Follow
repository restrictions and existing authorization before changing Git state.

Conversation memory does not survive compaction. An inline executor that
loses its place re-implements tasks whose commits already exist — the same
failure as a controller re-dispatching them, paid for in your own context.
Track progress in a ledger file, not only in todos. Harness todos are a
live view; the ledger is the record.

The workspace and ledger are shared with superpowers:subagent-driven-development
— same directory, same format — so a plan can change executors mid-flight
and the new one resumes from the same ledger.

- Each plan owns a workspace: at skill start, run
  `bash ../subagent-driven-development/scripts/sdd-workspace PLAN_FILE` — it
  prints the plan's git-ignored directory
  (`<repo-root>/.superpowers/sdd/<plan-basename>/`), home to every
  artifact for THIS plan: ledger, briefs, review packages. Another plan's
  directory is never yours to read or write.
- Check this plan's ledger at `<workspace>/progress.md`. Match its plan
  identity and reconcile completion entries with the current repository and
  evidence. For committed work, inspect the named commits; for uncommitted work,
  inspect the recorded files/snapshot and current diff. Resume pending work
  without repeating settled questions. A completion line alone does not prove
  uncommitted files still exist. Leave other plans' ledgers untouched.
- Create the ledger with its identity as the first line:
  `# SDD ledger — plan: <plan file path>`.
- The workspace is ignored scratch. Cleanup can destroy its evidence, and
  Git history cannot recover uncommitted work. Do not rely on it as a backup.

Read the plan, its Decision Record, Global Constraints, and referenced spec.
Confirm implementation is authorized; a plan-only request stops with the plan.
Carry approved and delegated decisions, their sources, pending choices, and
retained checkpoints into the ledger and task briefs. Current human corrections
take precedence over older artifacts. Check the record when resuming; do not
repeat settled questions. If a spec is missing, use the available agreement and
resolve only material gaps before affected work. Create a todo per task.

**REQUIRED SUB-SKILL:** load superpowers:test-driven-development now,
before Task 1. It governs every step of every task below; a plan whose
steps already say "write the failing test first" does not exempt you
from reading it.

Before Task 1, scan the plan for conflicts between tasks. The plan's
Interfaces blocks tell you where to look: for every task that consumes
what an earlier task produces, one ledger row — the two tasks, what one
produces against what the other consumes, and what you found. Tasks that
share nothing get no row; a plan whose tasks share nothing gets the single
line `Pre-flight: no shared interfaces`. Resolve routine conflicts within
existing authority and record them beside their rows. Raise material choices
under the decision checkpoints; start independent authorized tasks meanwhile.
Each task's own text is checked when you read its brief.

## The Task Loop

The brief helper extracts only task text. Carry the Decision Record and Global
Constraints from setup alongside each brief; they are not embedded by the helper.

Everything you print, and every tool result, stays resident in your
context for the rest of the session. Redirect long test output to a file
in the workspace and read its tail; read a brief, not the whole plan.

### 1. Take the task

- Run this skill's `bash scripts/task-start PLAN_FILE N`. It prints the brief
  path and BASE (the commit the task's range is cut from) in one call.
  Record relevant existing working changes as well; BASE alone does not capture
  them. Read the brief for every task, including ones you remember from setup:
  what you remember is a summary, the brief has the exact values,
  signatures, and test cases.
- Mark the task's todo in_progress.

Every tool call is a turn that re-reads your whole context. Bookkeeping
rides along with work — a ledger append in the same call as the commit,
never in a call of its own.

### 2. Work the steps

Follow task dependencies and acceptance criteria. Use the selected TDD guidance
for behavioral changes; use appropriate inspection or validation for low-impact
changes. Verify a regression test reproduces the intended defect before relying
on it. Do not invent tests solely to make a prose plan look executable.

For each required command, check its prerequisites and expected result, run
it when relevant evidence is missing, and compare the output. Three outcomes:

- **Matches.** Next step.
- **The code is wrong.** Use superpowers:systematic-debugging. Find the
  cause; never patch the symptom to make the step's output match.
- **The plan is wrong** — a step contradicts the spec, an interface from an
  earlier task doesn't match what this task consumes, a command that
  cannot work. Correct routine details within the accepted scope and record
  the evidence and authority. A material change needs the affected decision
  resolved first. Carry the decision into later briefs that use that interface.

Commit only when authorized. A task that spans several commits
is fine; BASE is what the review range is cut from, never `HEAD~1`.

### 3. The completion contract

Before a task's ledger line, all of the following are true, with evidence
in this session — not inferred from the diff looking right:

- Every required check in the brief has relevant evidence, and you read
  its output. Record scope adjustments using the TDD and verification guidance.
- The task's verification passed. Run it through `task-done` once when needed;
  if already run on unchanged relevant content, record its command, result,
  scope, and evidence path directly in the ledger rather than rerunning it.
- Every `Expected:` line in the brief was compared against real output.
- Every deviation from the brief has a `Ruling:` line in the ledger.

**REQUIRED SUB-SKILL:** superpowers:verification-before-completion governs
the claim. If any item is missing, the task is not complete: finish it.

### 4. Complete the task

For uncommitted work, record checks and the reviewed working-tree state directly
in the ledger; the helper's commit-only completion line cannot identify it.
For committed work needing a new run, run this skill's
`bash scripts/task-done PLAN_FILE N BASE -- <verification command>`
with the appropriate command from the brief. Otherwise record existing
evidence directly as described in the completion contract, then advance.
The helper runs the
tests, keeps the full output in the workspace, prints the tail, and — only
if they pass — appends the completion line to the ledger:

`Task <N>: complete (commits <base7>..<head7>, tests: <command> → <result>)`

A failing run records nothing; the task is not complete. When it records,
mark the todo complete and take the next task.

## Final Review

Build the review package using
[review evidence](../subagent-driven-development/review-evidence.md). Use the
commit-range helper for fully committed scope; include current tracked and new
untracked files for uncommitted or mixed work. A review must cover the actual
implementation, even when HEAD has not changed.

**With an authorized subagent tool:** choose a reviewer suited to the scope,
complexity, and risk using the host's allowed models and effort levels. Use
superpowers:requesting-code-review's
[code-reviewer.md](../requesting-code-review/code-reviewer.md), with the
package path, the plan and spec paths, the plan's Review Focus section
verbatim if it has one (the input classes and failure modes the plan's
tests do not exercise — the reviewer checks each deliberately), and a
pointer to the ledger's `Ruling:` lines so it can weigh the calls you
made. Follow the current host's model and context-fork rules. Explicit overrides
require a compatible fork mode; see the platform reference. This is the one fresh context the whole run buys. Do not
skip it, and do not replace it with your own read of the diff.

**Without a subagent tool:** read code-reviewer.md and perform that review
yourself against the package, as a separate pass after the last task's
ledger line. Write `Final review: self-review (no subagent tool)` to the
ledger, and say so in your final message: a self-review by the author is
weaker than a fresh reviewer, and your human partner decides whether that
is enough before merge.

Sort findings by evidence, scope, and authority before severity. The reviewer's
label does not establish a requirement or authorize a product decision.

- **Correctness defect:** A substantiated failure of the requested behavior or
  an existing contract remains a defect even if the spec did not enumerate the
  trigger. Data loss on an ordinary failed save is one example. Grade the actual
  consequence and correct it within existing authority.
- **Unresolved product choice:** New features, defaults, policy, and tradeoffs
  are proposals when the request and decision record do not settle them. Present
  the evidence, options, and recommendation to the human before affected work,
  or use explicit delegated discretion. Continue independent authorized fixes.
  Keep required open decisions pending; do not declare the whole task complete.
- **Optional improvement:** Record it as nonblocking when it is outside the
  accepted requirements and does not repair a correctness defect.

Apply these distinctions to the reviewer's "Declined to judge" list too. Record
consequential rulings with their authority and reason; a ledger entry cannot
turn an assumed preference into an accepted requirement. Within authorized scope:

- **Critical and Important** enter the fix pass.
- **Minor** goes to the ledger as `Final: minor (deferred): <one-liner>`
  and to your final message under "Deferred minors". Minors never enter
  the fix pass, and never become rulings — a ruling is a decision about a
  conflict, not a note that you declined a polish suggestion.

Fix the Critical and Important findings yourself. Use a regression test
for a reproducible behavior defect and appropriate inspection or validation
for low-impact prose or metadata changes. Run required project checks and
risk-appropriate integration checks, reusing results for unchanged content.
Record each fix, its verification scope, command, result, and evidence path
in the ledger. Classify unrelated baseline or environment failures separately.
A new review is useful only when changes introduce unresolved risk or the
first review identified a need for it.

A finding you decide not to fix is a ruling — `Final: Ruling: <finding> —
<why the code stands> — <cost if wrong>` — and reaches your human partner
in the rulings list. Required behavior cannot be deferred by a unilateral
ruling. Resolve any material scope change with the human or existing delegation;
keep incomplete work pending. Continue until authorized corrections and required
checks are complete.

## Finish

Before you delete anything, collect every ledger line containing
`Ruling:` into your final message under "Rulings I made", in the order you
made them, each with what it costs if wrong, and every `minor (deferred)`
line under "Deferred minors". Both lists are exhaustive. Your final
message is the only place the decisions you took on your human partner's
behalf — and the findings you chose not to act on — reach them.

Preserve the decision record and verification evidence needed for recovery.
Follow the repository's existing guidance and the user's instructions for
integration and cleanup. Completion of this workflow does not itself authorize
commits, publication, merging, or deletion of a workspace or recovery evidence.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I remember what Task N says" | You remember a summary. The brief has the exact values. Read it. |
| "The plan's code is right, so no regression evidence is needed" | Use evidence that distinguishes the defect from correct behavior. Reuse a valid recorded failure; add missing regression protection without deleting valid work or inventing a failure. |
| "The tests passed, but task completion needs another run" | Record still-valid evidence directly. Run only missing or invalidated checks; a ledger entry, commit, or task boundary does not require another run. |
| "The plan is wrong here, I'll just do the right thing" | Resolve routine details within authority; ask about material changes and record the decision. |
| "I'll write the ledger lines after a few tasks" | Compaction does not wait for a convenient moment. One line per task, in the same message as the commit. |
| "Let me check in before the next task" | Continue authorized work. Ask only about an unresolved material decision or retained checkpoint. |
| "I read my own diff carefully; the final reviewer is redundant" | Same author, same blind spots. The reviewer is the only fresh context this run buys. |
| "It was trivial, so no evidence is needed" | Match the evidence to the change: meaningful regression checks for behavior, or appropriate inspection/parsing for low-impact edits. Complete required checks and record the observed result. |
| "Subagents are slow and expensive, I'll skip the final review too" | Inline already removed the per-task reviewers. One review of the whole branch is the floor, not the ceiling. |
| "The reviewer called it Important, so the requirement is settled" | Establish whether it is a correctness defect, an unresolved product choice, or an optional improvement. Severity does not supply missing authority. |
| "The fix is obvious, no verification needed" | Use evidence that can detect the defect. Behavioral regressions usually need tests; low-impact prose or metadata may need inspection or parsing. |
| "I'll fix the minors too while I'm in there" | Keep scope bounded. Record deferred findings for your partner. |

## Example Workflow

```
You: I'm using the executing-plans skill to implement this plan inline.

[Setup: worktree verified]
[Read plan once: docs/superpowers/plans/feature-plan.md; spec read]
[Resolve workspace: sdd-workspace docs/superpowers/plans/feature-plan.md — no ledger inside, fresh start]
[Pre-flight scan: 2 shared-interface rows, 4 self-consistency rows, clean; written to ledger]
[Create todos for all tasks]

Task 1: Hook installation script

[task-start plan 1 → brief read; BASE a1b2c3d]
[Step 1: write failing test — written]
[Step 2: run it — FAIL: install_hook not defined. Matches Expected.]
[Step 3: implement — written]
[Step 4: run it — PASS 1/1. Matches Expected.]
[Step 5: commit — d4e5f6a]
[Contract: tests ran, output read, no deviations]
[Record the existing npm test -- hooks result, command, scope, and evidence path
 directly in the ledger. Tested content is unchanged; do not call task-done again.]
[Ledger: Task 1 complete; commits a1b2c3d..d4e5f6a; existing evidence covers current content]

Task 2: Recovery modes

[task-start plan 2 → brief read; BASE d4e5f6a]
[Step 2: run failing test — FAIL, but on an import error: Task 1 exported
 installHook, brief consumes install_hook]
[Ruling: brief's consumer name is a typo against Task 1's Produces block;
 use installHook — Ledger: Task 2: Ruling: install_hook → installHook — matches Task 1 Produces — cost if wrong: one rename]
[Re-run after correcting the brief: fails for the intended missing recovery behavior]
[Implement recovery; authorized commit b7c8d9e]
[Required verification has not yet run on the implemented content]
[task-done plan 2 d4e5f6a -- npm test -- recovery → ledger: Task 2: complete (commits d4e5f6a..b7c8d9e, tests: npm test -- recovery → 8/8 pass)]

...

[After all tasks: review-package plan MERGE_BASE HEAD; dispatch code-reviewer with capability appropriate to the review]
Reviewer: One Important finding — failed repair discards the saved index. Two Minor.
[Re-grade: Important stands; minors → ledger as deferred]
[Fix pass: test_failed_repair_preserves_index RED → preserve saved data on failure → GREEN; suite 12/12; authorized commit]
[Ledger: Final: fixed failed-repair data loss — test_failed_repair_preserves_index RED→GREEN, suite 12/12]

Rulings I made:
- Task 2: install_hook → installHook (brief typo; cost if wrong: one rename)

Deferred minors:
- README lacks a usage example
- recovery.js could split verify/repair into two files

[Preserve the decision record and recovery evidence]

Follow the repository guidance for any authorized integration or cleanup.
```
