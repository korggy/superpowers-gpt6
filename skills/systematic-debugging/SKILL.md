---
name: systematic-debugging
description: Investigate unexpected behavior, failures, or performance problems before choosing a fix.
---

# Systematic Debugging

Follow the [shared policy](../using-superpowers/references/workflow-policy.md), reading it once if needed. A diagnosis-only or audit-only request remains read-only; report findings and proposed remediation without implementing it.

## Find the first causal failure

Read the actual error and relevant logs, reproduce where possible, inspect recent changes, and distinguish product failures from baseline, dependency, and environment problems. Do not turn symptoms into a patch without a supported causal hypothesis.

For multi-component systems, trace inputs, outputs, and configuration across the relevant boundary. Use existing logs and read-only inspection first. Add instrumentation only within authorized scope and only when it resolves missing evidence. Redact credentials and sensitive values; inspect presence or sanitized structure rather than dumping environment variables.

Read [root-cause-tracing.md](root-cause-tracing.md) when tracing a deep call chain, [condition-based-waiting.md](condition-based-waiting.md) for timing failures, or [defense-in-depth.md](defense-in-depth.md) when a demonstrated invalid state needs multiple protections. Load only the relevant technique.

## Test the hypothesis

Compare with a working path and state the causal hypothesis. Choose a focused experiment that distinguishes it from plausible alternatives. If the result contradicts it, revise the hypothesis; do not accumulate speculative patches.

Keep experiments and artifacts inside the authorized workspace and side-effect limits. If the failure cannot be reproduced, report what the available evidence does and does not establish.

## Fix and verify when authorized

Capture the original symptom with a meaningful regression test or reproducible check. Apply a coherent fix at the causal boundary and verify affected behavior. Keep unrelated refactoring out of scope.

Repeated failures are a reason to reassess evidence and approach, not proof that the architecture is wrong. Discuss architecture when evidence reveals a material requirement or design choice the user must settle. Continue an evidence-supported in-scope next step without a fixed-count approval gate.

If the cause is environmental or external, identify the boundary and actionable evidence. Do not automatically add retries, timeouts, logging, or monitoring as a substitute for diagnosis. Implement those only when the requirement and authorization warrant them.

Report the causal finding, the change or recommendation, verification, and remaining uncertainty. Required behavior that still fails remains incomplete.
