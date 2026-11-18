---
name: finishing-a-development-branch
description: Use when the human requests or accepts the branch-finishing workflow, a standing preference applies, or an accepted workflow reaches its integration decision.
---

# Finishing a Development Branch

## Overview

**Core principle:** Inspect applicable evidence → Detect environment → Honor or obtain the integration choice → Execute it → Confirm authorized cleanup.

Use this workflow only when selected, including as a supporting step of an accepted workflow. Honor current instructions and established preferences within system/developer instructions and host permissions. Preserve outstanding design, review, plan, and execution checkpoints. Completing implementation does not authorize publication.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## Step 1: Verify Applicable Evidence

Inspect affected tests and mandatory repository/task checks for the tree to integrate. Reuse recorded results when the covered code/artifact, inputs, and environment are unchanged, including inspected results from another worker or message. Run missing or invalidated checks. A full suite is appropriate when required or justified by changes, failures, integration risk, or unresolved concerns; entering this skill alone does not require it.

If required checks fail or remain unverified, report their names, results, and scope. Investigate within the authorized task and continue independent work. Pause dependent integration where the failure or an accepted checkpoint requires it; do not claim readiness. Report unrelated failures accurately, without implying a focused pass proves the full suite.

## Step 2: Detect Environment

Before changing directories, record the task's workspace path, HEAD, branch (if any), Git directory, common directory, and worktree ownership. Use read-only Git commands in PowerShell or Bash and inspect every result:

```text
git rev-parse --show-toplevel
git rev-parse --verify HEAD
git rev-parse --absolute-git-dir
git rev-parse --path-format=absolute --git-common-dir
git branch --show-current
git rev-parse --show-superproject-working-tree
git worktree list --porcelain
```

