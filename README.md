# Superpowers GPT-6 — BetterGood

An opt-in GPT-6 Astra/Codex fork of [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent. Based on upstream **7.0.1**; customized version **7.0.1-gpt6.1**. MIT licensing and original attribution are retained.

The plugin ID is `superpowers-gpt6`. Explicit skill references use `superpowers-gpt6:brainstorming`, `superpowers-gpt6:writing-plans`, and the other unchanged skill names. Installing this package does not select a model or change global settings.

## Choosing a workflow

Ask for a skill, accept an offer, establish a preference, or use a supporting step of a workflow you already chose. Ordinary coding requests do not force brainstorming, TDD, delegation, or worktree creation. Accepted design and execution checkpoints still apply: asking for brainstorming does not approve its design.

The 15 skills cover brainstorming, plans, inline and delegated execution, debugging, TDD, reviews, verification, worktrees, branch finishing, skill authoring, and plugin diagnosis. The compact 7.0.1 references and plan ledger remain in place.

On Windows, use PowerShell 7+ and Git. See [plan helper commands](skills/subagent-driven-development/references/plan-helpers.md). Codex uses its native agent and managed-worktree tools where available; capability and authorization come from the current host, not the branch name or detached HEAD.

## Build and distribute

Run `pwsh -File scripts/build-gpt6-package.ps1` from this checkout. It creates a versioned plugin archive and a separate BetterGood marketplace under `dist/`, with exact candidate file hashes and upstream/base revisions. See [release and migration instructions](docs/GPT6-RELEASE.md) and [validation results](docs/GPT6-VALIDATION.md).

The source checkout does not register a development marketplace. Local registration, isolated test installation, workspace import, and employee availability are separate steps. No publication or active-profile installation is performed by the build.

## Development

The accepted [customization specification](docs/prompts/superpowers-7.0.1-gpt6-customization.md) defines the fork. [Contributor guidelines](AGENTS.md) retain upstream requirements for contributions to upstream; BetterGood customizations stay in this fork. [Testing](docs/testing.md) covers applicable checks. Other harness adapters are retained; their current validation status is listed in the report.

Upstream project: [obra/superpowers](https://github.com/obra/superpowers). Fork: [korggy/superpowers-gpt6](https://github.com/korggy/superpowers-gpt6). See [LICENSE](LICENSE) for original copyright and license terms.
