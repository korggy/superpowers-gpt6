# Install Superpowers GPT-6 from the shared ZIP

This package contains the customized Superpowers GPT-6 6.4.1 plugin for Codex.
It includes 14 opt-in skills and the startup workflow-choice notice. It does
not include the removed `finishing-a-development-branch` workflow. Installing
upstream Superpowers from a public marketplace will not install this fork.

## Requirements

- Codex desktop and a Codex CLI that supports `codex plugin add` and
  `codex plugin marketplace add`. Check with `codex plugin --help`.
- Node.js available as `node` on PATH for the startup notice and optional
  brainstorming visual companion. Restart Codex after changing PATH.
- Git and Bash for workflows that use the bundled shell helpers. On Windows,
  Git for Windows supplies Bash; your agent must be able to locate it.

No Python, package build, API key, or separate MCP server is required to install
this package. Your projects may have their own development dependencies.

## 1. Extract the ZIP

Extract `superpowers-gpt6-6.4.1.zip` into a permanent location. Keep the entire
extracted folder, including the hidden `.agents` directory. The folder contains:

```text
superpowers-gpt6-6.4.1/
  INSTALL.md
  .agents/plugins/marketplace.json
  plugins/superpowers-gpt6/
    .codex-plugin/plugin.json
    .codex-plugin/hooks.json
    .codex-plugin/session-start.cjs
    skills/
    assets/
    LICENSE
```

For example, in Windows PowerShell:

```powershell
Expand-Archive -LiteralPath "$HOME\Downloads\superpowers-gpt6-6.4.1.zip" -DestinationPath "$HOME\CodexPlugins"
$packageRoot = Join-Path $HOME 'CodexPlugins\superpowers-gpt6-6.4.1'
codex plugin marketplace add "$packageRoot"
codex plugin add superpowers-gpt6@superpowers-gpt6-shared
```

On macOS or Linux, extract the ZIP, then substitute its absolute folder path:

```sh
codex plugin marketplace add "/absolute/path/to/superpowers-gpt6-6.4.1"
codex plugin add superpowers-gpt6@superpowers-gpt6-shared
```

The first command registers the bundled local marketplace; the second installs
the plugin. Keep the extracted source folder for future reinstalls and updates.
The manifest version includes a build suffix to distinguish this customized
package from other 6.4.1 builds.

## 2. Enable and load it

Check the installation:

```sh
codex plugin list --marketplace superpowers-gpt6-shared --json
```

The installed entry should be `superpowers-gpt6@superpowers-gpt6-shared`, with
`installed: true` and `enabled: true`. If needed, enable it in Codex's plugin
settings. Start a new Codex task; restart the desktop app if it retains the old
skill catalog.

Review and approve the bundled SessionStart hook through Codex's hook-trust
controls when prompted. Its Node.js script reads the bundled invocation policy
and returns that text as session context. Installing the plugin does not itself
trust hooks. Explicit skill requests remain available if hooks are disabled.

If another Superpowers edition is enabled, disable that edition in plugin
settings to avoid duplicate or conflicting guidance.

## 3. Try it

In a new task, ask:

> Use Superpowers GPT-6 brainstorming to help design a small todo application.

An explicit request invokes the named workflow without asking again whether to
use it. The workflow should clarify material design choices before affected
implementation. For a generic coding request, the agent may suggest a relevant
workflow and must wait for acceptance before invoking it. Declining a suggestion
must not start that workflow or cause repeated offers.

## Updates and removal

For an update, replace the extracted package folder with the new complete
package. Do not overlay new files onto old files: removed skills could remain.
If the folder moves, register its new absolute path again. Reinstall with
`codex plugin add superpowers-gpt6@superpowers-gpt6-shared`, then start a new task.
If an update appears stale, compare the listed version with the new manifest;
the distributor should provide a new build suffix for changed content.

To uninstall this shared copy:

```sh
codex plugin remove superpowers-gpt6@superpowers-gpt6-shared
codex plugin marketplace remove superpowers-gpt6-shared
```

This package is for Codex local-plugin installation. Other harnesses require
their own packaging. The plugin's README contains upstream background and
multi-harness examples; use this guide to install this shared fork.

Reference: [OpenAI plugin packaging and local marketplaces](https://developers.openai.com/plugins/build/plugins).
