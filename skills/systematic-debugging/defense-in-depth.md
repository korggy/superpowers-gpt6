# Defense-in-depth validation

Follow the [shared workflow policy](../using-superpowers/references/workflow-policy.md). Use this technique when evidence shows that one protection can be bypassed or that distinct trust boundaries need independent checks.

Trace the invalid state to its cause and fix that cause within the authorized scope. For each additional guard, identify the path that bypasses the existing protection and the contract the new guard enforces. Add it only when that path is plausible and relevant to the requirement.

Examples of useful boundaries include an untrusted API input and a domain operation also called by background jobs. Identical checks in every forwarding method usually add maintenance without protecting a new boundary. Prefer the smallest set of checks that covers the demonstrated paths.

Verify each distinct protection with a meaningful regression case. Do not manufacture a test for each layer merely to match an architecture diagram. Passing tests support the exercised cases; they do not make a bug impossible.

Instrumentation is a diagnostic option, not a required validation layer. Use existing evidence first. Add temporary or permanent logging only when missing diagnostic evidence and task authorization justify it; record a reason to retain it and avoid sensitive values.

In an audit-only task, describe proposed protections and checks without editing code, adding instrumentation, or changing the environment.
