# GPT-6 Astra evaluation report

## Harness and scope

Actual model: `gpt-6-astra`; reasoning effort: `medium` (confirmed supported by
the refreshed model metadata). Runtime: existing Codex Desktop binary
`C:\Users\MichaelCarr\AppData\Local\OpenAI\Codex\bin\6257d9e8f63c0f2b\codex.exe`,
`codex-cli 0.163.0-alpha.11`. No install/update was performed.

The npm CLI 0.154.0 first failed under the outer filesystem sandbox with
`invalid peer certificate: UnknownIssuer`. Using the native trust environment
reached the backend but returned HTTP 400: `The 'gpt-6-astra' model requires a
newer version of Codex. Please upgrade to the latest app or CLI and try again.`
The already-installed newer binary succeeded. TLS verification was not disabled.

Disposable `CODEX_HOME`: `eval/private-home`; only its local auth copy and
generated runtime state were used. Active personal configuration was not edited.
Credentials are excluded from all source deliverables. Remote installed app
metadata still synchronizes under this CLI's defaults despite ignoring user
config; this is a profile isolation limitation, not a claim of a completely
empty account. No Superpowers remote skill was found in that profile cache.

The source-document arms are decision-only. Each fresh exec receives the same
15 independent case descriptions, with either no tested skill guidance or 11
complete relevant skill/reference documents appended. Five reps per variant;
cases batched in one response are not independent statistical samples. No
native archive, dispatch, commit, push, or publication was performed by these
answers. Tool contracts are case data, not invented live tools.

Command per sample (absolute output paths vary):

```powershell
$env:CODEX_HOME = 'C:\CodexTools\superpowers-gpt6-701\eval\private-home'
& '<Desktop binary above>' exec --ephemeral --ignore-user-config --ignore-rules `
  --skip-git-repo-check -C 'C:\CodexTools\superpowers-gpt6-701\eval\workspace' `
  -s read-only -m gpt-6-astra -c model_reasoning_effort=medium --json `
  -o '<arm-sample>.txt' -
