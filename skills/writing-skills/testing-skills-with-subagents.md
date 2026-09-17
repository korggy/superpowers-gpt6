# Behavioral evaluation

Independent isolated runs evaluate consequential changes. A subagent probe tests its actual instructions; it does not prove discovery or behavior in a fresh top-level Codex session.

Freeze existing skills and fixtures. Compare control, current, and candidate guidance with the same tasks, permissions, model, effort, and tools where possible. Use fresh contexts and independent fixtures. Repeat variable cases before generalizing.

Supply a realistic request and minimal raw artifacts. Do not reveal expected answers, suspected defects, or proposed fixes. State evaluation boundaries honestly and keep external actions simulated or unauthorized.

Judge observable outcomes: artifacts, scope, checks, questions, mutations, and completion. Reciting a rule or matching wording is not behavioral success.

Record case, arm, model/effort when available, host, input revision, initial state, actions, files, result, and limits. Unknown telemetry stays unknown. If all arms succeed, report no demonstrated difference.

Use several independent runs for reliability or efficiency claims. Small smoke samples can find defects but do not establish performance gains. Measure correctness alongside time, tokens, and tool calls.

The source checkout includes `tests/gpt6/scenarios.json` and evaluation tooling. These are source-only development resources, absent from the installed plugin. In a plugin-only workspace, create task-specific isolated fixtures from the requested behavior; do not search the user's repository for this fork's test suite. Inspect actual artifacts and distinguish subagent probes from top-level skill discovery and installed-plugin activation tests.

Correct demonstrated defects, rerun affected cases, and preserve counterexamples. Do not turn every failure into a universal prohibition. Installation and remote publication require separate authorization; evaluation scope does not include production or user-owned data.
