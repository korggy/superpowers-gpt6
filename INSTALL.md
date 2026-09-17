# Install Superpowers GPT-6

This ZIP contains 14 coding-workflow skills for Codex, specialized for GPT-6 Astra. Install it once in your personal local marketplace to use it across projects on this machine.

## Before you start

- Have an up-to-date Codex desktop app and sign in with your own account.
- Have access to GPT-6 Astra in the model selector.
- Keep the ZIP's files together, including the hidden `.codex-plugin` directory. You do not need this project's source repository or its build dependencies.

## Recommended: ask Codex to install it

1. Extract the ZIP into a folder. On Windows, right-click the ZIP and choose **Extract All**. Open the extracted folder and confirm that it contains this file, `README.md`, `skills`, and `.codex-plugin` (enable hidden items if needed).
2. In Codex, open that extracted folder as a local project and start a task.
3. Paste this request:

   ```text
   Use $plugin-creator to install the existing Superpowers GPT-6 package in
   this folder as my personal local plugin. This authorizes the local
   installation and personal marketplace registration.

   Copy the complete package into my user profile's plugins/superpowers-gpt6
   folder, preserving its bundled manifest, skills, assets, license, and
   attribution. Do not replace this package with a generated scaffold.
   Preserve existing unrelated plugins and marketplace entries. If this
   plugin is already installed, inspect its source and version before
   updating it with the supported reinstall/cache refresh procedure.

   Use my actual personal marketplace name; do not assume it is personal.
   Install with the supported Codex CLI and verify that the resulting
   plugin is installed and enabled and that all 14 skills are present.
   Do not publish anything or automatically uninstall other plugins.
   ```

4. Allow the requested local installation if Codex presents a permission prompt. The expected result is an installed, enabled plugin named **Superpowers GPT-6** (`superpowers-gpt6`).
5. Start a **new task in your normal project**, select **GPT-6 Astra**, and try:

   ```text
   Use Superpowers GPT-6 to review this project and recommend the next steps.
   Do not change any files yet.
   ```

The plugin does not change your model selection. If you also use upstream Superpowers, disable it for tasks using this fork to avoid overlapping workflow instructions.

## Check the installation

Open the app's Plugins area and look for **Superpowers GPT-6** among installed plugins. In the CLI, `codex plugin list --json` should include an entry for `superpowers-gpt6` with `installed: true` and `enabled: true`.

If the skills are missing, start a new task; refresh or restart Codex if needed. Ask Codex to check the installed plugin path and marketplace entry if the problem persists. If `codex` is not found or `plugin add` is unavailable, ask Codex to locate its bundled CLI or follow the [official CLI setup instructions](https://learn.chatgpt.com/docs/codex/cli). Do not copy someone else's account credentials.

## Updates and removal

For an update, extract the new ZIP separately and ask Codex to update the existing personal plugin using Plugin Creator. Editing an extracted folder alone does not refresh Codex's installed cache. Start a new task after the update.

To remove it, uninstall **Superpowers GPT-6** from the app's Plugins area, or ask Codex to uninstall that exact plugin. Your project files are separate from the plugin.

## About this distribution

The local installation flow has been exercised on Windows with Codex CLI `0.155.0-alpha.2.6`. Other operating systems have not been validated for this fork. Core skills are Markdown instructions; optional visual and shell helpers can require additional runtimes and are not installation prerequisites.

This is a community fork, not an official OpenAI plugin. See [README.md](README.md), [LICENSE](LICENSE), and [NOTICE.md](NOTICE.md).

OpenAI documents the local marketplace and new-conversation workflow in [Build plugins](https://learn.chatgpt.com/docs/build-plugins) and [Test the complete plugin](https://developers.openai.com/plugins/deploy/connect-chatgpt#test-the-complete-plugin).
