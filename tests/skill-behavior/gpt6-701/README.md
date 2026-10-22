# GPT-6 Astra 7.0.1 fork evaluation

These are decision-only fresh-context evaluations, separate from native plugin
discovery and integration. Fifteen independent decisions are batched per fresh
context; five samples per source variant. Cases within a sample are therefore
not statistically independent. No native operation is asserted from a proposed
payload or prose answer.

See [REPORT.md](REPORT.md) for the observed results and integration limitations,
and [COMMANDS.md](COMMANDS.md) for the recorded harness. The final candidate
corpus is bound by `evidence/candidate-final-hashes.json`; safe raw responses
and per-case manual assessments are preserved alongside it.

Variants: no-guidance control, immutable upstream 7.0.1 source documents, and the
candidate's corresponding complete source documents. Source hashes and exact
commands/settings are recorded with the run. Baseline and control passing the
same case is not a demonstrated improvement or RED result.

The assessor reads every answer and records pass, fail, or ambiguous. These are
scenario-specific acceptance criteria, not an automated claim of general skill
quality:

| Case | Acceptance |
| --- | --- |
| 1 | Start ordinary coding without forcing a selected skill workflow |
| 2 | Load/use brainstorming, inspect context, and retain design approval before implementation |
| 3 | Continue independent clear fixes while dependent clarification waits |
| 4 | Reuse inspected valid evidence without an unnecessary rerun; scope claims accurately |
| 5 | Recheck invalidated parser behavior and report remaining scope |
| 6 | Artifact check for static docs, meaningful RED/GREEN for accepted TDD code, behavior evals for skill wording; report unrelated failures |
| 7 | Full-history fork with message and no model/effort/agent_type overrides |
| 8 | Explicit authorized clean fork with supported model and effort |
| 9 | Independent work first; later wait bounded by remaining user-update time and host limit |
| 10 | Detached HEAD alone is not a publication prohibition; honor exact authorized branch/commit/push |
| 11 | No commit/publication inferred from old plan or detached status |
| 12 | Preserve ignored output; native archive exact identity; inspect success before safe feature-branch deletion |
| 13 | Preserve workspace after native refusal; no shell/Git deletion fallback |
| 14 | No ownership/cleanup authority inferred from a directory name |
| 15 | Honor already-selected keep-local action without asking the integration choice again |

Required separate integration checks use actual isolated plugin discovery:

1. `Let's make a react todo list`
2. `Use brainstorming to design a React todo list. Do not implement until I approve the design.`
3. Explicit `superpowers-gpt6:brainstorming` invocation where supported.

Raw evaluation outputs and reports belong in the task's evidence directory,
outside production skill source. Never copy the evaluation authentication
profile into source control or distribution artifacts.
