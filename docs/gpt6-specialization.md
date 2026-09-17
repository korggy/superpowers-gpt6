# GPT-6 specialization

This fork targets Codex sessions using GPT-6 Astra. Its starting point is upstream Superpowers 6.3.0, commit `b36e082`. It keeps all 14 skill names, but gives the Codex plugin the distinct identity `superpowers-gpt6`. Model selection remains a host setting; loading a skill cannot switch the parent model.

## Design decisions

| Concern | Implementation |
| --- | --- |
| Repeated approval and workflow restarts | One shared scope and authorization policy. Continue accepted implementation; preserve explicit audit-only, plan-only, and approval boundaries. |
| Over-prescribed process | Short entrypoints with specific triggers; conditional techniques remain in references. Routine edits do not start a design-to-release pipeline. |
| Excessive or ritual testing | Match checks to behavior and risk. Reuse evidence until relevant code, configuration, environment, or dependencies change. Keep failing required behavior incomplete. |
| Unsupported delegation examples | Consult actual runtime schemas. Full-history forks inherit settings; optional model overrides require a compatible fork mode and justified routing. No invented `agent_type`. |
| Shared-state collisions | Delegate only bounded independent work with ownership. Serialize Git mutations and competing builds. Workers do not commit shared changes. |
| Endless review cycles | Adjudicate findings against requirements and evidence; repeated failures trigger reassessment, not a fixed-count permission gate or false completion. |
| Destructive Git assumptions | Preserve the named checkout. A folder name is not proof of worktree ownership. Integration, publishing, and cleanup follow actual authorization. |
| Latest-commit-only reviews | Review the relevant baseline through the full implementation, including applicable uncommitted and untracked changes. |
| Packaging dependency on another distribution | Maintain all 14 `agents/openai.yaml` files locally and build with Python and parsed YAML validation. Distinguish committed releases from explicit working-tree previews. |

The central policy lives in `skills/using-superpowers/references/workflow-policy.md`. Active entrypoints link it instead of independently redefining authorization and completion. The Codex adapter and SDD execution reference carry runtime-specific detail.

## Packaging and compatibility

The source manifest intentionally retains `hooks: {}` to suppress discovery of the inherited Claude SessionStart hook when installing from the repository. The portable archive excludes hooks entirely and removes that source-only manifest field. These are different distribution shapes, not an accidental manifest mismatch.

The inherited upstream sync script is disabled for this fork. The Python/PyYAML packager performs no install, push, or publication. Its versioned `packaging/codex-files.json` selects every shipped file and required script resource. Retired instructions are archived under `docs/upstream/retired-skills`; legacy adapters used by source integrations stay in place but are excluded from the portable distribution. All selected Markdown and YAML is validated both before packaging and against the built archive. Its default uses committed HEAD and refuses dirty state. `--working-tree` is an explicit preview; `--allow-dirty` still packages a committed ref. Archives have deterministic entry order, timestamps, and modes. Outputs belong outside the source checkout and require explicit overwrite.

Legacy harness adapters, hooks, and historical design documents remain source provenance. This implementation targets Codex; compatibility with Claude, Gemini, Pi, and other harnesses has not been revalidated. Upstream contribution rules are archived in `docs/upstream/CONTRIBUTING.md`; the fork's contributor instructions are in `CLAUDE.md`.

Version 6.3.0 records the upstream base; no fork release or installed-plugin update is claimed. Choose a release version before separately authorized distribution. Use only one of upstream and fork workflow suites for a task to avoid ambiguous skill discovery.

## Evidence and limits

See [testing.md](testing.md), [evaluation results](gpt6-evaluation-results.md), and [scenario definitions](../tests/gpt6/scenarios.json). Structural validation, executable packaging tests, independent instruction review, and live isolated smoke probes cover different failure modes. None establishes a general quality, token, latency, or cost improvement.

Fresh top-level Codex discovery after installation and repeated model-pinned comparisons remain release validation work. They were not simulated by subagent probes or silently performed as account changes.

## Sources

The audit consulted the official guidance on September 17, 2026:

- [GPT-6 Astra prompting best practices](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6-astra#prompting-best-practices): preserve intent and authorization, supply decision boundaries, delegate deliberately, and scale verification to useful evidence.
- [Rethinking skills and prompts for GPT-6 Astra](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra): specialize skills around useful domain knowledge, explicit outcomes, and progressive disclosure instead of rigid process instructions.

These changes are an implementation judgment informed by that guidance, not an OpenAI certification or a claim that every upstream procedure is ineffective.
