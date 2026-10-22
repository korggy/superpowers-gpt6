---
name: using-git-worktrees
description: Use when the human requests or accepts worktree isolation, a standing preference applies, or an accepted workflow explicitly includes an isolated workspace.
---

# Using Git Worktrees

## Overview

Use this workflow when isolation is selected, including as a supporting step of an accepted workflow. A generic coding request or skill availability does not select it. Honor current instructions, established preferences, and accepted design or execution checkpoints within system/developer instructions and host permissions.

Prefer your platform's native worktree tools. Fall back to manual git worktrees only when no native tool is available and isolation is authorized.

**Core principle:** Detect existing isolation first. Then use native tools. Then fall back to git. Never fight the harness.

**Announce at start:** "I'm using the using-git-worktrees skill to set up an isolated workspace."

## Step 0: Detect Existing Isolation

**Before creating anything, inspect existing isolation and the task's worktree preference.** In Codex, call `list_artifacts` and look for a suitable active worktree attached to this task. Match its repository, path, and starting state to the authorized work; use its workspace path. Do not assume the current shell moved when a native tool created or attached a checkout.

Inspect Git state in the selected checkout. These read-only commands work in PowerShell and Bash; stop on a failed command rather than interpreting empty output as a valid state:

```text
git rev-parse --show-toplevel
git rev-parse --absolute-git-dir
git rev-parse --path-format=absolute --git-common-dir
git branch --show-current
git rev-parse --show-superproject-working-tree
```

**Submodule guard:** Different Git and common directories can also occur inside a submodule. If `--show-superproject-working-tree` returns a path, inspect that context before treating the current checkout as a linked worktree.

**If the absolute Git and common directories differ (and not a submodule):** You are already in a linked worktree. Reuse it when suitable for this task and skip to Step 2. Do not create a second checkout merely because this workflow started.

Report with branch state:
- On a branch: "Already in isolated workspace at `<path>` on branch `<name>`."
- Detached HEAD: "Already in isolated workspace at `<path>` (detached HEAD; no branch checked out)."

Detached HEAD proves only that no branch is checked out. Establish ownership from host/session records, and capabilities from current tools, permissions, and observed results. Create a branch only when the authorized work needs one. Git state does not authorize staging, committing, publishing, or cleanup.

**If no suitable worktree exists:** Use an already-authorized isolation choice without asking again. If isolation is still optional and no preference applies, offer it briefly:

> "Would you like me to set up an isolated worktree? It protects your current branch from changes."

If the user declines, work in place and do not repeat the offer. Continue independent authorized work while an optional choice is pending. If isolation is a required checkpoint of the accepted workflow, pause only work that depends on it and explain the applicable requirement.

## Step 1: Create Isolated Workspace

**You have two mechanisms. Try them in this order.**

### 1a. Native Worktree Tools (preferred)

With isolation authorized, use the host's current native creation or attachment tools. For Codex, follow [native worktree setup](../using-superpowers/references/codex-tools.md#native-worktree-setup): inspect attachments, reuse a suitable existing checkout, or create/attach one and use the returned workspace path. Confirm asynchronous completion before setup.

Native tools manage placement and lifecycle; they may use detached HEAD and may not copy uncommitted changes. Check the current contract and intended starting ref. Record the returned identity and path for later cleanup.

Only proceed to Step 1b if no native worktree tool is available. A native refusal is not permission to bypass it with Git. Preserve the current work and report the actual limitation; use the existing checkout only when the authorized scope allows it.

### 1b. Git Worktree Fallback

**Only use this if Step 1a does not apply** — you have no native worktree tool available. Create a worktree manually using git.

#### Directory Selection

Follow this priority order. Explicit user preference always beats observed filesystem state.

1. **Check your instructions for a declared worktree directory preference.** If the user has already specified one, use it without asking.

2. **Check for an existing project-local worktree directory** with the host's filesystem tools. If both `.worktrees/` and `worktrees/` exist, `.worktrees/` wins.

