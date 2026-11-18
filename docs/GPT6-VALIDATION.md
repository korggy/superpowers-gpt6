# Superpowers 7.0.2-gpt6.1 validation

On November 18, 2026, GPT-6.2 Astra completed the installed brainstorming-to-planning workflow in a WSL2 Ubuntu fixture. On native Windows, the final plugin installed and the client resolved the named skill, but normal shell reads were denied. Native Windows end-to-end skill loading remains open.

## Candidate and artifacts

The local candidate is based on upstream `22f0b463e7a5e579904dd6211a520321035526f7`. The builder records the prior adaptation `a202a7e8`, catalog fix `822d512`, build-input hashes and packaged-file hashes in `PROVENANCE.json`. The working tree includes the uncommitted adaptation.

| File under `dist/7.0.2-gpt6.1-validated/` | SHA-256 |
| --- | --- |
| `superpowers-gpt6-7.0.2-gpt6.1.zip` | `aa450842c8787ca5bf170ca26d022dd8d2be53a0211eba12f9e09ab902f02ad1` |
| `bettergood-marketplace-7.0.2-gpt6.1.zip` | `4b6bf52da71688413a8b26ccd50375b3e4a1e27285b1d44b01ba9b6096623117` |

The Windows desktop CLI `0.169.0-alpha.11.1` installed `superpowers-gpt6@bettergood` from the tracked root catalog and from the extracted final marketplace ZIP into separate fresh local profiles. Both returned version `7.0.2-gpt6.1`. The 114 runtime files in each installed cache matched the final provenance hashes. The Linux CLI `0.170.0` installed the independently extracted final marketplace on WSL2. The app-server verified both skill files against the extracted payload before starting each model session. The profile, CLI and workspace were local to each test surface.

## Installed workflow

All probes requested `gpt-6.2-astra` at medium effort. The app-server returned that model. Each case used a separate, newly initialized Git repository. Design and approval used the same thread. The test sent the ordinary coding and natural-language design requests as plain user text. The explicit mention used the skill name and path returned by native discovery.

| Probe | WSL2 Ubuntu | Native Windows |
| --- | --- | --- |
| Plain React todo request | Began building directly and wrote the React app files. Dependency download was unavailable, so browser behavior was unverified. | Proceeded directly and returned code in chat. The sandbox prevented workspace inspection and the fixture stayed empty. |
| Request brainstorming by name | A successful tool result contained the installed brainstorming skill. Astra asked about motivation, then presented a concrete design. The fixture had zero non-Git files before approval. | Recognized the workflow and presented a design. Native tool execution was denied. |
| Select the namespaced skill | Resolved `superpowers-gpt6:brainstorming`, read the installed skill successfully, and stopped at a design question. | Resolved the installed path and accepted the explicit skill mention. Ordinary sandboxed file reads remained unavailable. |
| Approve the presented design and request a plan only | Successfully read the installed `writing-plans` skill. The only file produced was `docs/superpowers/plans/2026-11-18-react-todo-list.md`. | Returned a plan in chat. A successful supporting-skill read and a saved plan were unverified. |

The packaged brainstorming SHA-256 was `bf871747368e4c83dcfbc0bfbacd0a43b9936150f6b31dac0eb6a2868ba60651`. The evidence records the resolved cache paths, model/thread IDs, prompts, approval boundary, file outcomes and successful Linux tool reads. The Windows preflight also denied a read of a known fixture file before any plugin was installed. [Installed probe evidence](../tests/skill-behavior/gpt62-702/evidence/installed-probes.json)

## Verification

| Check | Observed result |
| --- | --- |
| Fresh decision evaluations | Candidate 90/90 passes, upstream 85/90, control 82 passes, 7 failures and 1 indeterminate. All 19 evaluated candidate files match the final ZIP. [Per-case results and scope](../tests/skill-behavior/gpt62-702/REPORT.md) |
| ZIP and catalog tests | `node --test tests/package/test-gpt6-package.mjs` passed 3/3 with the generated marketplace supplied. `bash tests/codex/test-marketplace-manifest.sh` passed, including both upstream release guards. Archive contents, paths, hashes and exclusions were checked. |
| Windows helpers from the final marketplace ZIP | PowerShell 73/73 and Git Bash interoperability 17/17, including malformed plans, case collisions, six concurrent claimers, preserved evidence, linked worktrees and literal arguments. [PowerShell results](../tests/skill-behavior/gpt62-702/evidence/final-pwsh.log) · [Cross-shell results](../tests/skill-behavior/gpt62-702/evidence/final-interop.log) |
| Bash helpers | Workspace 69/69, executing-plans 34/34, helper-path references 8/8 in the source suites. From the final standalone ZIP on Linux, direct task extraction, repository discovery and nested helper resolution worked with executable bits stripped. |
| Skill and adapter checks | Skill size, layout, worktree path policy and all 46 diagnosis structure checks passed. Ten registered manifest versions agreed. Pi 6/6, Hermes 27/27, OpenCode 5/5 fixture suites, Kimi, Devin, Antigravity static checks, and the brainstorming companion suite passed. Antigravity’s native validator and logo freshness tool were unavailable. |
| Hooks | Windows wrapper 13/13 under both short and long path spellings. Unix hooks 22/22, including zsh fallback and the child-process check. Unix hosts that launch the hook directly should install the Git checkout, which preserves the executable bit. |

The tests covered the affected suites and fixtures. Workspace publication, employee availability and native managed-worktree lifecycle execution have no live acceptance evidence in this run. The current native Windows blocker is the test host’s shell policy. On a native host with functioning sandboxed reads, rerun the four installed workflow checks from the same archive before making a native Windows compatibility claim. [Release handoff](GPT6-RELEASE.md)
