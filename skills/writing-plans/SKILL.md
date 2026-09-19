---
name: writing-plans
description: Suggest when a multi-step change needs a durable implementation plan. Invoke only when requested or accepted.
---

Follow the [invocation policy](../using-superpowers/references/invocation-policy.md).
Apply this workflow only when requested or accepted, including its stated supporting steps.

# Writing Plans

Create a plan an engineer can execute without reconstructing the design.
State outcomes, boundaries, dependencies, and verification clearly. Use
exact procedures where interfaces or fragile operations require them;
leave routine implementation choices to the executor.

Read the [decision checkpoints](../using-superpowers/references/decision-checkpoints.md)
once. Carry accepted design decisions and delegated discretion into the plan.
A planning request does not automatically authorize implementation.

## Establish Scope

Inspect the request, approved design or combined packet, relevant code, and
existing instructions. Identify material open decisions and the requested
deliverable. Resolve those choices with your human partner before affected
implementation; do not re-ask settled questions.

For bounded work, a combined in-chat design/specification/plan may already
satisfy the need. Do not create a duplicate artifact unless requested or
needed for coordination, recovery, or handoff. For substantial work, save to
`docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`, or the chosen location.

If the design contains independent subsystems, separate plans when each can
deliver useful, testable behavior. Preserve their shared interfaces and
order. Do not split tightly coupled work merely to create more tasks.

## Define Deliverables and Interfaces

Map the affected files and each component's responsibility. Follow existing
patterns and avoid unrelated restructuring. Each task should have a
reviewable outcome, clear dependencies, and acceptance evidence.

Record exact interface names, signatures, formats, compatibility constraints,
and failure semantics when other tasks depend on them. Include code snippets
when they remove ambiguity or protect a fragile operation. A complete code
listing, fixed task duration, or separate task for every shell command is
not required.

Fold setup, configuration, and documentation into the deliverable they serve.
Specify behavior and useful verification rather than turning implementation
into transcription. Reuse helpers and interfaces already present.

## Plan Header

Use this header for durable plans; omit sections that are genuinely irrelevant
and explain any material unknowns. Keep `Spec`, `Global Constraints`, and task
headings compatible with the execution helpers.

```markdown
# [Feature Name] Implementation Plan

**Goal:** [Intended outcome and who it serves]

**Acceptance criteria:** [Observable behavior and boundaries]

**Architecture:** [Approach and affected components]

**Tech Stack:** [Relevant technologies and constraints]

**Spec:** [Existing design/spec path or a faithful summary of the approved chat packet]

## Decision Record

- Design/spec: [proposed, approved, or delegated; source of that authority]
- Plan: [proposed, approved, or delegated; remaining review decisions]
- Implementation: [authorized scope, or not yet authorized]
- Execution method: [chosen method, delegated choice, or unresolved]
- Retained checkpoints: [specific decisions the human wants to review]
- Changes and pending questions: [affected decisions and evidence]

## Global Constraints

[Applicable requirements, exact shared values, exclusions, and compatibility limits.]

## Review Focus

[Consequential cases, interactions, and failure modes; which checks cover them
and which risks require review or remain unverified. Do not invent a fixed count.]

---
```

The human's request and the current decision record govern authorization.
Do not put a mandatory execution command in the header of a plan-only artifact.

## Task Structure

Use a heading such as `### Task N: [Deliverable]` so the brief helpers can
extract it. The following is a template, not executable product code:

```markdown
### Task N: [Deliverable]

**Files:**
- Create/modify: [verified paths and responsibilities]
- Test: [relevant tests or other validation artifact]

**Depends on:** [prior deliverables or none]

**Interfaces:**
- Consumes: [exact shared contracts needed by this task]
- Produces: [exact contracts later tasks rely on]

**Acceptance:** [observable success and relevant failure behavior]

- [ ] Add meaningful regression protection for changed behavior where applicable.
- [ ] Implement the deliverable within the specified contracts.
- [ ] Run the required and risk-appropriate checks.
      Run: [concrete command, working directory, and prerequisites]
      Expected: [success condition and relevant failure signal]
- [ ] Update affected documentation and record evidence.

**Remaining decisions:** [none, or the material choice that blocks affected work]
```

Replace template placeholders with verified details in the actual plan.
Unknown requirements must be identified as unresolved, not filled with
invented code or assumptions. A plan may be delivered for review with open
decisions clearly marked; it is not execution-ready for the affected tasks.

For behavioral changes, use the TDD supporting guidance when applicable.
Documentation and low-impact metadata may need inspection or parsing instead.
Reuse still-relevant evidence; a task boundary does not require a rerun.
Include commit, isolation, publication, or cleanup steps only when authorized.

## Self-Review

Check that requirements map to deliverables, task interfaces agree, dependencies
are ordered, and verification covers meaningful behavior. Read the referenced
paths and commands; do not invent exact files, signatures, or completed results.

Resolve routine plan defects within the agreed design. Surface material
scope, behavior, data, cost, or approach changes through the shared checkpoint.
Review the affected parts again after substantive revisions; do not impose
a repeated review solely because a new message or document version exists.

## Execution Handoff

Present the finished plan or combined packet and state its decision status.

- **Plan only:** Link the artifact, identify open questions, and stop. Do not
  demand an execution-method choice merely to finish a planning request.
- **Review retained:** Ask for approval, revision, or explicit delegation of the
  unresolved plan decisions before affected implementation. Do not re-ask about
  the already-approved design.
- **Implementation already authorized, decisions covered:** Continue within
  that scope without a duplicate plan-approval question. A delegated plan is
  labeled delegated, not falsely described as human-reviewed.
- **Execution method unresolved and consequential:** Explain the tradeoff and
  ask, or select within explicitly delegated discretion. Preserve a method
  already chosen.

Inline execution uses executing-plans. Delegated execution uses
subagent-driven-development when useful, available, and selected. Explain
the actual tradeoff: coordination and independent review can help separable
work, while tightly coupled work may be clearer inline. Do not promise that
one method is always cheapest, fastest, or most thorough.

Pass the plan, specification, decision record, verification scope, and pending
work to the executor. After compaction or handoff, resume from those records
without restarting approved stages.
