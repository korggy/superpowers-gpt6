# BetterGood release and workspace upgrade

**Superpowers GPT-6 — BetterGood** version `7.0.2-gpt6.1` uses the existing selector `superpowers-gpt6@bettergood` and the `superpowers-gpt6:` skill namespace. Upstream Superpowers 7.0.2 supplies the release base. Individual skill names, existing `.superpowers` ledgers and the MIT attribution continue across this upgrade. Model and effort are session settings. [Upstream release](https://github.com/obra/superpowers/pull/2657)

## Build and inspect

From the source checkout in PowerShell 7+, run the following commands. Pass a new directory with `-OutputDirectory` to choose another destination. Git Bash or another Bash installation is required for the second catalog check.

```powershell
$build = pwsh -NoProfile -File scripts/build-gpt6-package.ps1 | ConvertFrom-Json
$env:GPT6_TEST_MARKETPLACE = $build.marketplaceDirectory
node --test tests/package/test-gpt6-package.mjs
bash tests/codex/test-marketplace-manifest.sh
Get-Content -LiteralPath $build.hashes
```

| Result | Contents |
| --- | --- |
| Plugin ZIP | Installable plugin with its Codex manifest, runtime adapters, 15 skills, license and provenance |
| Marketplace ZIP and extracted `bettergood/` directory | Distribution catalog and the same plugin under `plugins/superpowers-gpt6/` |
| `PROVENANCE.json` inside the plugin | Source base, upstream release, prior customization, catalog fix and SHA-256 hashes of build inputs and copied payload files |
| External `SHA256SUMS.txt` | SHA-256 of each complete ZIP |

The repository catalog at `.agents/plugins/marketplace.json` points to `./`. Its generated counterpart points to `./plugins/superpowers-gpt6`. Both refer to the same plugin name and use local sources. The workspace assigns its own plugin identifier. Codex uses native skills discovery and the manifest’s explicit empty hooks object. The separate Claude and Copilot hook files serve their respective hosts.

The source checkout contains `docs/GPT6-VALIDATION.md` and the decision evaluation under `tests/skill-behavior/gpt62-702/`. Consult those results for the tested CLI, model, installed reads, workflow handoff and outstanding coverage. The full archive digests belong in the external checksum file and release handoff.

## Manual BetterGood workspace upgrade

The Windows-built ZIPs target the Codex marketplace. For Unix hosts that directly execute a startup hook, install the reviewed Git revision so checkout preserves the tracked executable bits. Codex discovers skills through its manifest, and its Bash plan helpers are invoked through Bash.

1. When release is authorized, review the candidate, validation gaps and checksums. Confirm the repository URL, ref and import path configured on the **existing BetterGood marketplace**. Compare them with the intended release target.
2. Publish the reviewed revision through the approved release process. A repository-root import uses the tracked root catalog and an empty import path. A distribution import needs both the generated catalog and its adjacent `plugins/` tree at the configured path.
3. A workspace administrator opens the existing BetterGood marketplace and selects **Sync now**. Check the sync result and the version displayed for **Superpowers GPT-6 — BetterGood**. Keep existing access policies unless a policy change has been separately authorized.
4. Verify visibility and installation from an eligible employee account. Record the visible version and a successfully loaded skill on that surface. The build, source installation and workspace sync each provide different evidence. [OpenAI workspace plugin management](https://learn.chatgpt.com/docs/enterprise/plugin-management)

For a disposable CLI check, register each catalog in its own isolated profile, install `superpowers-gpt6@bettergood`, and list the marketplace. Compare the installed manifest and skill hashes with the candidate. A fresh session can then exercise the installed skill through its normal entry point. [Codex plugin structure](https://developers.openai.com/plugins/build/plugins)
