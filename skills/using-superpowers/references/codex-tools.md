## Subagent dispatch requires multi-agent support

Add to your Codex config (`~/.codex/config.toml`):

```toml
[features]
multi_agent = true
```

This enables the multi-agent tools that skills like
`dispatching-parallel-agents` and `subagent-driven-development` use.
Which tools you get depends on the multi-agent version your model
preset selects (current presets run V2; older ones run V1). Trust your
actual tool list over any table — including this one — when they
disagree.

- **Spawning:** give children a clean context with
  `spawn_agent {fork_turns: "none"}`; the default `"all"` copies your
  entire transcript into the child. Full-history forks inherit the
  parent's model and reasoning effort: omit `model` and
  `reasoning_effort` when `fork_turns` is `"all"`. Overrides require
  `fork_turns: "none"` and must be permitted by the current tool contract
  and the user's or applicable workflow's instructions. Put the role
  and task in `message`; use an `agent_type` field only if the actual
  tool exposes it.
- **Fix rounds:** resume the implementer with `followup_task` — it
  delivers your message, triggers a turn, and transparently reloads a
  child the harness evicted. Never dispatch a fresh implementer on the
  theory that a spawned agent cannot be messaged again; on V2 it
  always can.
- **Lifecycle:** V2 has no `close_agent`. Finished children are
  evicted automatically when slots are needed; leaving them unclosed
  costs nothing. Only V1 sessions have `close_agent` — there, close
  reviewers when their review returns, and close each implementer
  after its task's review passes.
- **Model names:** never copy a model name from a skill, table, or old
  session into `spawn_agent` without checking it against your current
  spawn allowlist — V2 accepts only V2-capable presets and hard-errors
  on the rest.

## Waiting on children

Use the current wait tool's event behavior and timeout limits. An event
wait can wake on child activity; avoid repeated short polls when no new
information or action is expected.

- While you still have local work, do not wait at all. A completed
  child's final answer is pushed into your mailbox and arrives with
  your next turn.
- When genuinely idle, choose a bounded wait that fits the tool's
  supported range, any host limit on blocking calls, and the time
  remaining before the next required user update. For example, with a
  60-second update cadence and 45 seconds already elapsed, wait at most
  15 seconds if the tool permits. If too little time remains for a
  supported wait, give the due update before waiting again.
- On wake, handle new results and resume useful work. On timeout,
  provide any due update and check child status when there is evidence
  of a missing report or stalled task. A timeout alone does not require
  another status-list call. Keep future waits within the same bounds;
  there is no fixed minimum wait duration imposed by this skill.

## Model routing on spawns

When a requested workflow calls for a particular model tier, dispatch an
isolated fork (`fork_turns: "none"`) with both `model` and
`reasoning_effort`, using values allowed by the current tool. Do not
assume that setting a model preserves the parent's effort. When no
override is called for, inherit the session settings. A full-history
fork always inherits them; never combine it with either override.

Ask your human partner to add a machine-level backstop to
`~/.codex/config.toml` so any spawn that slips through still routes to
a deliberate tier instead of silently inheriting the session's most
expensive model:

```toml
[agents]
default_subagent_model = "<a mid-tier model from your spawn allowlist>"
default_subagent_reasoning_effort = "medium"
```

## Environment Detection

Skills that create worktrees or finish branches should detect their
environment with read-only git commands before proceeding:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → check the submodule guard in
  `using-git-worktrees` Step 0; if linked, reuse the existing worktree.
- `BRANCH` empty → detached HEAD: no branch is currently checked out.
  This does not establish who created the workspace, what the sandbox
  permits, or whether publication is authorized.

Determine provenance from the host's worktree records or the session's
creation record. Determine capabilities from current tool descriptions,
permissions, and observed results. Determine authorized actions from the
human's request and applicable instructions, independently of Git state.

See `using-git-worktrees` Step 0 and `finishing-a-development-branch`
Step 2 for how each skill uses these signals.

## Codex App Finishing

A detached HEAD can be given a branch before an authorized integration
or publication step, using the available native controls or Git commands
permitted by the host. Honor an integration choice the human already
made; detached state does not require asking them to choose it again.

If a required operation is actually blocked, report the specific
limitation and available native branch or handoff options. Do not infer
a sandbox denial from detached state, or commit, stage, push, or create a
PR merely because this fallback is being discussed. Continue authorized
verification and preparation; preserve work when the requested action
cannot be completed.

### Native worktree cleanup

For authorized cleanup of a Codex-managed worktree, use the app's native
worktree tools. With the current `codex_app` tools:

1. Call `list_artifacts` and identify this task's active worktree. Retain
   its exact `identityKey`; do not derive the identity from a directory
   name or detached HEAD.
2. Preserve needed ignored files separately before archiving. The tool
   saves a recoverable Git snapshot of local changes, unpushed commits,
   and non-ignored untracked files; ignored files are not included.
3. Call `archive_worktree` with that `identityKey` as `root`, then inspect
   the result. Only confirmed archiving completes workspace cleanup.
   It keeps the chat open and does not modify GitHub PRs.
4. From a surviving checkout, inspect the remaining branch and worktree
   state before applying `finishing-a-development-branch` Step 7. A
   successful archive does not by itself prove the branch was deleted
   or is unused elsewhere.

Use the current tool contract if capabilities change. Primary, pinned,
shared, or otherwise ineligible worktrees may be refused. If the tool
is unavailable or refuses, preserve the checkout and branch and report
the limitation; do not bypass it with Git or filesystem deletion. Do
not archive the chat as a substitute for archiving its worktree.
