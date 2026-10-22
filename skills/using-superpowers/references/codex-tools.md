# Codex tool contracts

Use this reference within an accepted `superpowers-gpt6` workflow. Tool
availability does not authorize delegation, isolation, integration, or
publication. Follow current user instructions and established preferences
within system/developer instructions and host permissions. The current tool
schema takes precedence over examples or historical version claims here.

## Subagent dispatch

Use multi-agent tools only when delegation is authorized and those tools are
available. Do not modify personal Codex configuration to make a workflow run.
If a required capability is unavailable, report it and continue independent
authorized work.

- **Inherited settings:** Omit `model` and `reasoning_effort` when no override
  is authorized. `fork_turns: "all"` (including its default) inherits the
  parent's model and effort and must not receive either override.
- **Authorized override:** Use `fork_turns: "none"` with both `model` and
  `reasoning_effort`, each supported by the current spawn allowlist. Do not
  assume setting only a model preserves the parent's effort. Give the clean
  child its task, constraints, inputs, and required report in `message`.
- **Role:** Put role/task information in `message`. The current
  `collaboration.spawn_agent` has no `agent_type` field; do not invent it.
- **Fix rounds:** Reuse the implementer through `followup_task`. It delivers
  the follow-up and starts a turn when the agent is idle. `send_message`
  delivers information without starting an idle agent. A new worker is not
  required merely because the first completed its turn.
- **Lifecycle:** Use only lifecycle tools exposed in the current session;
  do not assume `close_agent` exists. Preserve the implementer's context for
  review fixes. If a capability or agent is actually unavailable, report
  that result before choosing an authorized replacement.

## Waiting on children

Continue useful independent work while children run. When genuinely idle,
use the available event wait, which wakes on mailbox activity or new user
input, rather than repeatedly polling status.

Choose a timeout within all three bounds: the current tool's supported
range, the host's blocking limit, and time remaining before the next required
user update. In this host, blocking calls must not exceed 60 seconds. With a
60-second update cadence and 45 seconds elapsed, a 15-second wait fits the
current `wait_agent` minimum of 10 seconds. If too little time remains for a
supported wait, give the due update first. Check the live schema when these
limits differ; there is no five-to-ten-minute minimum imposed by this skill.

On wake, handle new results and resume work. On timeout, give any due update.
Use `list_agents` when evidence suggests a stalled task or missing report;
a timeout alone does not require another status call. Keep later waits
within the same bounds.

## Environment detection

Use the read-only Git inspection in
[superpowers-gpt6:using-git-worktrees](../../using-git-worktrees/SKILL.md#step-0-detect-existing-isolation).
Different Git/common directories require the submodule guard before being
treated as a linked worktree. An empty branch name means detached HEAD:
no branch is checked out. It proves neither ownership, sandbox restrictions,
nor permission to publish.

Establish provenance from the host's worktree records or the session's
creation record. Establish capabilities from current tools, permissions,
and observed results. Establish authorization from the human's request and
applicable instructions, independently of Git state.

## Native worktree setup

When isolation is authorized, use the Codex app's native tools:

1. Call `list_artifacts`. Reuse a suitable active worktree attached to this
   task, checking its repository, workspace path, and intended starting state.
   A fresh-worktree request may call for a new one; ordinary workflow entry
   does not. Keep the exact attachment identity for cleanup.
2. If a suitable managed checkout exists but needs attachment, use
   `attach_worktree` only within its current ownership/attachment rules. It
   reuses the checkout without resetting files or running setup again.
3. Otherwise call `create_worktree` with the current required arguments
   (currently `allowAsync: true`). Choose `ref` to match the authorized start;
   omission uses the remote default branch, not necessarily the current
   branch. Current creation does not copy uncommitted changes. Preserve them
   and resolve any task dependency before proceeding in the new checkout.
4. If creation or attachment returns an `operationId`, check
   `get_worktree_creation_status` until completed or failed, doing independent
   work between checks and spacing unchanged checks farther apart. If creation
   succeeded but registration failed, use the returned workspace path with
   `attach_worktree` as the current contract directs.
5. Use the returned workspace directory for subsequent commands; the calling
   shell does not automatically move. Inspect its state before setup or edits.

A native refusal is not permission for manual `git worktree add`, deletion,
or other lifecycle workarounds. Report the specific limitation and preserve
work. Manual creation is a fallback only when native creation is unavailable
and the worktree workflow authorizes it.

## Codex app finishing

Honor an integration action already authorized, while preserving any remaining
design, review, or execution checkpoint. Detached HEAD can be given a branch
when the chosen action needs it, using a permitted native control or Git.
It is not a reason to ask the human to choose the same action again.

Do not infer permission to stage, commit, push, publish, discard, or create a
PR from Git state or tool availability. If a required operation is blocked,
report the actual limitation and supported handoff options; continue
authorized preparation and preserve the work. Do not claim a branch control
or handoff capability exists without checking the current host.

### Native worktree cleanup

For authorized cleanup of a Codex-managed worktree:

1. Call `list_artifacts` and identify the task's active worktree. Retain its
   exact `identityKey`; do not derive it from a path or detached HEAD.
2. Inspect and preserve needed ignored files separately. `archive_worktree`
   saves a recoverable Git snapshot of local changes, unpushed commits, and
   non-ignored untracked files; ignored files are not included.
3. Call `archive_worktree` with that exact `identityKey` as `root`. Include
   attached PR identity keys only as directed by its current contract. Inspect
   the outcome: only confirmed archiving completes workspace cleanup. It keeps
   the chat open and does not modify GitHub PRs.
4. From a surviving checkout, verify remaining branches and linked worktrees
   before following
   [superpowers-gpt6:finishing-a-development-branch](../../finishing-a-development-branch/SKILL.md#step-7-cleanup-branch).
   An archive success does not prove that a branch was deleted or is unused.

Primary, pinned, shared, or otherwise ineligible worktrees may be refused.
If archival is unavailable, refused, or uncertain, preserve the checkout and
branch and report the limitation. Never bypass refusal with Git or filesystem
deletion. Never archive the chat as a substitute for archiving its worktree.
