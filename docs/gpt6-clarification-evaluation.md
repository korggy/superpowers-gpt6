# Clarification and prompting integration evaluation

Date: 2026-09-19. Baseline: `559ef1eaa71fc9f810afb7a93b1d4bbcd7f3f1c1`
(`gpt-6 specialization 1`). This evaluates the accepted follow-up proposals,
not the earlier infrastructure changes.

## Scope and method

Implemented shared decision checkpoints across brainstorming, planning, inline
execution, and delegated execution. Updated plan and worker handoffs, authoring
guidance, and a dated Codex prompting-guide reference. Invocation remains opt-in;
the existing brainstorming intent section and Visual Companion are preserved.

The baseline skills were frozen before edits at
`C:/CodexTools/superpowers-clarification-eval-20260919-2d523a43/baseline-skills`.
Initial pre-edit probes informed the change. The recorded comparison below uses
identical scenario inputs with that frozen baseline and candidate files in
separate fresh-context workers. The reusable fixtures and rubric were recorded
after initial drafting; this was a development evaluation, not a preregistered
experiment or held-out benchmark.

Three control workers covered eight scenarios; three fresh candidate workers
covered those eight plus retained-review and unanswered-question cases. A
subsequent candidate worker covered three review/handoff cases after independent
review exposed integration gaps. Related cases shared a worker, so within-probe
context may influence results. Candidate plan, execution, and handoff workers inadvertently
saw the full input catalogue before filtering their assigned cases; they did not
see the grading rubric, control guidance, or other outputs.

These are simulated next-response/next-action probes, not product implementation
runs. Workers inherited the active Codex session model; exact build and reasoning
effort were not exposed in the recorded evidence. No model overrides were set.

## Recorded comparison

| Scenario | Baseline | Candidate |
|---|---|---|
| Bounded first review | Presented a concise design and waited for the first decision. | Presented one design/spec/plan packet and waited. Retained pass. |
| Approved packet | Continued inline without another approval. | Continued inline without another approval. Retained pass. |
| Plan-only request | Delivered a plan but added an unnecessary future execution-method question. | Delivered the plan and stopped without an executor questionnaire. |
| Delegated plan and implementation | Honored current user authority over the default review gate. | Recorded delegation accurately and continued inline without reapproval. Retained pass. |
| Material retention/cost change | Held affected work, asked the human, continued independent labels; worker routed through controller. | Same boundaries, with explicit decision-record handoff. Retained pass. |
| Resume approved change | Used the existing 90-day approval and preserved completed work. | Same, carrying approval/cost/source into the brief. Retained pass. |
| Review limit with required failure | Recorded `complete (..., 1 parked)` while admitting an acceptance criterion still failed. | Kept the task incomplete and reassessed; no completion entry or unilateral waiver. |
| Unchanged verification evidence | Reused existing passing checks. | Reused existing passing checks. Retained pass. |

Candidate-only cases: the retained plan-review checkpoint stayed pending despite
delegation of routine details; an unanswered retention question did not become
approval after two minutes, and independent authorized work could proceed.

This is qualitative smoke evidence: one response per scenario per arm. Six of
eight matched cases retained passing behavior. Two removed observed undesirable
actions. It does not establish a success rate, speedup, or token/cost reduction.
Tool counts, scenario wall time, and tokens were not collected; planned checks
and questions are not measurements of executed completion effort.

## Independent review and targeted corrections

An independent reviewer found three connected integration gaps:

1. Optional commits left commit-only review/completion helpers unable to identify
   uncommitted implementation.
2. Extracted task briefs omitted the plan-header Decision Record; reviewers and
   replacement workers could miss current authority.
3. Reviewer templates retained mandatory model overrides despite host-led selection.

Corrections added [review-evidence.md](../skills/subagent-driven-development/review-evidence.md),
working-tree snapshot/recovery rules, decision/constraint refresh after extraction,
and matching task, fix, and final-review templates. The helpers remain unchanged;
the workflow selects an appropriate evidence path. Targeted independent rereview
confirmed all three findings resolved.

The three targeted candidate probes also met their criteria:

| Scenario | Observed decision |
|---|---|
| Uncommitted review | Included staged, unstaged, and relevant new-file contents; separated unrelated edits; recorded reviewed snapshots without committing. |
| Uncommitted recovery | Kept the mismatched task pending, preserved current files, and reused existing authority without reopening design approval. |
| Decision handoff | Refreshed authority and constraints after each extraction and supplied the same current brief to implementer, reviewer, and fresh fix worker. |

Across the development probes, all 13 distinct candidate scenarios met the
stated decision criteria. This remains single-sample, grouped-context evidence
with the input-access limitations described above.

## Structural and executable checks

- `node --test tests/gpt6/compatibility.test.mjs`: **6 passed, 0 failed**.
  Covers opt-in metadata, Codex startup notice, Kimi/Gemini loading, packaging and
  sync metadata precedence, and Native helper Bash invocation.
- Frontmatter and opt-in metadata validated for all seven changed skill entrypoints.
- Local links in changed documents checked for existing targets.
- Existing brainstorming intent text and entire Visual Companion compared with
  the baseline and preserved verbatim.
- The new plan template's task block was extracted through the real
  `task-brief` helper, preserving task acceptance content and excluding Task 2.
  The check confirmed headers are not extracted; the updated handoff explicitly
  refreshes decision context after extraction.
- Scenario JSON parsed with unique IDs and valid skill references.
- `git diff --check`: passed.

The isolated validation script and fixtures are in the local evaluation directory.
The source checkout was updated without installing the plugin, committing,
pushing, or changing model settings. These checks do not prove live startup or
behavior on every supported harness.

## Evidence

Inputs and rubric: [scenario catalogue](../tests/gpt6/clarification-scenarios.json),
[protocol and expected outcomes](../tests/gpt6/README.md).

Recorded complete inputs and responses:

- [Control design](../tests/gpt6/results/2026-09-19-clarification/control-design.md)
- [Candidate design](../tests/gpt6/results/2026-09-19-clarification/candidate-design.md)
- [Control planning](../tests/gpt6/results/2026-09-19-clarification/control-plan.md)
- [Candidate planning](../tests/gpt6/results/2026-09-19-clarification/candidate-plan.md)
- [Control execution](../tests/gpt6/results/2026-09-19-clarification/control-execution.md)
- [Candidate execution](../tests/gpt6/results/2026-09-19-clarification/candidate-execution.md)
- [Candidate review/handoff](../tests/gpt6/results/2026-09-19-clarification/candidate-handoff.md)

The main comparison ran during drafting. Subsequent edits were confined to
review evidence, recovery, handoff context, and template synchronization; those
paths received targeted follow-up probes and review. Results should not be
interpreted as every scenario rerun on the final tree.
