# Recorded commands and reproduction

Observed runtime: Codex CLI `0.163.0-alpha.11`, the already installed Desktop
binary at `C:\Users\MichaelCarr\AppData\Local\OpenAI\Codex\bin\6257d9e8f63c0f2b\codex.exe`.
Model `gpt-6-astra`, effort `medium`; both were confirmed by refreshed runtime
metadata. No model substitution or software update was used.

Each decision sample executed the following arguments, with stdin containing
`scenarios.txt` plus complete source documents for baseline/candidate. Five
fresh calls were made for each arm. A distinct output basename recorded each.

```powershell
$env:CODEX_HOME = 'C:\CodexTools\superpowers-gpt6-701\eval\private-home'
& $CodexBinary exec --ephemeral --ignore-user-config --ignore-rules `
  --skip-git-repo-check -C 'C:\CodexTools\superpowers-gpt6-701\eval\workspace' `
  -s read-only -m gpt-6-astra -c model_reasoning_effort=medium --json `
  -o '<arm>-<sample>.txt' -
```

The baseline is upstream commit `2ce8aa15d05bd57213e6f746f953aafb7ded7a8b`.
The candidate is uncommitted; its 12-file evaluated corpus is identified by
`evidence/candidate-hashes.json`, not by the baseline commit. The additional
candidate final-review reference was inline in the upstream executing-plans
skill. Source equality with the installed test package is recorded separately.

`run-decision-evaluation.ps1` is a portable sequential reproduction wrapper
for the same sampling procedure. It was added after the recorded runs and
PowerShell-parsed without errors; the original recorded harness launched the
same five independent calls concurrently. Prepare an isolated authenticated
profile and an empty disposable workspace before using it. It does not copy
credentials or modify the active profile.

Native integration used another disposable profile with this initial config:

```toml
model = "gpt-6-astra"
model_reasoning_effort = "medium"
[features]
apps = false
remote_plugin = false
```

Native install commands, run with that profile's `CODEX_HOME`:

```powershell
& $CodexBinary plugin marketplace list --json
& $CodexBinary plugin marketplace add 'C:\Visual Studio Projects\superpowers-gpt6\dist\validation-2\bettergood' --json
& $CodexBinary plugin add superpowers-gpt6@bettergood --json
```

Each integration session used a separate empty fixture workspace:

```powershell
$env:CODEX_HOME = 'C:\CodexTools\superpowers-gpt6-701\eval\integration-home'
& $CodexBinary exec --ephemeral --ignore-rules --skip-git-repo-check `
  -C '<integration-plain|integration-brainstorm|integration-namespace workspace>' `
  -s workspace-write -m gpt-6-astra -c model_reasoning_effort=medium --json `
  -o '<integration-case>.txt' -
```

The exact prompts are preserved beside response text and JSONL events. The
integration config was loaded so the native local plugin registration would
participate. No skill contents or explicit filesystem path were included in
these prompts. Discovery therefore came from the installed candidate.

Important observed limitations: the integration runtime still initialized
account MCP plugins despite the feature settings, and its policy rejected the
attempted PowerShell skill reads. A request for workspace-write did not produce
successful local editing in these sessions. These failures are evidence, not
successful skill-loading or end-to-end implementation results. Outer native
certificate access was allowed; no TLS or inner policy bypass was used.

The three integration calls were repeated using ProcessStartInfo.ArgumentList
with the same explicit arguments and new empty fixture directories. Only these
inherited Desktop routing variables were removed from child environment:
`CODEX_APP_TOOLS_PIPE_PATH`, `CODEX_THREAD_ID`, `CODEX_SESSION_ID`,
`CODEX_INTERNAL_ORIGINATOR_OVERRIDE`, `CODEX_THREAD_SOURCE`, and
`CODEX_TOOL_CALL_ID`. No user/system environment was edited. The same policy
rejection persisted; both trial sets are preserved. The disposable profiles
were removed after all processes exited, including copied authentication.

After two evaluated source files changed, five additional calls used the same
decision command and a `candidate-final` output prefix. The final corpus adds
`skills/subagent-driven-development/references/review-snapshot.md`, for 13
documents. See `evidence/candidate-final-hashes.json` and
`evidence/candidate-final-parity.json`; the earlier 12-document results remain
separate. Every final response was manually assessed.

A final integration retry used the supported `[windows] sandbox = "elevated"`
setting in a recreated disposable profile. Reads stalled and its built-in
shared sandbox provisioning coincided with parent `.sandbox-bin` access-denied
errors. Only the three test CLIs and their verified setup descendants were
terminated. The normal parent sandbox probe still failed afterward. No manual
ACL/firewall changes or further integration retries were attempted. Both
recreated test profiles were removed after all test processes exited.
