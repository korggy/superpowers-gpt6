# Superpowers GPT-6 7.0.1-gpt6.1 validation

Local candidate, 2026-10-21. Implementation and targeted checks are complete. Native discovery succeeded in a disposable profile, but successful skill loading remains blocked by the Windows sandbox failure described below. This is not an end-to-end compatibility or publication claim.

## Provenance and scope

Upstream 7.0.1: `2ce8aa15d05bd57213e6f746f953aafb7ded7a8b`. Earlier customization inspected: `6ff96f4a47f2291ca20a3ddb3a01e3e236ba0246`, based on `bb92a77741419a4ab5f06e711a283343f1ada0c3`. The candidate is uncommitted. Each build's `PROVENANCE.json` records exact source and payload hashes and labels the Git revision as its base only.

The fork preserves the 7.0.1 brainstorming organization, compact skills, extracted references, plan ledger and contribution templates. Its explicit specification changes activation, authorization, verification, Windows helpers, agent/worktree contracts and identity. It does not configure a model globally or publish anything.

## Guidance

Implementation follows [OpenAI's GPT-6 Astra skill guidance](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra), current tool schemas, [plugin packaging](https://developers.openai.com/plugins/build/plugins), and [workspace plugin import](https://learn.chatgpt.com/docs/enterprise/plugin-management), checked 2026-10-21. The exact Astra migration Markdown URL could not be retrieved through the available web client (unsupported content type); shell retrieval failed certificate authentication. That gap was not filled with an invented model capability. No API/model-registry migration was needed.

## Behavior evaluation

Fresh no-guidance control, upstream baseline, initial candidate, and final candidate: five samples each, 15 decisions per sample, actual `gpt-6-astra`, effort `medium`, Codex Desktop bundled CLI `0.163.0-alpha.11`. The older npm CLI rejected Astra. Every response was read and assessed. The final candidate includes 13 complete skill/reference documents, including the extracted final-review and review-snapshot guidance; hashes identify the evaluated bytes.

All **75 final-candidate decisions pass**. In the proportional-verification case, upstream passes 0/5, final candidate 5/5, and no-guidance control 5/5. The candidate removes the observed upstream insistence on a 50-minute full suite under that prompt; it does not demonstrate improvement over the no-guidance model. Native-refusal branch preservation is explicit in all candidate samples, while two upstream and three control answers were ambiguous about later deletion. Other shared passing cases establish no demonstrated improvement.

Cases are batched within each sample and are not statistically independent. These are source-guided decision evaluations, not blind causal proof or execution of the proposed operations. No live native worktree archival, refusal, branch deletion or publication was performed. Separate task-reviewer/code-reviewer templates, diagnostic routing and other adapter files are outside the 13-document behavior corpus. The evaluation report (`REPORT.md`), source hashes, scenarios, commands and raw safe outputs are in `tests/skill-behavior/gpt6-701/` in the repository; test evidence is not shipped as plugin runtime content.

## Deterministic checks

| Check / command from repository root | Observed result |
| --- | --- |
| `pwsh -NoProfile -File tests/powershell/test-plan-helpers.ps1` | 52/52 checks pass, with PATH restricted to PowerShell and Git |
| `bash tests/claude-code/test-executing-plans-scripts.sh` | 25/25 checks pass |
| `pwsh -NoProfile -File tests/powershell/test-plan-helper-interoperability.ps1 -GitBash 'C:\Program Files\Git\bin\bash.exe' -TempRoot 'C:\CodexTools\superpowers-gpt6-701\bash-temp'` | 3/3 checks pass |
| `node --test tests/package/test-gpt6-package.mjs` with `GPT6_TEST_MARKETPLACE` set to the built catalog directory | 3/3 checks pass: source identity/assets, 15 skill names/sizes, catalog/payload provenance |
| `bash tests/skill-size/test-skill-size.sh` | All 15 skills below 20,000 bytes |
| `bash tests/hooks/test-session-start.sh` | 13 checks pass; retained Claude hook tested, Codex manifest still has empty hooks |
| `node tests/opencode/test-skill-registration.mjs .opencode/plugins/superpowers.js` | Registration, paths and rejection handling pass |
| `node tests/opencode/test-session-bootstrap.mjs .opencode/plugins/superpowers.js` | Session classification, recovery and cache lifetime pass |
| `node tests/opencode/test-bootstrap-caching.mjs .opencode/plugins/superpowers.js present` | Present-file caching checks pass |
| `node --test tests/pi/test-pi-extension.mjs` | 6/6 tests pass |
| `python -m pytest tests/hermes/test_bootstrap.py tests/hermes/test_plugin.py -q -p no:cacheprovider` | 25/25 tests pass |
| `bash tests/kimi/test-plugin-manifest.sh`, `bash tests/devin/test-devin-plugin.sh`, `bash tests/antigravity/test-plugin-manifest.sh` | Static manifest/layout checks pass; native `agy` unavailable and skipped |
| `bash tests/diagnosing-superpowers/test-skill-structure.sh` | 46/46 checks pass, including 998-word skill body |
| `git diff --check` | Pass |

Helper runtime: PowerShell 7.6.7, Git 2.55.0.windows.5, Git Bash 5.3.15. Bash helper fixtures used `TMPDIR=C:/CodexTools/superpowers-gpt6-701/bash-temp`. The native suite requires no Bash. Adapter scripts' `python3` command was mapped to the existing `C:\CodexTools\Python\python.exe`; pytest 8.4.2 and its test dependencies were installed only under the task scratch directory and selected through process-local `PYTHONPATH`. Nothing was added to the plugin's runtime dependencies.

Helper logs are in `tests/powershell/evidence/`. Tests exercised literal empty/quoted/metacharacter/newline/Unicode arguments, exact fenced task extraction, collisions, invalid revisions, command failures, output capture, ledger integrity, existing-evidence attestation and nested Bash helpers without executable bits. Existing evidence remains caller-attested: unchanged HEAD alone does not establish unchanged files, inputs or environment. The independent source review's findings were resolved, including an explicit route for reviewing uncommitted changes when BASE equals HEAD.

## Native discovery and integration limits

An isolated local profile started with zero marketplace registrations, accepted the built BetterGood catalog, and installed **`superpowers-gpt6@bettergood` / `7.0.1-gpt6.1`**. Installed validation-2 source hashes were recorded. Three fresh sessions used the exact plain React todo prompt, the explicit brainstorming/design-only prompt, and the renamed namespace prompt. The plain request did not force brainstorming. Both explicit requests selected the candidate's renamed skill path and retained the approval boundary, but PowerShell reads were rejected with `blocked by policy`. Skill content was therefore not successfully loaded, and supporting-skill routing remains unverified.

A second attempt removed inherited Desktop routing variables only from the child environment and failed the same way. A third configured the supported Windows sandbox mode used by the host. It triggered shared Windows sandbox provisioning despite the isolated `CODEX_HOME`, then stalled. The test CLI processes and their verified sandbox-setup descendants were stopped. Subsequent ordinary terminal calls still failed with `helper_sandbox_lock_failed` / `NtCreateFile: Access is denied` at the host `.sandbox-bin`; recovery was not observed. No manual ACL/firewall changes or policy bypass was attempted. Remaining repository checks used separately approved tool execution outside the failing sandbox provisioning path.

The final source arm was rerun after the reviewed source changes; it is bound to the final 13-document hashes. Integration observations remain bound to validation-2's installed bytes, not a successful test of the final archive. Account MCP startup also appeared despite isolated local registrations and disabled app/remote-plugin settings, so account-empty isolation was not established. Disposable profiles and copied authentication were retired after test-owned processes stopped. Active profile configuration and installed plugins were not intentionally changed; the host-shared sandbox provisioning effect above is a separate observed limitation.

The next integration attempt should follow recovery of ordinary Codex terminal execution and use a fresh host session with controlled isolation. Repeat both required exact prompts and the explicit namespace invocation, verify the loaded candidate hash, and exercise supporting-skill routing before claiming end-to-end compatibility. A Codex restart is a recovery check, not a verified fix from this run.

## Remaining scope and handoff

No full upstream suite or end-to-end run of other harnesses is claimed. Native managed-worktree lifecycle cases are decision-only; the separate linked-worktree helper suite was not rerun. Execute-bit behavior was exercised on Git Bash/Windows, not a separate POSIX host. PowerShell 7 minors other than 7.6.7 were not tested.

The final local artifacts are under `dist/7.0.1-gpt6.1/`: plugin ZIP, BetterGood marketplace ZIP/directory, per-file provenance and archive checksums. The source remains uncommitted on its original base revision. No push, PR, workspace import, employee installation or publication occurred. [Release and identity migration steps](GPT6-RELEASE.md) describe the separate manual handoff.