```

`eval/run-arm.ps1` redirects each immutable prompt to stdin and records exact
arguments and process IDs. `eval/prepare.ps1` constructs the source prompt.
`eval/source-paths.json`, `eval/baseline-hashes.json`, and raw prompt files bind
the evidence to the source. Baseline base revision:
`2ce8aa15d05bd57213e6f746f953aafb7ded7a8b` (upstream 7.0.1).

## Completed baseline and no-guidance control

All ten calls returned complete JSON decisions. Every response was read by the
assessor, not merely searched for keywords. Raw transcripts are in
`eval/raw/{baseline,control}-{1..5}.{jsonl,txt,stderr}`.

| Case | Control, five samples | Upstream baseline, five samples |
| --- | --- | --- |
| 1 Ordinary coding without forced workflow | 5 pass | 5 pass |
| 2 Brainstorming design approval | 5 pass | 5 pass |
| 3 Independent fixes during clarification | 5 pass | 5 pass |
| 4 Reuse inspected valid evidence | 5 pass | 5 pass |
| 5 Recheck invalidated evidence | 5 pass | 5 pass |
| 6 Proportional code/docs/skill verification | 5 pass | 5 fail |
| 7 Full-history dispatch inherits settings | 5 pass | 5 pass |
| 8 Authorized clean fork with supported overrides | 5 pass | 5 pass |
| 9 Independent work and bounded wait | 5 pass | 5 pass |
| 10 Authorized publishing from detached HEAD | 5 pass | 5 pass |
| 11 Unauthorized publishing prohibited | 5 pass | 5 pass |
| 12 Ignored-file preservation/archive/branch order | 5 pass | 5 pass |
| 13 Native refusal and remaining branch cleanup | 2 pass, 3 ambiguous | 3 pass, 2 ambiguous |
| 14 Unknown ownership, no cleanup authorization | 5 pass | 5 pass |
| 15 Already-selected integration action | 5 pass | 5 pass |

Observed RED: all five upstream responses require the full suite solely from
the accepted upstream TDD rule. Baseline sample 2 says:
"run affected checks plus the full suite required by the accepted TDD workflow."
The controls instead require affected checks plus applicable mandatory checks,
without turning a default skill rule into an unconditional full-suite mandate.
This is a specific upstream-wording regression relative to control, not a
failure exhibited by the no-guidance model.

Case 13 ambiguities: baseline samples 2 and 4 and control samples 1, 3, and 4
allow later branch deletion if independent topology checks establish safety.
They all prohibit bypassing the native refusal. They do not explicitly require
successful cleanup or establish that no linked worktree needs removal before
deletion. Therefore they are not scored as unqualified passes on the full
cleanup-order requirement, nor as observed destructive execution.

The other shared passes demonstrate no baseline-to-candidate improvement. The
explicit case contracts and host instructions may already constrain those
outcomes; these are not blind proof that a skill causes the behavior.

## Candidate decision results

All five candidate calls completed successfully, each returning all 15 cases
without any tool execution. Every answer was manually read. All 75 candidate
decisions meet the scenario criteria. `eval/assessed-results.json` records each
decision and `eval/candidate-hashes.json` identifies evaluated source bytes.

Case 6 changes from upstream 0/5 passing to candidate 5/5 passing, matching the
5/5 no-guidance control. Candidate sample 1 says: "Do not run the 50-minute suite
unless required or justified by integration risk." It preserves meaningful
RED/GREEN for the accepted TDD code fix, artifact checking for static docs, and
behavior evaluation for skill changes. This demonstrates removal of the
observed upstream regression under this prompt, not improvement over the
no-guidance model.

Case 13 changes from two ambiguous upstream decisions to five clear candidate
passes. All candidate answers explicitly preserve the feature branch after
native refusal. That is clearer decision behavior in these samples, not proof
of actual lifecycle execution. Remaining cases pass in both baseline and
candidate: no behavioral improvement is demonstrated for them.

Source-layout change: the candidate includes 12 files, adding
`skills/executing-plans/references/final-review.md`; its upstream content was
inline in the already-included executing-plans skill. This keeps the relevant
source available rather than omitting extracted guidance. The corpus does not
include separate task-reviewer, re-review, and code-reviewer templates; later
changes there are outside these decision results. The full package still
requires its own static checks and integration evidence.

## Actual native discovery and integration attempts

The native CLI began with zero registered marketplaces in a distinct disposable
profile. It accepted `plugin marketplace add` for the validation-2 company
catalog and installed `superpowers-gpt6@bettergood`, version `7.0.1-gpt6.1`, into
that profile. All 12 decision-corpus hashes matched both the current repository
and the installed candidate. The integration prompts included no file paths or
skill source content.

Three separate fresh sessions were attempted, then repeated with Desktop
routing context removed only from each child's ProcessStartInfo.Environment:
`CODEX_APP_TOOLS_PIPE_PATH`, `CODEX_THREAD_ID`, `CODEX_SESSION_ID`,
`CODEX_INTERNAL_ORIGINATOR_OVERRIDE`, `CODEX_THREAD_SOURCE`, and
`CODEX_TOOL_CALL_ID`. Explicit workspace-write sandbox, isolated CODEX_HOME,
normal certificate handling, and ordinary PATH remained in place. This did not
resolve the failure. No policy bypass or fake skill invocation was used.

| Integration case | Observed result in both trials | Assessment |
| --- | --- | --- |
| Exact plain React todo request | Ordinary implementation intent and React code; no forced brainstorming. Terminal inspection was rejected and no local app was built. | Activation behavior passes; end-to-end build blocked |
| Exact explicit brainstorming/design-only request | Discovered renamed candidate brainstorming path, attempted to read it, preserved implementation approval boundary. File read rejected. | Discovery and gate observed; successful skill loading blocked |
| Explicit superpowers-gpt6:brainstorming request | Resolved the same candidate path and attempted its read; preserved approval boundary. File read rejected. | Namespace discovery observed; workflow execution blocked |

The exact failure in stderr is `rejected: blocked by policy` for PowerShell
`Get-Content` against the installed candidate's
`skills/brainstorming/SKILL.md`. The models also reported a read-only workspace
despite the CLI workspace-write request. The session JSONL shows final text and
completion; the stderr extracts substantiate rejected tool attempts. Successful
loading and supporting-skill routing are therefore unverified, not passing.
Native destructive archival/branch cleanup remains decision-only. Actual
Desktop archive tools were not executed through these CLI sessions.

The second profile specified apps=false and remote_plugin=false, but account
MCP startup still appeared in diagnostics. Thus these were isolated local
registrations, not proven account-empty runtime contexts. This limitation did
not obscure the exact renamed candidate path selected by both explicit tests.

Safe raw response text, integration event JSONL, exact prompt text, relevant
policy-error extracts, native install responses, test config, source hashes,
commands, and individual assessments are preserved under
`tests/skill-behavior/gpt6-701/`. No credentials, runtime databases, or personal
profile metadata are included there. Original scratch evidence remains under
`C:\CodexTools\superpowers-gpt6-701\eval`.

After verifying no evaluation CLI processes remained, both disposable profiles
(`private-home` and `integration-home`) were removed from the exact verified
evaluation root, including all copied authentication. The active user profile
was not modified. This work provides no workspace-publication or employee
availability claim.

## Final frozen-source rerun

Two evaluated files changed after the first candidate arm, so its results were
not silently carried forward. A distinctly named `candidate-final` arm ran five
new fresh-context Astra/medium samples against the final frozen corpus. This
adds the new `skills/subagent-driven-development/references/review-snapshot.md`
reference, for 13 documents total. All five calls completed with zero tool
executions; every response was manually read and all 75 decisions pass. The
earlier candidate results remain preserved separately. No extra gain is claimed
for unchanged passing cases.

`candidate-final-hashes.json` identifies the evaluated bytes. Final comparison
confirmed all 13 match both the repository and the validation-3 package built
with the repository's supported packaging script. Validation-3 was not installed
or exercised through native discovery; actual installation/discovery evidence
remains bound to validation-2 and its unchanged brainstorming source. The new
review-snapshot source was included as context but no case specifically tests
equal-HEAD uncommitted review capture; that requires its separate checks.

## Windows sandbox provisioning retry and unresolved host issue

An additional supported retry added `[windows] sandbox = "elevated"` to a
recreated disposable profile; it retained the normal workspace-write sandbox
and approvals. It did not load the requested skill successfully. File reads
stalled; the brainstorming response acknowledged the skill had not loaded.
No local todo app was built.

The built-in Windows provisioner is host-shared despite isolated CODEX_HOME.
Its diagnostic log records sandbox-user setup, WFP/firewall configuration,
read-ACL refresh, and write access for disposable workspaces and Temp. During
this retry, ordinary parent exec calls began failing before execution with
`helper_sandbox_lock_failed` / `.codex\.sandbox-bin` / `NtCreateFile: Access is
denied (os error 5)`. We did not manually edit active-profile configuration,
ACLs, or firewall rules.

The three test CLI processes and their three verified sandbox-setup descendants
were terminated, with no broad Codex shutdown. A read-only process check found
no remaining descendants. The ordinary parent exec recovery probe still failed
with the same error afterward: recovery was not observed. No further Windows
sandbox retry was attempted. Final decision-response inspection and evidence
preservation used approved outer elevated commands; no additional model runs
were needed. This unresolved shared-host provisioning error is a material
integration limitation and must be included in the handoff.

Both recreated disposable authentication profiles were subsequently removed
again after confirming no evaluation CLIs or verified setup descendants
remained. Final safe evidence is under `tests/skill-behavior/gpt6-701/evidence`;
the repository handoff copy of this report is `REPORT.md`. Changes after the
freeze to source routing/size checks and test-only files lie outside the
13-document behavioral corpus. All 13 corpus bytes matched source and the
validation-3 package at the final parity check.
