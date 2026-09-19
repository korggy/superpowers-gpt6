---
name: brainstorming
description: Suggest when a material design decision needs discussion. Invoke only when requested or accepted.
---

Follow the [invocation policy](../using-superpowers/references/invocation-policy.md).
Apply this workflow only when requested or accepted, including its stated supporting steps.

# Brainstorming Ideas Into Designs

Help turn an idea into a shared understanding, reviewable design, and useful
specification before the affected implementation begins. Read the
[decision checkpoints](../using-superpowers/references/decision-checkpoints.md)
once for approval, delegation, changed scope, and recovery rules.

## Establish Shared Understanding

The outcome of brainstorming is an understanding your human partner can
recognize and correct, grounded in what they want to accomplish.

1. **Discover intent.** Use the request and available context to identify
   the intended outcome, who it is for, and what success looks like. When
   that information is missing, ask one focused question about purpose or
   intended use before proposing features or an approach. Knowing the app
   genre does not tell you why your partner wants it. Gathering missing
   requirements does not ask them to authorize the task again.
2. **Write back your understanding.** Summarize the intended outcome,
   relevant constraints, and success criteria in a short note your partner
   can assess. Separate what they said from assumptions. Invite correction
   and incorporate their answer before treating this as the design brief.
3. **Carry intent into the design.** Preserve the agreed understanding in
   the selected path's design artifact: the written spec for architectural
   work, or the in-chat design/probe for bounded work and spikes. Check
   proposed features and technical choices against that understanding.

When the request already supplies the purpose and constraints, reflect
that understanding instead of asking the same questions again. Keep the
note concise; its accuracy and the opportunity to correct it matter.

A previously accepted understanding satisfies this step. Do not require a
second confirmation merely to restate it in a document.

## Choose the Review Scale

Scale the work to uncertainty, dependencies, and consequences. Explain the
chosen scale when it helps your human partner shape the discussion.

- **Investigation:** Define the question, evidence needed, and bounded probe.
  If the human already requested that investigation, proceed within its
  scope. Ask about material missing constraints before the affected action.
  Report a recommendation; a throwaway probe does not authorize a product change.
- **Bounded change:** Use one concise in-chat packet for design, specification,
  and plan. Include the intended behavior, acceptance criteria, assumptions,
  affected components, implementation sequence, and verification. No separate
  spec or plan file is needed unless requested or useful for handoff.
- **Substantial change:** Review material design decisions in stages, then
  preserve the specification and implementation plan in durable artifacts.
  State which decisions each review settles. New subsystems, interface changes,
  and migrations commonly need this depth; the label alone does not determine it.

Reassess the scale when evidence changes. Add detail where needed; do not
restart settled decisions or require a heavier path solely because one was
chosen earlier. Unresolved material choices stay open until answered or
explicitly delegated.

## Discuss the Design

1. **Ground the discussion.** Read existing behavior, relevant instructions,
   docs, tests, and interfaces. Follow established patterns. Identify the
   intended outcome, constraints, exclusions, and success criteria.
2. **Resolve useful questions.** Ask only questions whose answers could change
   the result. Group related choices when helpful. When a request spans
   independent subsystems, agree on their boundaries and implementation order.
3. **Compare real alternatives.** Explain meaningful tradeoffs and recommend
   an approach. Do not invent a fixed number of alternatives when evidence
   already establishes a suitable one.
4. **Present a reviewable packet.** Describe behavior and acceptance criteria,
   components and interfaces, data flow, failure handling, implementation
   sequence, and verification. Include assumptions and unresolved decisions.
   A bounded packet may be a few paragraphs; larger designs may need sections.
5. **Settle the checkpoint.** Let your human partner approve, revise, or
   explicitly delegate remaining decisions before affected implementation.
   Do not implement while waiting for an unresolved decision. If the same
   packet is already approved, or the human explicitly authorized you to
   develop and implement it within stated constraints, continue under that
   authority. Preserve any review checkpoints they retained.

Approval of an idea alone does not imply approval of a future spec or plan.
Explicit delegation can cover developing those artifacts and proceeding
within agreed scope. Record whether a decision was approved or delegated;
do not claim an unseen artifact was reviewed.

