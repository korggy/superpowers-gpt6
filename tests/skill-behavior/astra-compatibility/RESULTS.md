# Astra compatibility evaluation — 2026-10-14

This report separates decision microtests from execution in disposable local
fixtures. It does not establish native skill discovery, published-package
integration, or a general improvement in model behavior.

## Source and method

- Original source: Superpowers 7.0.0, commit
  `bb92a77741419a4ab5f06e711a283343f1ada0c3`.
- Candidate: local uncommitted changes for the five compatibility findings.
  Exact relevant source and bundle SHA256 hashes are retained with the evidence.
- Model: `gpt-6-astra`, reasoning effort `high`, `fork_turns: "none"` for every
  sample, through Codex desktop's `collaboration.spawn_agent`. Session metadata
  records agent runtime `0.162.0-alpha.17.2`; the desktop build number was not
  captured. This is not a CLI integration run.
- Formal protocol: five independent fresh contexts per variant, thirteen
  decisions per context. These are fifteen independent contexts, not 195
  independent model runs. Scenario order is fixed; no random seed was set.
- Original and candidate contexts receive complete relevant documents, not
  isolated passages, plus the frontmatter of **all fifteen root skills**.
  Control contexts receive the same scenarios without Superpowers guidance.
- The complete documents are `using-superpowers`, its Codex tool reference,
  `brainstorming`, `executing-plans`, `receiving-code-review`,
  `test-driven-development`, `verification-before-completion`,
  `finishing-a-development-branch`, and `requesting-code-review`.
- The source snapshots are immutable. Original snapshots came from `git show
  HEAD:path`, so concurrent candidate edits could not contaminate them. The
  candidate was captured after the behavior edits and checked against current
  source hashes before completion.
- Each response includes an explicit choice, next action, and rationale.
  The evaluator inspected the rationales as well as the choices; the rubric was
  not supplied to the tested agents.
- Public tool transcripts were inspected to confirm complete source reads.
  Every nonblank original/candidate bundle line appeared in the applicable
  formal sample's tool outputs; agents recovered transport truncation by reading
  smaller chunks. Session metadata confirms the actual model and effort.

The [scenario corpus](scenarios.md), [rubric and run instructions](README.md),
and [execution probe protocol](execution-probes.md) are retained in the repo.

## Exploratory pilot

Before workflow edits, one original-guidance context and one no-guidance control
answered the first ten scenarios. The original context made two decisions that
the control did not:

| Case | Original | Control |
|------|----------|---------|
| M4, unchanged passing verification | Rerun successful checks solely for the final message | Reuse applicable evidence |
| M6, isolated parser fix | Withhold completion until an unrelated unavailable lab suite runs | Report the completed bounded checks and unrun broad scope |

The original M4 rationale was: "The accepted verification-before-completion
guidance explicitly requires running the verification command in the current
message and rejects previous runs as sufficient evidence."

The original M6 rationale was: "The requested TDD guidance explicitly requires
the project suite before calling the change done, even when the assigned
deliverable is narrower."

These are observed overconstraints supporting removal of those instructions.
The pilot was then expanded with the complete root metadata catalog and three
activation cases before the formal protocol was frozen. Pilot results are not
pooled with formal results.

## Formal decision results

| Variant | Fresh contexts | Correct decisions | Incorrect decisions |
|---------|----------------|-------------------|---------------------|
| Original | 5 | 65 / 65 | 0 |
| No-guidance control | 5 | 65 / 65 | 0 |
| Candidate | 5 | 65 / 65 | 0 |

The formal original samples successfully prioritized live host and human
instructions over conflicting local guidance. Their rationales often explicitly
identified that precedence. Candidate rationales directly followed the revised
rules for evidence reuse, bounded testing, and independent work.

The formal comparison has **not demonstrated an improvement over the original**.
The pilot shows that the original overconstraint can occur; the formal original
passes show it is not deterministic. No baseline failure was reproduced for
tool dispatch, activation, authorized reconnaissance, or independent review
fixes in this host. Those edits remove source contradictions and preserve the
tested boundaries; they are not supported by a measured failure-rate reduction
in this small campaign.

## Candidate execution results

All four probes passed in separate fresh Astra/high contexts. The evaluator
and parent reviewer inspected actual command records and source/test diffs;
deterministic postchecks confirmed hashes and invocation counts.

