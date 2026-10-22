# BetterGood GPT-6 release and migration

This fork is `superpowers-gpt6`, display name **Superpowers GPT-6 — BetterGood**, version `7.0.1-gpt6.1`, based on upstream Superpowers 7.0.1 by Jesse Vincent (MIT). Its skill namespace is `superpowers-gpt6:`. Individual skill names and internal `.superpowers` plan workspaces are unchanged. Model selection remains a host/session choice.

## Local artifacts

Run `pwsh -File scripts/build-gpt6-package.ps1` in the checkout. The build writes a plugin ZIP, a separate BetterGood marketplace ZIP and extracted directory, `SHA256SUMS.txt`, and `PROVENANCE.json`. The latter records the upstream/base revisions and exact uncommitted source and payload hashes. A base commit is not the candidate revision. The builder refuses an existing output directory.

The marketplace root contains `.agents/plugins/marketplace.json` and `plugins/superpowers-gpt6/`. Its catalog is named `bettergood`, with a local source path `./plugins/superpowers-gpt6`. It has no workspace `pluginId` and carries no active-profile settings. The source checkout has no development catalog. Codex uses `.codex-plugin/plugin.json`; its intentional `hooks: {}` suppresses automatic loading of the retained Claude hook.

## Company release (manual, after approval)

1. Review the source diff, validation report, ZIP contents, and checksums. Decide whether any unverified scope is acceptable.
2. Commit and push the reviewed marketplace contents to the intended **GitHub** distribution repository. Preserve the catalog and plugin layout. This build performs neither action. If the marketplace is at repository root, leave the import Path empty; otherwise use the directory containing `.agents/plugins/marketplace.json`.
3. A workspace admin opens **Admin > Plugins > Add > Import marketplace**, supplies the GitHub repository URL, marketplace Path, and desired branch/tag/commit, and authorizes repository access. Review the import results and each plugin's role installation policy. Use **Sync now** for later updates. These controls are documented by OpenAI; they are not a promise of a Publish button on the local plugin card.
4. Verify the new named plugin in the BetterGood workspace directory, then test installation from an employee account. Local registration or a successful isolated test does not establish workspace publication or employee access.

Current workspace import supports GitHub repositories. Azure DevOps can remain a source mirror, but registering it locally does not populate the BetterGood organization tab. These steps follow [OpenAI workspace plugin management](https://learn.chatgpt.com/docs/enterprise/plugin-management), checked 2026-10-21.

## Migration from `superpowers`

Treat the new identity as a distinct plugin. Review the old workspace entry and policies before any replacement; do not add its `pluginId` to this catalog automatically. Publish and validate the new identity first, then have admins and employees intentionally select it and retire the old identity when appropriate. Update saved instructions from `superpowers:<skill>` to `superpowers-gpt6:<skill>`; historical transcripts remain unchanged. Avoid having both variants supply the same skill names during migration verification.

For a local disposable test profile, current Codex CLI supports marketplace add and plugin add. The selector is `superpowers-gpt6@bettergood`. Inspect that CLI's `--help` for the installed version and set an isolated `CODEX_HOME` before using it. These are local test operations and should not be run in an employee's active profile as part of building the release.

The supported Codex compatibility manifest is retained rather than migrating unrelated harness formats. See [OpenAI plugin packaging](https://developers.openai.com/plugins/build/plugins). Other harness adapters retain their upstream paths and use the customized identity; see the validation report for which were actually exercised.
