# Design, specification, and plan decisions

Use this reference within an accepted design, planning, or execution workflow.
The [invocation policy](invocation-policy.md) governs whether that workflow
has been selected. A human should be able to shape the work before the
affected implementation begins, without being asked to approve unchanged
decisions again.

## Establish the current agreement

Read the request, prior decisions, repository context, and existing artifacts.
Identify the intended outcome, constraints, success criteria, and authorized
deliverable. Separate agreed facts, assumptions, open choices, and decisions
the human explicitly delegated. An instruction to implement a concrete
recommendation or approved plan authorizes that work within its scope.

Workflow acceptance alone does not authorize implementation, publication,
or unrelated work. A plan-only or review-only request ends with that artifact.
Approval covers what was presented; do not describe an unseen artifact as
approved. Explicit delegation can instead authorize you to develop the plan
and implement it within agreed constraints. Record that distinction.

## Prepare a reviewable checkpoint

Investigate enough to make the choices concrete. Ask focused questions when
an answer could change requirements, behavior, compatibility, data handling,
cost, risk, or approach. Group related questions when that makes the decision
easier; do not force one question per turn or invent alternatives when the
evidence already settles the choice.

Present the useful decision material:

- Outcome, proposed behavior, constraints, acceptance criteria, and exclusions.
- Assumptions and material open choices; relevant alternatives and tradeoffs.
- Affected components, interfaces, data flow, and failure behavior.
- Implementation sequence, dependencies, and verification appropriate to risk.

For bounded work, one concise in-chat packet can cover design, specification,
and plan. For substantial work, use staged reviews and durable artifacts,
stating which decisions each stage settles. Do not require a second approval
merely because the same agreed content was copied into a document.

## Proceed or wait

If the necessary decision is unresolved, give the human a concrete opportunity
to approve, revise, or delegate it before implementing the affected behavior.
Wait for their response; silence and elapsed time are not acceptance. Explain
the relevant checkpoint when it causes a pause. Continue independent work
already authorized while an answer is pending, using the host's question tools.

When the same scope is already approved or decisions are explicitly delegated,
acknowledge that agreement and continue. Do not restart design approval when
writing a plan, choosing routine implementation details, changing executors,
or recovering after compaction. Honor any explicit review checkpoint the
human retained despite delegating other decisions.

## Changes and recovery

Reopen only decisions materially affected by new evidence or a changed request.
Explain the difference, alternatives, and consequences. Hold affected work;
continue independent authorized tasks. Routine details within agreed scope
can be resolved from project evidence and recorded without a new checkpoint.
A worker reports a material choice to the controller; the controller answers
from existing authority or asks the human rather than inventing approval.

Keep a compact decision record in the existing spec, plan, or ledger; bounded
chat work does not need a separate file. Record the accepted outcome and
constraints, proposed/approved/delegated status, source of that authority,
execution scope and method, retained checkpoints, changed decisions, and
pending work. After compaction, check the record against the conversation
and current artifacts, then resume. Resolve a material conflict in the record;
do not repeat questions solely because the context was summarized.