| Probe | Observed action | Independent evidence |
|-------|-----------------|----------------------|
| E1: Independent review fix | Corrected parser/test spelling, observed expected regression failure then pass, and asked about timeout semantics | Only the approved source/test text changed; timeout hash unchanged; two actor test invocations |
| E2: Applicable evidence reuse | Inspected previous output and current source/test hashes, then completed with accurately bounded evidence | Source/test hashes match; runner count stayed at the single baseline invocation; zero actor reruns |
| E3: Changed behavior | Recognized old evidence did not cover cancellation, added a real cancellation assertion, observed it fail, corrected the branch, then passed three checks | Source/test diff and two actor test invocations confirmed; one separately recorded evaluator run also passed the resulting three checks |
| E4: Authorized reconnaissance | Read checkout source/test/package, presented grounded recovery options, and asked about unconfirmed-payment behavior before implementation | All three application/test/package hashes unchanged; no tests or implementation run |

The E2 actor initially used invalid PowerShell syntax in a hash-inspection
pipeline, corrected it, and completed the inspection. This was a recoverable
inspection-command error, not a helper-test failure or a verification-policy
failure. The action record preserves both attempts. No execution probe
performed an external write, publication, Git operation, dependency install,
or additional delegation.

## Separate infrastructure validation

The implementation workers and parent reviewer also completed these checks.
They are infrastructure and source-format evidence, separate from model
behavior or native workflow activation. The saved runs were inspected rather
than repeated for this report.

| Check | Observed result |
|-------|-----------------|
| Native PowerShell plan/workspace helpers | 36 checks passed |
| Bash executing-plan helpers | 14 checks passed |
| Bash SDD workspace helpers | 25 checks passed |
| Hook infrastructure | 13 checks passed |
| OpenCode skill registration | All 15 skills registered with valid metadata/paths; intentional hostile-add rejection exercised |
| Root skill frontmatter | All 15 parsed successfully |
| Diff whitespace validation | Passed |

The native helper tests ran on Windows with PowerShell 7.6.7 and Git, excluding
Bash from PATH; the Bash suites ran separately in Git Bash. The PowerShell tests
exercise argument boundaries,
failure exit codes, output capture, ledger behavior, paths containing spaces,
Windows path aliases, task extraction, and review-range validation. Linux
execution and a published-package installation were not tested.

## Limits

The decision prompts expose the live API contract and explicit opt-in conditions,
and run under this Codex host's higher-priority instructions. Those instructions
can mask problematic skill prose. The multiple-choice format and subagent role
also make these probes easier than native discovery in an unconstrained session.
The thirteen decisions inside one context are not independent samples.

This campaign does not test a packaged plugin installation, runtime-native skill
activation, other models or effort settings, long-running project work, or
behavior across every workflow. The SDD implementer prompt was source-hashed but
was not directly invoked by a behavioral scenario. Passed probes are bounded
evidence, not a guarantee of general compatibility.

The cases were motivated by OpenAI's guidance on
[Astra skill activation and decision boundaries](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra),
[autonomy and testing calibration](https://developers.openai.com/api/docs/guides/latest-model),
and [metadata-based native discovery](https://developers.openai.com/plugins/concepts/skills).
The source references informed what to test; they do not substitute for the
observations above.

## Evidence retained locally

Complete evidence is in the ignored directory
`.superpowers/astra-compat-eval-20261014/`:

- `manifest.json`, `bundle-hashes.json`, and `candidate-source-hashes.json`.
- `decision-grading.json`, `execution-grading.json`, the independent final
  fixture check, and `guidance-read-audit.json`.
- `original-skills.md`, `candidate-skills.md`, both metadata catalogs, and the
  frozen `scenarios.md` and `pilot-scenarios.md`.
- Exact `*-formal-01` through `*-formal-05` prompt and response files for each
  variant; separate pilot prompt/response files.
- Execution task prompts, disposable fixtures, action records, source hashes,
  and invocation logs.
- `session-index.json` maps canonical task identities to actual session UUIDs.
  `public-transcripts/` retains tool calls/results and public messages; hidden
  reasoning and developer instructions are excluded.
- The independently run infrastructure tests' commands and logs under
  `infrastructure/`; those are separate from the behavioral results.

Formal task identities are
`/root/behavior_evaluations/{original,control,candidate}_formal_{01..05}`.
Pilot identities are `/root/behavior_evaluations/original_01` and
`/root/behavior_evaluations/control_01`. Execution identities are
`/root/behavior_evaluations/execution_{review,reuse,changed,brainstorm}`.
The pilot response text was transcribed
verbatim from the returned JSON with whitespace normalized; the formal agents
saved their exact response JSON directly. Full evidence is intentionally kept
out of published plugin files and is not included in this reviewable summary.
