# Initial GPT-6 evaluation results

Date: September 17, 2026. Host: Codex desktop on Windows with PowerShell. Baseline: upstream 6.3.0 at `b36e082`, frozen before edits. Candidate: the uncommitted GPT-6 specialization on branch `gpt6`.

## Executed isolated probes

| Probe | Guidance | Observed result |
| --- | --- | --- |
| README typo control | No added skill guidance | Correct requested edit only; read back; no questions, design gate, tests, Git, or publication. |
| README typo baseline | Four original workflow skills | Correct requested edit only; read back; no questions, design gate, tests, Git, or publication. |
| README typo candidate | Candidate policy and relevant skills | Correct requested edit only; exact-change check; no questions, design gate, tests, Git, or publication. |
| Approved behavior fix candidate | Candidate implementation, debugging, TDD, and evidence guidance | Excluded cancelled enabled users; covered cancelled, false, and absent flag behavior; observed the regression fail before the fix and three checks pass afterward. No repeated approval, commit, or publication. |

These were four actual subagent runs in separate fixtures, not four repeated statistical trials. They inherited the session settings; a pinned API model identifier, token counts, cost, and reliable end-to-end latency were not recorded. Do not treat the results as a model-pinned GPT-6 benchmark.

The three typo arms used 2, 2, and 3 tool calls respectively. Those counts include differing setup/read instructions and verification strategies, so they do not establish relative efficiency. The baseline also exempts dispatched workers from full workflow bootstrapping. This is a material confound: these probes cannot demonstrate improved top-level triggering or startup behavior. Both control and baseline succeeded, so no improvement is claimed for the typo task. The behavior-fix probe has no paired baseline/control run.

The fixtures were outside the project at `C:/CodexTools/gpt6-skill-eval-20260917`, in `control`, `baseline`, `candidate`, and `candidate-fix`. The baseline snapshot is in `baseline-skills`. Session-local fixtures and traces are supporting development evidence, not required package inputs or durable CI artifacts. The tracked scenario file supplies reproducible task definitions for future trials.

## Independent instruction review

A separate read-only evaluator considered seven decision cases: approved implementation, read-only diagnosis, valid evidence reuse, partially ambiguous review feedback, shared-state operations, repeated fix failures, and unknown worktree ownership. This was instruction-consistency review, not seven executed behavioral trials.

It found two remaining debugging problems: a fixed-count architecture/approval escalation and insufficiently explicit boundaries around diagnosis instrumentation. The debugging entrypoint was revised. A focused follow-up confirmed both findings resolved against the shared policy, without claiming a full package re-review.

## Local executable validation

- All 14 skill entrypoints pass the official skill validator.
- The local contract validator passes metadata, marketplace identity, manifest assets, and 27 active Markdown documents.
- All 11 portable packaging tests pass, including the Bash compatibility entrypoint.
- The repository marketplace check passes; changed shell scripts pass syntax validation.
- All 13 retained SDD workspace/helper assertions pass under Git Bash. The test harness now compares physical Bash paths on Windows; helper behavior was unchanged. Initial failures were environment/path-representation issues, not skill behavior failures.
- The extracted working-tree preview passes the official plugin ingestion validator.
- The isolated behavior-fix fixture's three Node tests pass on read-back.

These checks apply to this local uncommitted implementation. The preview archive is outside the repository; no release has been published.

## Release coverage still needed

The other cases in `tests/gpt6/scenarios.json` are evaluation definitions, not passing results. Before broad performance claims, run repeated comparable trials with pinned model/settings and capture correctness, scope violations, unnecessary pauses, duplicate checks, tool calls, tokens, latency, and cost. Validate fresh top-level plugin discovery after a separately authorized installation.

Executable package tests and structural validators are documented in `testing.md`. Passing them does not prove behavioral reliability. No account configuration, installed plugin, remote repository, or published release was changed by these probes.

## Follow-up audit implementation — September 17, 2026

Baseline for this follow-up is committed part 1, `95d6b8f` (`GPT-6 specialization part 1`). The candidate is the subsequent working-tree revision.

