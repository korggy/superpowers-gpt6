# GPT-6 re-audit fixes: evaluation record

Date: 2026-09-19. Baseline: source revision `5e884b2`. Candidate: the
uncommitted source changes accompanying this record. This follows the prior
compatibility and clarification evaluations; their historical skill counts
describe those earlier runs.

## Changes assessed

1. Allow passing skill baselines and preserve valid work when evaluation order
   was imperfect. Remove the conflicting deletion mandates and examples.
2. Preserve requested worktree isolation after a permission denial, check the
   actual selected ignore path, and require separate authority for commits.
3. Clarify unresolved review items while completing independent authorized fixes.
4. Remove `finishing-a-development-branch` from source, discovery metadata,
   active routing, examples, and advertised capabilities. Integration and cleanup
   follow repository guidance and human instructions. Preserve historical records.
5. Require verification appropriate to the SDD fix, including inspection or
   parsing for low-impact prose/metadata, and reuse applicable unchanged-code
   results. Behavioral fixes retain meaningful regression coverage.

The Codex sync helper also stops preserving destination metadata for skills
absent from source, preventing removed skill directories from being recreated.

## Method and artifacts

The baseline skill tree was copied before edits to
`C:/CodexTools/superpowers-reaudit-fixes-20260919-4a977ea1/baseline-skills`.
The candidate skill tree was frozen beside it in `candidate-skills` before
candidate probes. Case inputs were written before behavioral edits in
[reaudit-scenarios.json](../tests/gpt6/reaudit-scenarios.json).

Four fresh-context workers evaluated the same inputs: an authority worker
received the first three cases and a review worker received the last two,
once for each source snapshot. Workers were given the fixture instructions,
their assigned cases and snapshot root, and permission to read applicable
linked guidance. They were asked for JSON containing next actions, a user
response, guidance used, and conflicts or uncertainty. They did not receive
the grading rubric, implementation diff, or other workers' outputs, and did
not execute the hypothetical actions. Cases within each worker shared a
context, so this is five matched decisions across four sessions, not ten
independent sessions.

Host: Codex desktop on Windows. Workers inherited the active model and effort
without overrides. Exact model/build, reasoning effort, and desktop version
were not exposed in their responses and are recorded as unknown. No token,
latency, or cost measurements were captured.

The JSON response contents are retained with normalized formatting:

- [Control authority](../tests/gpt6/results/2026-09-19-reaudit/control-authority.json)
- [Candidate authority](../tests/gpt6/results/2026-09-19-reaudit/candidate-authority.json)
- [Control review](../tests/gpt6/results/2026-09-19-reaudit/control-review.json)
- [Candidate review](../tests/gpt6/results/2026-09-19-reaudit/candidate-review.json)

## Decision results

| Case | Baseline | Candidate |
|---|---|---|
| Passing skill baseline | Preserved the edit and reported unchanged passes, resolving the old Iron Law against newer evaluation guidance | Preserved the edit and reported unchanged passes directly under the revised evidence policy |
| Blocked isolation | Preserved isolation despite the automatic fallback instruction, relying on user scope and host authority | Preserved isolation and pursued the permission process under the revised worktree instructions |
| Unignored selected location | Checked the actual path and avoided a commit despite the old OR check and commit mandate | Checked the selected path, added the authorized ignore entry, and left it uncommitted |
| Independent review items | Continued independent fixes despite the global stop rule, relying on higher-priority host guidance | Asked for the missing retention choice and continued independent fixes under the skill itself |
| Prose re-review | Accepted inspection evidence despite the universal test-output gate, relying on host verification policy | Accepted inspection evidence directly under the revised controller and reviewer contracts |

All five baseline and candidate decisions met the rubric. Both review workers
also required meaningful regression evidence for the null-handling behavioral
counterfactual. The three successful baseline/candidate evaluations mentioned
inside the first scenario are supplied hypothetical facts, not extra runs.

These results do not demonstrate a behavioral improvement: baseline decisions
already succeeded by resolving contradictory instructions. The verified change
is removal of those conflicts while preserving the sampled successful decisions.

## Executed checks

| Check | Result |
|---|---|
| `node --test tests/gpt6/compatibility.test.mjs` | 7 passed: Codex discovery policy, Muse catalog, Codex startup hook, Kimi/Gemini notice, package metadata staging, sync metadata preservation/removal, Native helper success/failure bookkeeping |
| `bash tests/claude-code/test-worktree-path-policy.sh` | 7 assertions passed |
| `python -B tests/gpt6/hermes-smoke.py` | 14 skills registered; startup notice, size, and later-turn checks passed |
| `node tests/opencode/test-skill-registration.mjs .opencode/plugins/superpowers.js` | 14 valid skills registered; opt-in policy and simulated host-rejection containment passed |
| `bash -n scripts/sync-to-codex-plugin.sh` | Passed |
| Changed JSON manifests and source catalog | Parsed successfully; Muse matches all 14 surviving skills |
| Active reference inspection | No remaining finishing-workflow routing or discovery references; removal assertions and historical records retain the name |
| `git diff --check` | Passed |

Windows commands used Git Bash and the bundled Python runtime; Node tests used
`TEST_TMPDIR=C:/CodexTools`. The OpenCode rejection message is an intentional
fixture, not an activation failure. Python was unavailable on PATH, so the
bundled executable ran the dependency-free Hermes check successfully.

## Independent review and limits

A separate fresh-context worker reviewed the diff and affected active references
without reading behavioral outputs. It found a leftover deletion example in
`skills/writing-skills/persuasion-principles.md`. That example was corrected to
preserve valid work and require honest baseline evidence; the reviewer verified
the correction and reported no remaining actionable findings. This final
supporting-example edit occurred after the candidate snapshot and was checked
statically, not rerun through the behavioral probes.

These are small decision probes and local structural/runtime-fixture checks.
They do not establish reliability across repeated real tasks or live activation
in every supported harness. Full archive/sync integration suites and remote
publication were not run; the changed production sync function was exercised
in an isolated fixture. The installed plugin cache was not updated. Source
changes remain uncommitted.
