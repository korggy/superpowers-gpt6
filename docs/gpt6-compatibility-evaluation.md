# GPT-6 compatibility evaluation record

Date: 2026-09-19. Baseline source: Superpowers 6.4.1 at
`5bf4e78011075bcfc0dc295f0724994cd123ee71`. Candidate: the local uncommitted
changes accompanying this record. Host: Codex desktop on Windows, using the
active collaboration tool schemas. Behavioral workers inherited the active
model without a model or reasoning-effort override; the exact model build and
desktop version were not captured.

## Scope and limits

The behavioral checks were fresh-context, decision-only worker probes. They
read the supplied baseline or candidate skills and returned intended actions
for hypothetical user requests. They did not implement features, exercise a
real customer session, or prove top-level skill discovery in a newly installed
harness. The baseline skills were frozen before editing. Three baseline and
three candidate responses cover equivalent scenarios; two further scenarios
were evaluated in one additional candidate worker. This is a small qualitative
sample, not a benchmark or a measured claim about token savings.

Repository `evals/` was not available. No installed plugin was replaced and no
live acceptance session was run in each supported harness. Consequently the
results establish local wiring, selected instruction decisions, and the
reproduced helper fix, not complete GPT-6 compatibility across all runtimes.

## Behavioral probes

| Scenario | Baseline | Candidate | Interpretation |
|---|---|---|---|
| Generic bounded dark-mode request; no workflow requested | Announced brainstorming, created its checklist, and planned a mandatory approval gate | Inspected existing conventions and proceeded with bounded authorized work; no automatic workflow. A declined offer would not be repeated | Demonstrated removal of automatic invocation for this scenario |
| Explicit diagnosis; supplied evidence; exact wording recommendation requested; no edits or export | Recommended an evidence-based correction despite the old skill's prohibition | Recommended a correction, treated source evidence carefully, and respected no-edit scope. A later explicit fix request authorizes the edit | Baseline already passed under host instructions; candidate retains that pass |
| Accepted testing/verification workflows; 36 affected tests and required lint already passed on unchanged code; costly E2E unrequired | Reused evidence and reported scope | Reused evidence, with no rerun or extra permission request | Baseline already passed; no claimed improvement |
| New approval subsystem with unresolved permissions, rejection behavior, and audit requirements | Not sampled | Offered brainstorming with its purpose and design checkpoint; waited before loading it and before implementing affected behavior | Candidate-only check that useful clarification remains available |
| Explicit executing-plans request with approved design, scope, testing, and final review | Not sampled | Started the requested workflow without asking again or restarting design approval | Candidate-only check of accepted supporting steps |

Selected raw response excerpts:

- Baseline invocation: “I’m using the brainstorming skill to shape this change.”
  It then listed the bounded-path checklist and a stop for explicit approval.
- Candidate invocation: “I’ll check the settings page and existing theme support,
  then add a dark-mode toggle that matches the current controls.” Its action
  list specified no automatic Superpowers invocation and material clarification
  only when needed.
- Baseline verification: “Verified the unchanged final code: **36/36 affected
  tests passed**, and required lint passed.”
- Candidate verification: “Reuse the recorded results for the unchanged final
  code and respond now. No repeated tests, E2E run, or further approval is needed.”
- Candidate ambiguous feature: “Superpowers brainstorming would help settle
  approval permissions, rejection behavior, and audit requirements, then produce
  a design for your review before implementation. Would you like to use it?”
- Candidate explicit workflow: “I’ll use Superpowers executing-plans to carry out
  the approved plan, including its testing and final-review steps.”

The 36-test results above are scenario inputs, not tests of this repository.

## Executable and structural checks

| Check | Result |
|---|---|
| New `tests/gpt6/compatibility.test.mjs` | 6 passed: all 15 Codex policies; declared Codex hook command and startup sources; Kimi/Gemini notice wiring; source-first packaging metadata with legacy fallback and missing-file failure; sync precedence; Native helper success/failure bookkeeping |
| Native helper baseline | Before the fix, the new fixture failed with a missing child-script interpreter, exit 126. After explicit Bash calls, it passed, including a failed verification that must not mark task 2 complete |
| Pi `test-pi-extension.mjs` | 6 passed, including startup, post-compaction injection, deduplication, and resource discovery |
| OpenCode bootstrap caching | Present and missing notice cases passed for V1/V2 |
| OpenCode session bootstrap | Session classification, transient failures, recovery, and cache lifetime passed |
| OpenCode skill registration | 15 skills registered, `autoinvoke: false` asserted, and one simulated host rejection did not abort remaining registration |
| Shared shell SessionStart tests | 6 passed: manifest dispatch, wrapper, Claude/Cursor/Copilot JSON shapes, and obsolete-warning removal |
| Diagnosis structure | 47 passed, including 973-word body budget and referenced-file checks |
| Codex/Kimi manifest assertions | Passed using the existing tests' Python assertion bodies |
| Hermes dependency-free smoke | 15 skills registered; real first-turn notice, size limit, and later-turn behavior passed |
| Modified Bash scripts | Syntax checks passed |
| Git diff whitespace check | Passed |

Run the dependency-free checks with:

```text
node --test tests/gpt6/compatibility.test.mjs tests/pi/test-pi-extension.mjs
python tests/gpt6/hermes-smoke.py
node tests/opencode/test-bootstrap-caching.mjs .opencode/plugins/superpowers.js present
node tests/opencode/test-session-bootstrap.mjs .opencode/plugins/superpowers.js
node tests/opencode/test-skill-registration.mjs .opencode/plugins/superpowers.js
bash tests/hooks/test-session-start.sh
bash tests/diagnosing-superpowers/test-skill-structure.sh
```

On Windows use Git Bash with its `usr/bin` on the test process's PATH, not
the WSL launcher named `bash`. `TEST_BASH` and `TEST_TMPDIR` can select the
test runtime and scratch directory. The missing-notice OpenCode case used
an isolated copied plugin fixture, leaving the source policy intact.

The initial candidate helper run accidentally resolved a nested `bash` to
the Windows WSL launcher and failed on paths; fixing the test-process PATH
resolved that environment failure. An initial attempt to run OpenCode CLI
test scripts under `node --test` omitted their required arguments; the
documented direct invocations above passed. These were validation setup
errors, not product regressions.

Full archive and sync suites were not run: `jq`, `zip`, `shasum`, and `rsync`
were unavailable in the available Git Bash environment. The changed production
metadata block/function was executed directly in isolated fixtures instead;
this does not validate archive reproducibility or remote synchronization.
The full Hermes pytest suite was unavailable because pytest was absent;
temporary dependency installation did not complete and was stopped. The
dependency-free smoke above covers the changed startup path, not that full suite.

## Independent review

A read-only review found four concrete issues: Kimi still loaded a startup
skill, OpenCode v2 lacked its native implicit-invocation setting, execution
Step 4 contradicted evidence reuse, and supporting workflows still treated
detached HEAD as proof of host management. All four were corrected. A focused
follow-up inspection found those resolutions complete and confirmed source
metadata precedence. No repeated test run was required by that review alone.

Before a release, run the unavailable integration suites on a prepared host
and test real installed sessions for: generic request, useful offer, acceptance,
explicit initial invocation, decline, compaction, and approved supporting steps.
Keep results for each harness separate.