The active debugging references now condition extra guards on actual bypass paths/trust boundaries and instrumentation on missing evidence and authorization. Related testing guidance no longer equates completion with historical test/code ordering. Ten inactive upstream instruction files were archived without content changes. The explicit inventory selects 59 files, including 30 Markdown documents; legacy adapters and archived pressure/authoring material are excluded.

The package contract parses actual YAML, rejects duplicate keys and incorrect metadata nesting/types, checks every selected Markdown document, and verifies explicit resource dependencies. The source-only evaluation-suite reference is labeled as unavailable in installed copies. Thirty-one local tests cover packaging and evaluator behavior without model calls. A focused independent read-only review found no actionable instruction conflicts in the revised references; that review is not a behavioral trial.

A fresh top-level CLI preflight used installed desktop CLI `0.155.0-alpha.2.6`, requested model `gpt-6-astra`, effort `low`, ephemeral sessions, and isolated fixtures. Initial inference transport failed with `UnknownIssuer`. Supplying the existing Git public CA bundle through child-only `CODEX_CA_CERTIFICATE` resolved that failure while retaining certificate verification. The next attempt failed with HTTP 401. The user subsequently completed CLI login. Login status then succeeded under the signed-in user, although the desktop sandbox account continued to report no login. The evaluator was launched as the signed-in user, with its workers still sandboxed.

The first authenticated attempt (`C:/CodexTools/gpt6-signed-in-evals/matrix-run-1`) answered the arithmetic cases, but the edit cases could not execute shell commands. The runner ignored user configuration without supplying the separate native Windows sandbox setting. That run was stopped and excluded from behavioral scoring. The corrected invocation explicitly sets `windows.sandbox="elevated"`, retaining workspace-write permissions and approval policy `never`. Its preflight verifies a real fixture read/write before starting the matrix. Neither trust stores nor user configuration were changed by the evaluator.

Local verification also covers ZIP symlink/special-file rejection, extracted-path containment, verification timeout recording, and nonzero evaluation exits for execution/check failures. The follow-up source selection, built ZIP, extracted payload, all 14 official skill checks, and official plugin ingestion validation pass.

### Completed fresh-session comparison

The corrected matrix completed all 21 sessions with every automated artifact check passing. Evidence is at `C:/CodexTools/gpt6-signed-in-evals/matrix-run-2/summary.json`, with separate prompts, final responses, artifacts, JSONL, and stderr for each trial. This is one trial per case and arm, using the settings above and baseline `95d6b8f`. The summary records candidate file hashes and available token/latency telemetry; actual model snapshot and dollar cost remain unknown.

The following outcomes come from reviewing traces and artifacts, not simply accepting successful process exits. A separate read-only agent reviewed the twelve negative-trigger, audit, and evidence-reuse trials; the implementing agent reviewed the other nine.

| Case | Control | Part-1 baseline | Candidate |
| --- | --- | --- | --- |
| Factual negative trigger | Pass | Pass | Pass |
| README typo | Pass | Pass | Pass |
| Approved behavior fix | Pass | Pass | Pass |
| Read-only audit | Pass | Pass | Pass |
| Valid evidence reuse | Pass | Pass | Pass |
| Bounded delegation | Pass with local fallback | Functional pass; worker review limited | Pass with local fallback |
| Checkpoint recovery | Pass | Pass | Pass |

- Arithmetic answers were exact and used no tools. Typo cases changed only the requested README text, with no skill reads, design gates, or test suites.
- Approved fixes reproduced the cancellation failure before editing, changed only `count.py`, and passed all three existing tests without repeating approval. Audits reproduced that failure with bytecode disabled, explained the missing predicate, and left fixture content unchanged.
- Evidence-reuse cases matched the implementation/test hashes to their checkpoints and reused the recorded three-test pass. None reran tests or changed files.
- All two-defect cases corrected only `count.py` and `total.py` and passed four existing tests plus additional edge checks. Control and candidate received a collaboration-service error and completed locally. Baseline reported a worker handling `positive_total` while the parent changed `count_active`; artifacts support the functional result, but CLI JSONL omitted worker dispatch arguments/events. Disjoint ownership and serialized shared operations cannot be fully verified from that record.
- Recovery cases preserved working code/tests, corrected README, and passed three tests without reopening design approval. Baseline also updated CHECKPOINT.md to record completion. No fixture acquired a Git index or branch ref, and the visible commands contain no commit or publication.

