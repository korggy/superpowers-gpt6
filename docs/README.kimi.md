<!-- GPT-6 fork: retained adapter guidance; consult docs/GPT6-VALIDATION.md for current test coverage. -->
# Superpowers for Kimi Code

Complete guide for using Superpowers with [Kimi Code](https://github.com/MoonshotAI/kimi-code).

## Installation

This fork is not claimed to be available in Kimi Code's public marketplace. Install a reviewed, published fork revision when available.

Open the plugin manager:

```text
/plugins
```

Use the fork identity `superpowers-gpt6` when selecting or managing it.

You can also install from this repository:

```text
/plugins install https://github.com/korggy/superpowers-gpt6
```

For unreleased validation against `dev`, pin the branch explicitly:

```text
/plugins install https://github.com/korggy/superpowers-gpt6/tree/<reviewed-fork-branch>
```

Kimi Code applies plugin changes to new sessions. After installing, updating, enabling, disabling, or reloading a plugin, start a fresh session with `/new`.

## How It Works

The Kimi plugin manifest lives at `.kimi-plugin/plugin.json`.

The manifest does three things:

1. Points Kimi Code at the existing `skills/` directory.
2. Loads `using-superpowers` at session start through `sessionStart.skill`.
3. Provides Kimi-specific tool mapping through `skillInstructions`.

Kimi Code reads Superpowers skills from this repository. There are no copied skills, symlinks, hooks, or extra runtime dependencies.

## Tool Mapping

Skills describe actions instead of hard-coding one runtime's tool names. On Kimi Code these resolve to:

- "Ask the user" / "ask clarifying questions" -> `AskUserQuestion`
- "Create a todo" / "mark complete in todo list" -> `TodoList`
- "Dispatch a subagent" -> `Agent`
- "Invoke a skill" -> Kimi Code's native `Skill` tool
- "Read a file" / "write a file" / "edit a file" -> `Read`, `Write`, `Edit`
- "Run a shell command" -> `Bash`
- "Search file contents" -> `Grep`
- "Find files by path or pattern" -> `Glob`
- "Fetch a URL" -> `FetchURL`
- "Search the web" -> `WebSearch`

## Updating

Use Kimi Code's plugin manager:

```text
/plugins
```

Select Superpowers GPT-6 and update it from there. Start a fresh session with `/new` after updating.

## Troubleshooting

### Plugin not loading

1. Run `/plugins info superpowers-gpt6` and check diagnostics.
2. Make sure the plugin is enabled.
3. Start a fresh session with `/new` after install or update.

### Direct GitHub install used an old release

Kimi Code installs the latest GitHub release for a bare repository URL when one exists. To test unreleased changes before the next Superpowers release, install the branch explicitly:

```text
/plugins install https://github.com/korggy/superpowers-gpt6/tree/<reviewed-fork-branch>
```

### Skills not triggering

1. Confirm `/plugins info superpowers-gpt6` shows the plugin enabled.
2. Start a fresh session with `/new`.
3. In one fresh session, try `Let's make a react todo list`. Ordinary coding should proceed without forcing brainstorming.
4. In a separate fresh session, try `Use brainstorming to design a React todo list. Do not implement until I approve the design.` The requested skill should load and preserve the design approval boundary.

These are the fork's acceptance criteria, not a claim that Kimi integration has been tested for this release. See [validation coverage](GPT6-VALIDATION.md).
