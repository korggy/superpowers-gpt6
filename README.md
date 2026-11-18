# Superpowers GPT-6 — BetterGood

BetterGood’s opt-in edition of Superpowers provides 15 development workflows. Version `7.0.2-gpt6.1` is based on upstream 7.0.2 by Jesse Vincent and contributors. [Upstream Superpowers](https://github.com/obra/superpowers) · [MIT license](LICENSE)

Ask for a workflow by name, accept an offer, or establish a preference. For example, “Use brainstorming to design a React todo list” selects brainstorming and leaves implementation for later approval. An ordinary coding request can proceed directly. Supporting skills follow the workflow you have accepted.

Codex discovers the skills under `superpowers-gpt6:`. Use `superpowers-gpt6:brainstorming` to name one explicitly. The session controls model and reasoning effort. The release evaluation targets `gpt-6.2-astra`.

On Windows, the plan helpers use PowerShell 7+ and Git. Existing plans and completion ledgers use the same `.superpowers` locations. [Plan helpers](skills/subagent-driven-development/references/plan-helpers.md)

## Build and distribution

Run `pwsh -NoProfile -File scripts/build-gpt6-package.ps1` in the source checkout. It creates a plugin ZIP, a BetterGood marketplace ZIP, an extracted marketplace and SHA-256 checksums under `dist/`. Both catalogs install `superpowers-gpt6@bettergood`. The repository catalog resolves the plugin at the repository root. The distribution catalog resolves it under `plugins/superpowers-gpt6`. [Release and workspace upgrade](docs/GPT6-RELEASE.md)

The source checkout contains the evaluation report, helper and adapter tests, and contributor guidelines. [Validation](https://github.com/korggy/superpowers-gpt6/blob/7.0.2-gpt6/docs/GPT6-VALIDATION.md) · [Contributor guidelines](https://github.com/korggy/superpowers-gpt6/blob/7.0.2-gpt6/AGENTS.md)