## Design for the Existing Project

Give units clear responsibilities and interfaces that can be understood and
tested independently. State what each component does, what it consumes,
and what it produces. Keep related changes together and use the project's
established architecture.

Include a targeted structural improvement only when it serves the requested
outcome. Do not add unrelated refactoring or features. Verification should
establish acceptance criteria and consequential failure behavior, rather
than reproduce implementation details.

## Preserve the Specification and Decisions

For substantial work, save the spec to
`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`, or the human's chosen
location. A document that faithfully records an approved packet does not
need a second approval just because its format changed. If writing reveals
a material new decision, bring that decision back for review.

Self-review the spec for missing acceptance criteria, contradictions,
undefined interfaces, untested assumptions, and scope gaps. Resolve routine
details from evidence; ask about material ambiguity instead of silently
choosing requirements. Do not leave an unresolved choice disguised as a
finished requirement.

Use the existing spec, plan, or chat as the
[decision record](../using-superpowers/references/decision-checkpoints.md#changes-and-recovery).
Retain the agreed outcome, constraints, approval or delegation source,
execution scope, method, and remaining checkpoints. Commit only when
authorized by the human or applicable project instructions.

## Handoff

- **Design-only or investigation-only request:** Deliver the design or findings
  and stop at that requested boundary.
- **Bounded implementation authorized:** Continue from the accepted combined
  packet using the agreed development method and appropriate verification.
- **Substantial planning authorized:** Use writing-plans as the supporting
  step, carrying forward the accepted decisions and any retained plan review.
- **Implementation not yet authorized:** Present the completed artifact and
  identify the concrete decision needed before implementation.

Do not restart workflow selection or seek approval of unchanged decisions.
If implementation uncovers a material change, hold the affected work and
reopen that decision while continuing independent authorized tasks.

## Red Flags

| Thought | Reality |
|---|---|
| "I know this kind of app, so I know the goal" | Establish the human's outcome and constraints from their request and context. |
| "The change is small, so I'll code while they review it" | Small work can use one short packet; an unresolved checkpoint still requires an answer. |
| "They approved this already, but now it is in a document" | Preserve the prior decision; ask again only about material changes. |
| "They said use judgment, so every decision is mine" | Delegation has a scope. Honor constraints and checkpoints they retained. |
| "The spike works, so I'll keep the code" | A requested investigation does not authorize a product change. |
| "The design changed, so all prior approvals are void" | Reopen only affected decisions and preserve the rest. |

## Visual Companion

A browser-based companion for showing mockups, diagrams, and visual options during brainstorming. Available as a tool — not a mode. Accepting the companion means it's available for questions that benefit from visual treatment; it does NOT mean every question goes through the browser.

**Offering the companion (just-in-time):** Do NOT offer it upfront. Wait until a question would genuinely be clearer shown than told — a real mockup / layout / diagram question, not merely a UI *topic*. The first time that happens, offer it then, as its own message:
> "This next part might be easier if I show you — I can put together mockups, diagrams, and comparisons in a browser tab as we go. It's still new and can be token-intensive. Want me to? I'll open it for you."

**This offer MUST be its own message.** Only the offer — no clarifying question, summary, or other content. Wait for the user's response. If they accept, start the server with `--open` so their browser opens to the first screen automatically. If they decline, continue text-only and don't offer again unless they raise it.

**Per-question decision:** Even after the user accepts, decide FOR EACH QUESTION whether to use the browser or the terminal. The test: **would the user understand this better by seeing it than reading it?**

- **Use the browser** for content that IS visual — mockups, wireframes, layout comparisons, architecture diagrams, side-by-side visual designs
- **Use the terminal** for content that is text — requirements questions, conceptual choices, tradeoff lists, A/B/C/D text options, scope decisions

A question about a UI topic is not automatically a visual question. "What does personality mean in this context?" is a conceptual question — use the terminal. "Which wizard layout works better?" is a visual question — use the browser.

If they agree to the companion, read the detailed guide before proceeding:
`skills/brainstorming/visual-companion.md`
