---
name: using-git-worktrees
description: Suggest when requested work needs an isolated checkout. Invoke only when requested or accepted.
---

Follow the [invocation policy](../using-superpowers/references/invocation-policy.md).
Apply this workflow only when requested or accepted, including its stated supporting steps.

# Using Git Worktrees

## Overview

Set up requested isolation with Codex's native worktree tools. Let Codex use the worktree location configured in Settings; do not choose a directory or create a worktree through the shell. If the native tool cannot be used, stop the affected work and ask the user how to proceed.

**Core principle:** Reuse suitable existing isolation. Let Codex manage placement and lifecycle. There is no automatic manual fallback.

**Announce at start:** "I'm using the using-git-worktrees skill to set up an isolated workspace."

## Step 0: Detect Existing Isolation

**Before creating anything, call `list_artifacts` to inspect this chat's attached worktrees, then inspect the current checkout.** Prefer a suitable active worktree. Reuse requires that no ongoing task or process relies on it and that existing changes have been accounted for. An archived worktree is for recovering specific prior work, not a spare checkout for new work.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule guard:** `GIT_DIR != GIT_COMMON` is also true inside git submodules. Before concluding "already in a worktree," verify you are not in a submodule:

```bash
# If this returns a path, you're in a submodule, not a worktree — treat as normal repo
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**If `GIT_DIR != GIT_COMMON` (and not a submodule):** You are already in a linked worktree. If it is suitable for this task, reuse it and skip to Step 2 (Project Setup). Do not create a duplicate merely because its name differs from the current task. Preserve a worktree that is still in use or contains unaccounted-for work.

Before setup in any reused worktree, select its absolute workspace path explicitly and verify its branch, current commit, and relationship to the task's intended base. Prepare the authorized branch and base without discarding existing work; if that cannot be done within scope, preserve the checkout and ask the user. Reuse alone does not establish the correct starting revision.

Report with branch state:
- On a branch: "Already in isolated workspace at `<path>` on branch `<name>`."
- Detached HEAD: "Already in isolated workspace at `<path>` (detached HEAD)."

Determine workspace ownership from the host's metadata or creation record,
not from branch state. Detached HEAD does not imply restricted permissions.
Before integration, preserve the work with an appropriate branch or host
handoff within the authorized scope.

**If `GIT_DIR == GIT_COMMON` (or in a submodule):** You are in a normal repo checkout.

Has the user already indicated their worktree preference in your instructions? If not, ask for consent before creating a worktree:

> "Would you like me to set up an isolated worktree? It protects your current branch from changes."

Honor any existing declared preference without asking. If the user declines consent, work in place and skip to Step 2.

## Step 1: Create Isolated Workspace

When isolation is authorized and no suitable active worktree is available, discover and use Codex's native `create_worktree` tool. Follow its current schema:

- Pass `allowAsync: true`, a short descriptive `name`, and the verified starting commit or branch as `ref`. The tool otherwise defaults to the remote default branch, which may differ from the current checkout; preserve the task's intended base explicitly.
- Let Codex choose the directory using Settings. Do not supply, infer, or override a filesystem worktree location, and do not change Settings to satisfy this skill.
- If creation returns an `operationId`, use `get_worktree_creation_status` until it returns a completed workspace path. Continue independent work between checks and space checks farther apart when progress is unchanged. Do not edit a pending checkout.
- Creating a worktree does not move this chat's working directory and does not copy uncommitted changes. Use the returned absolute workspace directory explicitly for subsequent commands and edits; verify its branch or detached HEAD and starting commit before setup.
- If creation succeeded but registration failed, preserve the returned checkout and report that status. Do not create a second checkout to repair an attachment failure.

**Unavailable or failed native tool:** Stop work that requires creating or managing the worktree, report the exact limitation, and ask the user how to proceed. Preserve any returned paths and operation IDs. Do not use `git worktree add`, a manual clone, a shell deletion, another directory, or an unrequested switch to the original checkout as a fallback. A permission denial is not permission to bypass the native tool. Continue only independent authorized work while awaiting the user's decision.

## Step 2: Project Setup

Run appropriate setup only in the successfully selected, authorized workspace.
Follow repository instructions; typical setup commands include:

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

## Step 3: Verify Clean Baseline

Establish an appropriate baseline for the planned change. Reuse recorded
results only when they cover this code, configuration, and environment.
Otherwise run the relevant project checks; a full suite is appropriate when
required or justified by the planned integration risk:

```bash
# Use project-appropriate command
npm test / cargo test / pytest / go test ./...
```

**If tests fail:** Identify baseline, dependency, or environment causes and
record the limitation. Ask only if the failure blocks the authorized work
or a material scope decision is needed; continue independent work.

**If tests pass:** Report ready.

### Report

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Native Lifecycle and Cleanup

Follow the task's authorized integration and verification requirements before retiring a worktree. Inspect `list_artifacts` again at that lifecycle transition and confirm that no ongoing task or process needs the checkout. Use `archive_worktree` with its exact worktree identity from that listing when an eligible managed worktree is no longer needed; do not remove its checkout with shell or Git worktree deletion commands. Archival saves a recoverable snapshot but does not preserve ignored files, so account for any needed ignored output first.

Do not archive primary, pinned, shared, or in-use worktrees. Use `restore_worktree` only for requested recovery or specific work archived prematurely. If a required native lifecycle operation is unavailable or fails, preserve the checkout and stop to ask the user. A creation or archive request does not itself authorize a push, merge, PR, unrelated ref deletion, or changing the user's Settings.

## Quick Reference

| Situation | Action |
|-----------|--------|
| Suitable active worktree exists | Reuse it after checking ownership, changes, and active work |
| In a submodule | Treat as normal repo (Step 0 guard) |
| New isolation is authorized | Use native `create_worktree`; Settings owns placement |
| Creation is pending | Wait for a completed returned path; keep using explicit workspace paths |
| Native tool unavailable, denied, or failed | Stop affected work and ask; no manual fallback |
| Managed worktree is no longer needed | Verify lifecycle gates, then use native `archive_worktree` |
| Tests fail during baseline | Classify cause; ask only for a blocking scope decision |
| No package.json/Cargo.toml | Skip dependency install |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I'm obviously not in a worktree — no need to check" | Run Step 0. Harness-created isolation and submodules both fool eyeballing; the detection commands settle it. |
| "`git worktree add` is quicker than finding the native tool" | Codex's native tool owns creation and Settings controls placement. Stop and ask if it cannot be used. |
| "A directory from a prior task is the right default" | Use a suitable active attachment or the new path returned by Codex; never hardcode a location. |
| "The tool returned, so this chat moved into the worktree" | Use the returned workspace path explicitly; the chat's working directory is unchanged. |
| "The workspace is fresh — baseline tests can wait" | Establish relevant baseline evidence so later failures can be attributed correctly. |
