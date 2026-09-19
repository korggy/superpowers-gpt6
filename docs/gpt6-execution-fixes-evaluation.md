# GPT-6 execution, review, and dispatch: evaluation record

Date: 2026-09-19. Baseline: `860917402208a058f8754a3ba399acd790fb8e97`.
Candidate: the uncommitted changes accompanying this record.

## Scope

The three requested corrections align inline execution with valid evidence
reuse, distinguish correctness defects from unresolved product choices during
review, and describe concurrency using the host's actual background-worker
contract. Examples now follow those rules. Material choices remain with the
human or explicit delegation, while independent authorized work continues.

Only four skill documents and source-only evaluation material changed. Hooks,
manifests, discovery metadata, executable helpers, and the previously excluded
diagnostic example were not changed.

## Method and artifacts

The baseline skill tree was frozen before edits at
`C:/CodexTools/superpowers-execution-eval-20260919/baseline-skills`.
The initial candidate was frozen in sibling directory `candidate-skills`.
[Scenario inputs](../tests/gpt6/execution-scenarios.json) and the
[rubric](../tests/gpt6/README.md#execution-review-and-dispatch-fixtures) were
written before production edits. Both arms received the same six scenarios,
assigned skill files, and applicable linked guidance from their frozen root.
Workers returned planned actions, a human-facing response, and cited guidance;
they did not execute the hypothetical tasks. They could write only their result
JSON and could not read repository guidance, rubrics, diffs, evaluation records,
or other probe outputs.

Each arm used a fresh-context worker. All six cases shared that arm's session,
so these are twelve decisions in two sessions, not twelve independent sessions.
Within-session influence is possible. A separate reviewer inspected the edits
without reading probe outputs.

Independent review found two remaining example contradictions: an unconditional
readiness verdict despite an unresolved defect, and a mandated invalid-date
policy without an established contract. The verdict now requires correction
and verification; the date example states the accepted contract being violated.
Scoped re-review confirmed both findings resolved, with no new findings.

These two example corrections occurred after the initial candidate probe. The
original snapshot and results were preserved. The final source was frozen in
`candidate-final-skills`, and a third fresh-context worker rechecked the two
affected review cases using the same inputs and isolation rules. Those two
cases shared a session. The other four cases retain their initial candidate
evidence; their assigned skills and applicable policy references did not change.

Host: Codex desktop on Windows. No model or effort override was supplied.
Exact worker model/build, reasoning effort, and desktop version were not exposed
in the results and remain unknown. No token, latency, or cost comparison was
captured. Worker capacity errors during dispatch were host limitations, not
scenario failures.

Artifacts:

- [Baseline responses](../tests/gpt6/results/2026-09-19-execution/baseline.json)
- [Initial candidate responses](../tests/gpt6/results/2026-09-19-execution/candidate.json)
- [Final review-case responses](../tests/gpt6/results/2026-09-19-execution/candidate-final-review.json)
- [Guidance hashes](../tests/gpt6/results/2026-09-19-execution/guidance-hashes.json)

## Results

| Case | Baseline | Initial candidate |
|---|---|---|
| task-record | Passed: recorded existing evidence directly; an identical-content commit did not justify another run | Passed: recorded existing evidence and skipped the rerunning helper |
| documentation-task | Passed: inspection and target/heading validation completed the task | Passed: used the same evidence without a new framework, test, or commit |
| list-order | Core decision passed: held ordering for the human, offered three options, and continued the null fix; omitted an explicit recommendation | Passed the full rubric: also recommended retaining insertion order for compatibility, without treating that recommendation as approval |
| save-failure | Passed: classified record loss as a correctness defect and planned an authorized narrow fix with regression protection | Passed: preserved that decision without making the omitted trigger a new approval gate |
| background-workers | Passed: explicitly overrode the old message-count rule with the host's async contract | Passed: started A and B in separate calls, did local work, queued C for a free slot, and collected all results |
| shared-contract | Passed: sequenced the contract and overlapping consumer work while launching the independent investigation | Passed: preserved dependencies, file ownership, and unresolved-decision authority |

Both initial arms made the correct core decision in all six cases. Against the
full rubric, the baseline has five passes and one partial result because its
ordering response omitted a recommendation; the initial candidate has six
passes. The baseline's correct decisions remain passes even where it resolved
conflicting instructions through other guidance. The recommendation difference
is a single observed sample, not evidence of broad behavioral improvement.
The principal supported change is removal of contradictory guidance while
preserving the sampled decisions.

The final two-case recheck passed both full criteria: the ordering response
presented options and a recommendation, held only the unresolved choice, and
continued the null fix; the failed-save response treated data loss as an
authorized correctness correction with meaningful regression protection.

These are decision probes, not executed implementation or live-harness tests.
Responses referring to completed validation rely on the scenario's supplied
facts. This small comparison does not establish reliability across models or
supported harnesses.

## Verification

- JSON parsing and unique-case checks cover the fixture and result artifacts.
- The final frozen guidance matches the four edited source files byte for byte;
  baseline, initial candidate, and final hashes distinguish the evaluated states.
- Changed skill frontmatter remains opt-in, Markdown fences are balanced, and
  local skill and evaluation links resolve.
- `git diff --check` passed.
- The preceding audit's four discovery/startup compatibility checks are reused:
  `node --test --test-name-pattern 'every discoverable skill|Muse registers|Codex startup hook|Kimi and Gemini' tests/gpt6/compatibility.test.mjs`.
  Their hooks, manifests, discovery metadata, and executable dependencies were
  unchanged. Those checks were not rerun for this prose-only correction and do
  not establish a live installation.

No installed plugin cache was updated, and no commit, push, PR, or live-harness
installation was performed.
