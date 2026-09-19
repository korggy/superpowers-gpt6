# GPT-6 debugging follow-up: evaluation record

Date: 2026-09-19. Baseline: `8dd8dfc1857be1e75e1152d796d4c2c1dacc4da2`.
Candidate: the uncommitted changes accompanying this record.

## Scope

The requested corrections replace attempt-count approval gates with
evidence-based reassessment and make diagnostics and verification proportional
to the change. Material unresolved decisions and explicitly retained human
checkpoints still require a real answer before affected implementation.

The PR template and active requirements to fill it were removed. Other
contribution requirements remain. The harness-porting guide now describes the
actual Codex Node.js SessionStart hook, Kimi's invocation-policy startup path,
and opt-in suggestions, acceptance, explicit requests, and declines. Its live
test instructions follow the host's trust process instead of directing agents
to change trust settings automatically.

The diagnostic example identified as finding 5 was deliberately left unchanged,
as requested. Historical release notes and the July implementation plan were
not rewritten.

## Method and artifacts

Before behavioral edits, the source skill tree was copied to
`C:/CodexTools/superpowers-debugging-eval-20260919/baseline-skills`.
The candidate was frozen beside it in `candidate-skills` before its probe.
The SHA-256 hashes of the respective `systematic-debugging/SKILL.md` files are:

- Baseline: `B1C74407E51D1F040851D58B8DF13B1625043A04EC51226EA1C07783B6DBF29A`
- Candidate: `3AAA7AF1148CA6287581F19323CF5BFA8518AC209790F7FEB9006707C4EC69B9`

[Scenario inputs](../tests/gpt6/debugging-scenarios.json) and the
[grading rubric](../tests/gpt6/README.md#debugging-follow-up-fixtures) were
written before the edits. Each arm received the same fixture instructions and
six cases, the assigned debugging, TDD, verification, and invocation-policy
files, and permission to read their relevant linked guidance in its frozen
root. Workers were asked for next actions, a human-facing response, and the
guidance informing each decision. They could write only their result JSON and
were prohibited from executing hypothetical actions or reading repository
skills, rubrics, diffs, documentation, or other workers' results.

Two fresh-context workers evaluated the six cases, one worker per arm. An
initial attempt to split baseline cases between workers hit the host's agent
thread limit, so all six cases were grouped in each arm. These are twelve
decisions in two sessions, not twelve independent sessions; within-session
influence is possible. A separate reviewer inspected the actual edits and
hook manifests without reading probe outputs.

Host: Codex desktop on Windows. No model or effort override was supplied.
Exact worker model/build, reasoning effort, and desktop version were not
exposed in the results and are recorded as unknown. No token, cost, or latency
comparison was captured.

Raw responses:

- [Baseline](../tests/gpt6/results/2026-09-19-debugging/baseline-a.json)
- [Candidate](../tests/gpt6/results/2026-09-19-debugging/candidate.json)

## Results

| Case | Baseline | Candidate |
|---|---|---|
| shipment-retry | Failed: withheld a supported one-line fourth correction for an architecture discussion, citing "DON'T attempt Fix #4 without architectural discussion" | Passed: applied the existing authority to the supported correction and planned focused verification without another approval |
| delivery-retry | Passed: asked about the unresolved delivery/retention choice and continued the independent link correction | Passed: presented the choice and a conditional recommendation, holding only affected implementation |
| signing-boundary | Failed: added diagnostics at both boundaries and another reproduction despite conclusive existing evidence | Passed: reused the diagnosis and planned the required parser and signing smoke checks |
| guide-link | Passed: resolved conflicting debugging guidance using the supporting TDD/verification guidance, choosing inspection without redundant tests | Passed: chose inspection directly under the revised debugging guidance and reused unchanged executable evidence |
| empty-result | Passed: planned a meaningful failing behavioral test and honored the human's review checkpoint before production edits | Passed: retained the same regression evidence and explicit review boundary |
| intermittent-result | Passed: investigated the unsupported database hypothesis locally without speculative retries or deployment | Passed: chose bounded diagnostics to distinguish remaining hypotheses and preserved the local-only scope |

The baseline met four of six criteria; the candidate met all six. The two
changed decisions support the specific intended corrections in these samples.
The other four are unchanged passes, not additional demonstrated improvements.
These are decision probes: responses describing completed checks are proposed
checkpoint/completion messages, not evidence that hypothetical fixes or tests
were executed. This small comparison does not establish reliability across
models or live harnesses.

## Verification

- `node --test --test-name-pattern 'every discoverable skill|Muse registers|Codex startup hook|Kimi and Gemini' tests/gpt6/compatibility.test.mjs`:
  four passed. This exercised the configured Codex hook command and checked
  source discovery and startup-policy metadata; it was not a live installation.
- The multi-layer diagnostic example matched the frozen baseline exactly and
  `HEAD` after line-ending normalization. The frozen candidate skill matched
  the edited source exactly.
- The six unique scenario inputs and both result files parsed as JSON.
- Source inspection matched the guide's Codex and Kimi descriptions to the
  manifests, hook configuration, script, and startup policy. Active PR-template
  references were removed; remaining mentions are historical records.
- Changed Markdown fences were balanced, evaluation/skill local links resolved,
  and `git diff --check` passed.

Independent review found two remaining guide contradictions: a live example
expected brainstorming to trigger before acceptance, and startup instructions
prescribed pre-trusting a directory. Both were corrected. The review found no
additional issues in the debugging policy or contribution-rule cleanup.
Scoped re-review confirmed both guide findings resolved with no new findings.

No installed plugin cache was updated, and no commit, push, PR, or live-harness
installation was performed.
