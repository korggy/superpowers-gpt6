# GPT-6.2 Astra skill evaluation

Five fresh decision-only sessions per arm, with 18 cases per session. The control received the scenarios alone. The baseline received the relevant upstream 7.0.2 documents at `22f0b463e7a5e579904dd6211a520321035526f7`. The candidate received the packaged skill documents. All 19 candidate inputs have the same SHA-256 in the final archive. Both source-guided arms include the reviewer and implementer prompts. The fork extracts two additional review references from the upstream workflow text.

| Arm | Pass | Fail | Indeterminate |
| --- | ---: | ---: | ---: |
| No guidance | 82 | 7 | 1 |
| Upstream 7.0.2 | 85 | 5 | 0 |
| BetterGood 7.0.2-gpt6.1 | 90 | 0 | 0 |

**What changed in these samples.** On case 6, all five upstream responses required the long suite for a task that mixed a documentation correction, a TDD regression, and a skill edit. All five candidate and control responses selected verification appropriate to each change. The candidate and upstream tied on the other 17 cases. On cases 16 and 17, both source-guided arms more consistently did the available reconnaissance and recommended a concrete option. All three arms tied on 15 cases. The batched cases are correlated. These results compare the complete supplied guidance under one model and effort.

**Reproduction.** The recorded comparison used the Windows desktop CLI `0.169.0-alpha.11.1`, `gpt-6.2-astra`, and medium effort. Use `run-decision-evaluation.ps1` with `-Arm control|baseline|candidate`, an absolute `-CodexBinary`, a disposable authenticated `-IsolatedCodexHome`, an empty `-Workspace`, and a distinct `-OutputDirectory` for each arm. For baseline use an exported upstream tree as `-SourceRoot`. For candidate use the extracted `plugins/superpowers-gpt6` directory. The runner disables plugins, remote plugin discovery and apps for all three arms. Preliminary runs before disabling these features were excluded. The upstream tree and the control were frozen before any candidate skill edits.

An independent reviewer scored the fifteen responses against the criteria fixed before scoring. The raw response texts, their hashes, and per-sample scores are retained with the two corpus manifests. [Rubric](RUBRIC.md) · [Control and upstream scores](evidence/control-baseline-scores.json) · [Candidate scores](evidence/candidate-scores.json)

A separate fresh session used the three packaged instructions for Codex tools, the fix loop and the review snapshot. Given an idle implementer and uncommitted work with identical BASE and HEAD, it selected a follow-up to that implementer, preserved the original review state, and required a new snapshot covering the fix. This was a decision probe. Native worktree archiving, refusal, and deletion were also assessed as decisions. [Fix-round response](evidence/fixed-findings.txt)

The installed tests use ordinary skill discovery through the Codex app-server, including a native skill mention for the namespace case. The driver records resolved model, installed path, file hash, user turns, tool completions and worktree file evidence. A completed turn can still report denied reads. Grade its actual events and output before claiming a pass. See the [package validation report](../../../docs/GPT6-VALIDATION.md).
