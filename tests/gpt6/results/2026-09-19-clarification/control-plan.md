# Baseline writing-plans decision probes

These are independent simulated decisions, not an implementation or a claim that a production plan has been saved. Only the assigned baseline writing-plans skill and invocation policy were applied. The baseline documents did not reference a separate decision reference.

## Scenario: plan-only

### Scenario input
{
  "id": "plan-only",
  "skill": "writing-plans",
  "prompt": "The human selected writing-plans and requested only a plan for an approved customer-approval subsystem design. Two distinct managers must approve, rejection returns the item to its author, and every transition is audited. Repository inspection confirms modular service, storage, UI, and unit-test patterns. No exact paths or signatures are supplied in this probe, so do not invent them. Give the planned document structure, an illustrative task shape, and the final handoff message. This request does not authorize implementation."
}

### Complete response

I'm using the writing-plans skill to create the implementation plan. I'll keep this request to planning the approved subsystem: two distinct managers must approve, rejection returns the item to its author, and every transition is audited.

The plan will begin with the required implementation-plan header and include:

- Goal, architecture, confirmed technology stack, and the verified location of the approved design.
- Global constraints copied from the approved design, including the approval, rejection, and audit requirements.
- A file map identifying verified service, storage, UI, and unit-test files and each file's responsibility. I will inspect the actual repository before supplying paths or signatures.
- Review Focus covering repeated decisions by the same manager, concurrent approvals, concurrent rejection and approval, failures while persisting audit records, and stale UI decisions. Where the approved design does not settle an externally visible outcome, the plan will identify that decision rather than invent a requirement.
- Independently testable tasks with exact files and interfaces, test code, failure and success commands, implementation code, and scoped commit steps. Setup and documentation belong to the task that needs them.
- A final verification sequence and an explicit statement that implementation requires separate authorization.

An illustrative task is “Enforce distinct-manager approval and audit persistence.” Its real file list and callable interfaces will come from repository inspection. Its steps will be:

1. Add focused tests using existing fixtures for a first manager's approval, a second distinct manager's approval, and a repeated decision by the first manager. Assert that only two distinct manager approvals satisfy the approval requirement and that every resulting transition has its audit record.
2. Add the design's agreed failure and concurrency cases to this same task, including verification that audit persistence failure cannot leave a completed transition without its required audit record.
3. Run the exact existing unit-test command for these cases and verify that the new behavior is what causes failure.
4. Implement the smallest change in the existing service and storage patterns, using the repository's verified interfaces and transaction approach.
5. Run those tests and the directly affected existing tests, then inspect the resulting diff.
6. Commit the implementation and its tests together when implementation is separately authorized.

The completed plan will contain the actual test and implementation code for those steps. This illustration deliberately does not invent repository paths, signatures, or commands.

I'll self-review the plan for design coverage, missing content, interface consistency, and tests for each Review Focus item. I will then save it in the established plans location and provide its actual link.

Final handoff wording, to be used only after that save and review:

“The plan is complete and saved; the linked document contains the implementation tasks and verification steps. Please review whether it captures the approved design. For later implementation, I recommend subagent-driven execution because distinct approvals and reliable auditing span service, storage, and UI responsibilities and benefit from independent task reviews. Subagent-driven execution reviews each task before continuing; native execution keeps implementation inline and reviews the whole branch afterward. Which approach would you prefer if you choose to authorize implementation? This request is complete at the plan.”

Planned actions stop after delivering that plan. No implementation, execution workflow, or implementing worker is started under this request.

## Scenario: delegated-plan

### Scenario input
{
  "id": "delegated-plan",
  "skill": "writing-plans",
  "prompt": "The same customer-approval subsystem design is agreed: two distinct managers must approve, rejection returns the item to its author, and every transition is audited. The human has selected writing-plans and says: 'Write the plan and implement it inline. I delegate routine planning details to you; do not ask me to approve the plan again.' Give the next response, planned actions, and handoff behavior. Do not implement code in this probe."
}

### Complete response

I'm using the writing-plans skill to create the implementation plan. I'll resolve routine planning details, check the plan against the agreed approval and audit rules, and continue with inline execution without another plan-approval prompt.

Planned actions:

1. Read the approved design and verify the existing service, storage, UI, and unit-test patterns. Identify actual paths and interfaces before writing implementation steps.
2. Write and save the required plan with the goal, architecture, technology stack, design reference, global constraints, Review Focus, and independently testable tasks. Include concrete code, commands, expected outcomes, interfaces, and verification steps. Preserve the requirements for two distinct managers, rejection returning the item to its author, and an audit record for every transition.
3. Resolve routine decomposition, file placement, and test organization using established repository patterns. Do not treat routine choices as renewed consent requests. If inspection exposes a material requirement conflict outside the delegated planning details, identify it and seek the missing decision while continuing independent authorized work.
4. Self-review for complete design coverage, placeholders, interface consistency, and tests for the identified failure modes. Correct routine problems directly.
5. Link the completed plan and report that inline execution is beginning. Preserve the user's supplied execution method; do not ask the user to choose it again.
6. In a real implementation session, continue using executing-plans as the writing-plans workflow's required supporting execution skill. Work through the verified tasks and checks inline, tracking completion and reporting actual evidence. This probe stops at describing these actions and performs none of the implementation.

Handoff behavior:

“Planning and self-review are complete. I've linked the saved plan for reference and am continuing inline with the first implementation task, as you requested.”

No response is required at that handoff. Although the baseline writing-plans Execution Handoff normally asks for a plan review even when an execution method was supplied, its invocation policy says the human's current request and established preferences take precedence over skill defaults. The explicit instruction to delegate routine planning and skip renewed plan approval therefore governs this case. It does not delegate changes to the agreed approval rules or authorize unrelated external actions.