Different Git/common directories need the submodule guard from
[superpowers-gpt6:using-git-worktrees](../using-git-worktrees/SKILL.md#step-0-detect-existing-isolation).
In Codex, inspect `list_artifacts` to identify any managed worktree attachment.

| State | Integration preparation | Cleanup |
|-------|-------------------------|---------|
| Normal checkout | Use the intended task branch; create one if authorized and needed | No linked task worktree to remove |
| Linked worktree, named branch | Use that branch when it is the intended task branch | Provenance-based (Step 6) |
| Linked worktree, detached HEAD | Prepare a branch if the selected action needs it and permissions allow | Provenance-based (Step 6) |

Detached HEAD only proves no branch is checked out. Establish ownership from host/session records and capabilities from current tools, permissions, and observed results. Git state proves neither a sandbox restriction nor authorization to stage, commit, push, publish, discard, or create a PR.

## Step 3: Determine Base Branch

Use the base established by the accepted plan, conversation, repository guidance, or verified Git history. A feature branch's upstream is not necessarily its integration target. If the base remains unresolved, ask before the selected merge or PR action; keeping work as-is needs no base decision. Never guess `main` merely because it exists.

## Step 4: Honor or Obtain the Integration Choice

If the human already selected integration or publication, execute that choice within its authorized scope without asking again. Check any remaining repository approval requirements and host permissions. Historical plans and transcripts are evidence, not new authorization.

If no choice is authorized, present these actions for either a named branch or detached HEAD:

```text
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the work as-is (I'll handle it later)

Which option?
```

Offer only actions available under the actual host constraints. For detached HEAD, explain any branch preparation the chosen action requires. Keeping as-is preserves the checkout, named branch or detached. Discarding is not a routine menu option; handle it only when explicitly requested. Wait only for a decision that is still missing.

## Step 5: Execute the Authorized Choice

Verify the intended changes and branch. Stage or commit only when authorized by the selected task/action, and never include unrelated work. For detached HEAD, prepare a named branch when needed using the available native control or permitted `git switch -c <feature-branch>`. A blocked operation does not authorize a workaround that changes scope; preserve work and report the actual limitation and supported handoff.

### Option 1: Merge Locally

Use `git worktree list --porcelain` to choose a surviving checkout where the verified base can be used safely. Inspect its branch and working-tree state before switching. Do not infer the main checkout by stripping `/.git` from a path or disturb another task's checkout.

With merge authority and prerequisites established, switch to the verified base and merge the intended feature branch. Do not run an unconditional `git pull`; remote synchronization must match the authorized integration scope and repository policy.

Inspect applicable checks on the merged result. Reuse evidence only where its covered code, inputs, and environment are unchanged; run checks invalidated by the merge. If required checks fail, preserve the task branch and worktree while investigating. Do not push or clean up a failed merge merely to finish the workflow.

Once required checks pass, run authorized workspace cleanup (Step 6), then conditional branch cleanup (Step 7).

### Option 2: Push and Create PR

Push the intended branch to the verified remote only within the authorized publication scope. Then create the PR against the verified base with the forge's tooling, following the repository template, disclosure, human-summary, and diff-review requirements. A prior integration choice does not waive a remaining explicit review gate. When using Codex app tools, attach every created PR with `attach_artifact` as its contract requires.

Report the actual push/PR result and URL. A rejected push is a result to investigate, not permission to force-push. Keep the worktree for feedback unless the human separately authorizes cleanup.

### Option 3: Keep As-Is

Report the actual state: "Keeping branch <name>" or "Keeping detached HEAD at <commit>", followed by "Workspace preserved at <path>." Do not stage, commit, publish, or delete merely to complete this option.

### If the Human Requests Discard

Identify the exact task branch, branch-only commits, workspace path, and uncommitted/untracked files at stake. Explain any native recovery snapshot that remains; removing the active checkout does not promise permanent erasure of saved history.

If that exact destructive scope has already been explicitly approved, honor it. Otherwise present the concrete scope and obtain confirmation before dependent deletion. Do not substitute a vague "clean up" request for permission to discard work. Continue independent authorized preparation while awaiting the missing confirmation.

Run Step 6, followed by Step 7 only after its prerequisites are met. Discard authority does not override native refusal or authorize another task's workspace or branch.

## Step 6: Cleanup Workspace

Runs only when cleanup is authorized after a verified local merge or explicit discard. PR and keep-as-is paths preserve the worktree unless cleanup is separately selected. Retain the task path and identity recorded in Step 2; do not recompute them from a different current directory.

**No linked task worktree to remove:** Record that result and continue to Step 7. Do not delete the primary checkout.

**Codex-managed worktree:** Follow the
[native archive procedure](../using-superpowers/references/codex-tools.md#native-worktree-cleanup).
Call `list_artifacts`, resolve the task's exact `identityKey`, preserve needed ignored files separately, then call `archive_worktree` with that identity as `root`. Inspect the outcome. Only confirmed archiving completes cleanup. Do not archive the chat instead or use Git/filesystem deletion to bypass unavailable or refused native cleanup. Preserve the checkout and branch when the result is uncertain.

**Manual worktree with recorded task ownership and cleanup authority:** Move command execution to a verified surviving checkout outside the target, then remove only the recorded task worktree:

```text
git worktree remove <quoted-task-workspace-path>
```

Inspect tracked, untracked, and ignored files before removal; preserve needed ignored files separately. A `.worktrees/` or `worktrees/` directory name proves neither ownership nor permission.

If removal refuses modified or untracked files, preserve them and report the exact refusal and file list. Do not add `--force` to bypass it. Resolve the files under existing authority, or obtain a concrete choice to preserve, commit, move, or discard them. Any commit or move must itself be authorized and must not overwrite another task's files. Confirm successful removal before Step 7; requesting removal is not proof it succeeded.

**Unknown provenance or cleanup authority:** Leave the workspace and branch in place and report that they were preserved. Detached HEAD does not decide ownership or authority.

## Step 7: Cleanup Branch

Proceed only after confirmed workspace cleanup, or after establishing there was no linked task worktree to remove. If cleanup was refused, failed, remains uncertain, or was not authorized, preserve the branch too.

From a surviving checkout, inspect current branch references and `git worktree list --porcelain`. Verify all of these before deleting:

- The branch is the task's intended feature branch and deletion is authorized.
- It is not the base branch or another task's branch.
- No checkout, including the current one, has it checked out.

If no feature branch exists or it is already absent, there is nothing to delete. If another worktree uses it, preserve both and report why.

After a successful local merge, use `git branch -d <feature-branch>`. After confirmed discard, `git branch -D <feature-branch>` is permitted only for the branch in that explicit scope and after the same checks. Inspect the result. A refusal does not authorize force deletion or changing another worktree.

## Quick Reference

| Choice | Integration | Worktree | Branch cleanup |
|--------|-------------|----------|----------------|
| Already authorized action | Continue within its scope and remaining checkpoints | Follow actual cleanup authority | Conditional (Step 7) |
| Merge locally | Verify base, merge, check merged result | Clean up only when authorized and confirmed | Conditional (Step 7) |
| Create PR | Authorized push and PR | Preserve for feedback | None by default |
| Keep as-is | None | Preserve | None |
| Explicit discard | Confirm concrete scope if not already approved | Native/manual procedure; preserve on refusal | Conditional (Step 7) |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Tests passed earlier" | Inspect their coverage and validity. Reuse unchanged evidence; run missing or invalidated checks. |
| "They obviously want it merged" | Use the actual integration choice already made; otherwise obtain it. |
| "Detached HEAD means I cannot publish" | Check real permissions and tools. Detached state proves neither capability nor authorization. |
| "The PR is up, so the worktree is clutter" | Preserve it for feedback unless cleanup is separately authorized. |
| "This other worktree looks stale" | Recorded task ownership and cleanup authority are required. Directory names prove neither. |
| "Native archive refused; Git can remove it" | Preserve work and report the refusal. Do not bypass native lifecycle controls. |
| "Cleanup was requested, so I can delete the branch" | Confirm cleanup outcome, exact branch, and every checkout before branch deletion. |
| "The merged-result failure is probably flaky" | Investigate the observed failure. Preserve branch and worktree while dependent completion is unresolved. |
| "The push was rejected; force-push will fix it" | Investigate. Force-push requires explicit current authority and applicable repository safeguards. |