3. **If there is no other guidance available**, default to `.worktrees/` at the project root.

#### Safety Verification (project-local directories only)

**MUST verify directory is ignored before creating worktree:**

```text
git check-ignore -- <chosen-directory>
```

Check the actual chosen directory, not either of two candidates. If it is not ignored, add the narrow ignore rule when that edit is authorized, preserving existing rules, then verify it. Do not stage or commit merely to create a worktree. If the required edit is outside scope, choose an authorized external location or resolve that dependency first.

**Why critical:** Prevents accidentally committing worktree contents to repository.

#### Create the Worktree

```text
git worktree add -b <feature-branch> <quoted-workspace-path> <verified-start-ref>
```

Quote arguments for the active shell; prefer PowerShell 7+ on Windows. Inspect success before changing directory. Record the task, path, start ref, branch, creation result, and cleanup authority; a directory name alone does not prove task ownership.

**Permission failure:** Report the observed failure. Continue in the current checkout only if the task permits working there; do not silently drop a required isolation boundary or work around a native refusal.

## Step 2: Project Setup

Inspect repository setup instructions and existing dependencies. Run only setup needed for the authorized task, using the project's package manager and lockfile conventions. Native creation may already have run setup. Reuse a ready environment rather than reinstalling merely because the skill started.

## Step 3: Verify Clean Baseline

Inspect applicable baseline evidence for the selected checkout. Reuse recorded results when the covered code/artifact, inputs, and environment are unchanged, including inspected results from another worker. Run missing or invalidated affected tests and mandatory project checks. Broaden verification for relevant changes, failures, or integration risk, not merely because a new workflow step began.

**If checks fail or remain unavailable:** Record the failure and its scope. Investigate within the task's authority; pause dependent implementation only when the baseline prevents safe progress or an accepted checkpoint requires a decision. Continue independent authorized work.

**If applicable checks pass:** Report ready with the commands/results or reused evidence and any unverified scope. Do not imply a focused check was the full suite.

### Report

```
Worktree ready at <full-path>
Applicable baseline: <checks and results, reused evidence, or known limitations>
Ready to implement <feature-name>
```

## Quick Reference

| Situation | Action |
|-----------|--------|
| Suitable linked or attached worktree | Reuse it (Step 0) |
| In a submodule | Inspect superproject context (Step 0 guard) |
| Native worktree tool available | Use it for authorized isolation (Step 1a) |
| No native tool | Authorized Git worktree fallback (Step 1b) |
| `.worktrees/` exists | Use it (verify ignored) |
| `worktrees/` exists | Use it (verify ignored) |
| Both exist | Use `.worktrees/` |
| Neither exists | Check instruction file, then default `.worktrees/` |
| Directory not ignored | Verify authorized ignore edit; no automatic commit |
| Permission error on create | Preserve work; honor actual scope and refusal |
| Tests fail during baseline | Report and investigate; pause only dependent work |
| Applicable evidence unchanged | Reuse it; run missing or invalidated checks |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I'm obviously not in a worktree — no need to check" | Run Step 0. Harness-created isolation and submodules both fool eyeballing; the detection commands settle it. |
| "`git worktree add` is quicker than hunting for a native tool" | A native tool (e.g. `EnterWorktree`) owns placement, branching, and cleanup. Bypassing it is the #1 mistake — it creates phantom state your harness can't see or manage. |
| "The worktree directory is surely ignored already" | Run `git check-ignore`. An unignored worktree directory commits the whole tree into the repo. |
| "Any directory name works" | Explicit instructions beat an existing project-local directory, which beats the `.worktrees/` default. |
| "Detached HEAD means the sandbox owns it" | It only means no branch is checked out. Verify provenance and capabilities independently. |
| "The workspace is fresh — baseline checks can wait" | Establish applicable baseline evidence before attributing failures to new work. Reuse valid results; run missing checks. |