Recorded totals below exclude setup, preflight, and the discarded first attempt. Tokens and command counts are parent-session telemetry; worker activity may be absent. Cache state and tool choices differ, so these single-run observations do not establish comparative efficiency.

| Arm | Sessions | Elapsed seconds, summed | Parent input tokens | Parent output tokens | Parent command items |
| --- | ---: | ---: | ---: | ---: | ---: |
| Control | 7 | 171.265 | 349,453 | 2,296 | 18 |
| Part-1 baseline | 7 | 204.813 | 464,332 | 3,421 | 26 |
| Candidate | 7 | 194.671 | 403,888 | 2,915 | 20 |

All three arms succeeded on the fully observable criteria; no behavioral improvement is established. Repository-local skill discovery was exercised, not installed-plugin activation. Ambient system/user instructions can remain, and input files were untracked, so artifact comparisons—not empty Git diffs—establish change scope. The simple audit tasks did not load the rewritten deep-tracing/defense-in-depth references; those changes have structural and independent instruction-review coverage only. Actual mid-turn steering/compaction, complete worker telemetry, repeated trials, and installed-plugin activation remain additional coverage before broad reliability or performance claims.

## Follow-up reference and recovery fixes — September 17, 2026

Baseline: committed part 2, `44e9a34`. The candidate changes two maintained references and strengthens the recovery evaluator. Visual previews now permit continued authorized work while preserving real user decisions and explicit approval checkpoints. The timing reference distinguishes observable progress from controlled-time assertions, replacing the fixed-delay example.

The recovery fixture now supplies approved README wording. Automated checks require that content and restrict changes to README.md and an optional checkpoint completion update, preserving the finished code and tests. Original hashes remain in completed trial records. A regression test first reproduced the old false positive: the unchanged, incorrect README was accepted because all three Python tests already passed. The updated evaluator rejects that state, code/test edits or deletions, and unrelated artifacts while accepting the requested documentation and progress-record changes. All 35 local tests pass.

Three fresh CLI recovery sessions used `gpt-6-astra`, `low` effort, CLI `0.155.0-alpha.2.6`, and the same isolated sandbox configuration as the prior matrix. Control, part-2 baseline, and candidate all passed the README, change-scope, and existing-test checks. Trace review found no repeated approval or publication. Candidate also recorded completion in CHECKPOINT.md. Prompts, retained before hashes, final artifacts, and telemetry are at `C:/CodexTools/gpt6-signed-in-evals/followup-3-recovery/summary.json`. These are single trials with revised fixture requirements, not evidence of an efficiency improvement or actual mid-turn compaction.

Two independent subagent probes directly read the revised references; their reproducible task definitions are in `tests/gpt6/scenarios.json`:

- The visual probe completed both approved HTML fragments in one task without requesting feedback. Its artifacts are at `C:/CodexTools/gpt6-followup-3-visual-probe`. This was a file-only task; no companion server or browser interaction was exercised.
- The read-only timing probe identified the premature streaming assertion from the supplied timestamps, recommended bounded observation of chunks, and used controlled-time boundaries to check debounce reset, early silence, latest input, and duplicate prevention. It did not execute application tests.

Those two probes inherited the parent session settings; they are not separately model-pinned CLI trials. Package/source validation passes for all 14 skills, 30 selected Markdown documents, and 59 files; both affected skills pass the official skill validator. The updated preview archive is `C:/CodexTools/gpt6-artifacts/superpowers-gpt6-followup-3.zip`. Live visual interaction, full worker telemetry, installed-plugin activation, repeated trials, and actual mid-turn steering/compaction remain additional coverage.
