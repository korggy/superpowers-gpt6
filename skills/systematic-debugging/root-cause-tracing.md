# Root cause tracing

Follow the [shared workflow policy](../using-superpowers/references/workflow-policy.md). Use this reference when an error appears deep in a call chain and the originating input or state transition is unclear.

Start with the actual error, input, and failing operation. Follow callers backward until the evidence explains how the invalid state arose. Compare with a working path and distinguish the original failure from downstream symptoms. A hypothesis should identify an experiment or existing observation that could disprove it.

For example, `git init` in an unexpected directory may come from an empty `cwd`, whose source is a fixture accessed before setup. Fixing the fixture lifecycle addresses that cause. An additional boundary check may be useful if other callers can independently pass an empty path; it is not a reason to add checks to every intervening method.

Use stack traces, existing logs, and read-only inspection first. When evidence is insufficient, choose a focused experiment within the requested scope. Instrumentation changes require implementation or experiment authorization. Inspect selected sanitized values or presence checks; do not dump environment variables or credentials. Diagnosis-only requests remain read-only.

If a test contaminates later state, use the project's test runner to narrow the order-dependent interaction in a disposable fixture. The optional [find-polluter.sh](find-polluter.sh) helper assumes an npm test runner and checks whether a named path appears; inspect its assumptions before use. Its lack of a finding does not establish that all tests ran or passed.

When a fix is authorized, change the causal boundary and demonstrate the original symptom is covered. Consult [defense-in-depth.md](defense-in-depth.md) only if distinct bypass paths or trust boundaries warrant further protection.

When the original trigger cannot be established, report the supported observations and remaining uncertainty. A scoped mitigation can still be appropriate if requested, but identify it as a mitigation and verify its effect without claiming a root-cause fix.
