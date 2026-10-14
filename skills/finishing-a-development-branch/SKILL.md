---
name: finishing-a-development-branch
description: Use when your human partner requests the branch-finishing workflow, or an accepted implementation workflow reaches its integration decision.
---

# Finishing a Development Branch

## Overview

**Core principle:** Verify tests → Detect environment → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## Step 1: Verify Tests

Inspect results for the affected tests and required project checks on the
tree to integrate. Reuse recorded results when the covered code, inputs,
and environment are unchanged. Run missing or invalidated checks; use a
full suite when required or justified by integration risk.

**If required checks fail or remain unverified**, report them before
offering integration. Do not claim the work is ready:

```
Tests failing (<N> failures). Must fix before completing:

[Show failures]
```

**If tests pass:** continue to Step 2.

## Step 2: Detect Environment

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
# Capture now, while still inside the workspace — Step 5 changes directory
# before cleanup (Step 6) needs this value
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

These commands identify Git state, not permissions or workspace ownership:

| State | Integration preparation | Cleanup |
|-------|-------------------------|---------|
| Normal repo | Use the current branch, or create one if detached and the chosen action needs it | No linked worktree to clean up |
| Linked worktree, named branch | Use that branch | Provenance-based (see Step 6) |
| Linked worktree, detached HEAD | Create a branch when needed for the chosen action, if permitted | Provenance-based (see Step 6) |

Apply the submodule guard in `using-git-worktrees` Step 0 before treating
different Git directories as a linked worktree. Use host records or the
session's creation record for provenance, and current tool contracts,
permissions, and observed results for capabilities. Detached HEAD alone
proves neither a host-managed workspace nor a sandbox restriction.

## Step 3: Determine Base Branch

Use the base branch established by the plan, conversation, repository
guidance, or verified Git history. If it is unresolved, ask when a merge or
PR is selected, before that action. Keeping the work as-is does not need a
base-branch decision. Merging into the wrong base is expensive to undo.

## Step 4: Present Options

If the human has already explicitly chosen integration or publication,
carry out that choice within its authorized scope; do not ask them to
select it again. Honor repository approval requirements and host permissions.
Otherwise, present these three actions for either named or detached HEAD:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the work as-is (I'll handle it later)

Which option?
```

For detached HEAD, explain that this workflow prepares a named branch for
merge or publication; use the current native branch control or Git when
permitted. If an action
is unavailable, state the actual limitation rather than offering it as
executable. Keeping as-is preserves the current checkout, branch or detached.

Keep the menu concise. Discarding the work happens only in response to your
human partner explicitly asking for it (see "If your human partner asks to
discard the work" below). If no choice is already authorized, wait for
their answer; the integration decision is theirs.

## Step 5: Execute Choice

For a selected merge or PR, first ensure the intended changes are on an
appropriate named branch and any needed commits are within the authorized
scope. From detached HEAD, create that branch through the available native
control or a permitted `git switch -c <feature-branch>`. Do not stage or
commit unrelated work. If permissions block a required operation, preserve
the workspace and report that specific limitation and available handoff.

### Option 1: Merge Locally

```bash
# Get main repo root for CWD safety
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# Merge first — verify success before removing anything
git checkout <base-branch>
git pull
git merge <feature-branch>

# Verify tests on merged result
<test command>
```

If tests fail on the merged result: stop, leave the worktree and branch in
place, and investigate — nothing has been pushed, so the merge is local
and recoverable.

Once the merged result is green, run workspace cleanup (Step 6), then
use its confirmed outcome to decide branch cleanup (Step 7).

### Option 2: Push and Create PR

```bash
git push -u origin <feature-branch>
```

Then create the pull/merge request against <base-branch> with the forge's
tooling — its CLI if one is available, or the creation URL most forges
print when you push — following the repo's PR template and conventions if
present, and report the URL to your human partner.

Keep the worktree — your human partner iterates on PR feedback there.

### Option 3: Keep As-Is

Report the actual state: "Keeping branch <name>" or "Keeping detached HEAD
at <commit>", followed by "Workspace preserved at <path>."

### If your human partner asks to discard the work

This path exists only as a response to an explicit request to throw the
work away. Confirm first:

```
This will discard the active work:
- Branch <name>
- Branch-only commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Explain any native recovery snapshot that will remain; discarding the
active checkout does not promise permanent erasure of saved history.

Wait for that exact confirmation. When it arrives:

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

Then run workspace cleanup (Step 6), followed by the conditional branch
cleanup in Step 7. A confirmed discard does not override a native tool's
refusal or authorize deleting a branch used by another worktree.

## Step 6: Cleanup Workspace

**Runs for Option 1 and confirmed discards.** Options 2 and 3 always
preserve the worktree. Both callers have already changed directory to the
main repo root — worktree removal must run from outside the worktree —
and use the `GIT_DIR`/`GIT_COMMON`/`WORKTREE_PATH` values captured in
Step 2, from before that directory change.

**If `GIT_DIR == GIT_COMMON`:** Normal repo, no linked worktree to clean
up. Record that outcome and continue to Step 7.

**If host-managed:** let the host manage the worktree through its native
cleanup tool when cleanup is authorized. For Codex, follow the
[native archive procedure](../using-superpowers/references/codex-tools.md#native-worktree-cleanup):
resolve the attached worktree's identity, preserve needed ignored files,
and inspect the archive result. Do not remove a managed checkout with
`git worktree remove`, filesystem deletion, or a manual fallback after a
native refusal. If the tool is unavailable, refuses, or leaves the
outcome uncertain, preserve the workspace and branch and report the
limitation. Continue to Step 7 only after confirmed cleanup.

**If the session's creation record confirms this is the manual worktree
created for this task, and cleanup is authorized:** remove only that
worktree. A `.worktrees/` or `worktrees/` directory name does not prove
ownership or authorize removal:

```bash
git worktree remove "$WORKTREE_PATH"
```

**If removal is refused** (`contains modified or untracked files`): the
worktree holds files that exist nowhere else — uncommitted plans, notes,
or scratch work. Never `--force` on your own initiative. Show your human
partner what is at stake and ask:

```bash
git -C "$WORKTREE_PATH" status --porcelain -uall
```

```
Worktree removal refused — these files were never committed:

<file list>

1. Commit them to <branch> before cleanup
2. Move them into <main repo root>
3. Delete them (unrecoverable)

Which?
```

Carry out the choice, then remove the worktree. Confirm removal before
continuing to Step 7; a requested removal is not proof that it succeeded.

**If provenance or cleanup authority is unknown:** leave the workspace
and branch in place and report that they were preserved. Detached HEAD
does not decide either case.

## Step 7: Cleanup Branch

Runs only after confirmed workspace cleanup, or when Step 6 established
that there was no linked worktree to remove. If cleanup preserved the
workspace, failed, or is uncertain, preserve the branch too.

Check the current branch references and `git worktree list --porcelain`
from a surviving checkout. Delete only the task's identified feature
branch when that deletion is authorized and no worktree has it checked
out. If another worktree uses it, leave both in place and report why.
If the branch is already absent or no feature branch was created, there
is no branch deletion to perform. Never substitute the base branch.

- After a successful local merge, use `git branch -d <feature-branch>`.
- After the explicit discard confirmation, use
  `git branch -D <feature-branch>` only for the branch named in that
  confirmation and after the same checks above.

A refusal is a new result to investigate, not a reason to force deletion
or alter another worktree. Report the actual workspace and branch state.

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------|------|---------------|----------------|
| 1. Merge locally | yes | - | if cleanup cannot complete or is not authorized | conditional (Step 7) |
| 2. Create PR | - | yes | yes | - |
| 3. Keep as-is | - | - | yes | - |
| Discard (explicit request only) | - | - | if cleanup cannot complete | conditional (Step 7) |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Tests passed earlier this session" | Inspect that evidence against the current tree and environment. Reuse valid results; run missing or invalidated checks. |
| "They obviously want it merged" | Follow an explicit integration choice already made; otherwise present the menu and wait. |
| "They seem done with this feature — I'll offer to discard it" | The menu is complete as written. Discard happens only when your human partner asks for it in so many words. |
| "'Yeah, get rid of it' counts as confirmation" | Only the typed word `discard` authorizes deletion. |
| "The PR is up, so the worktree is clutter now" | PR feedback gets fixed in that worktree. It stays until the work lands. |
| "This other worktree looks stale — I'll clean it too" | Clean up only the task's worktree with established provenance and authorization. A directory name or detached HEAD does not establish either. |
| "Removal refused — `--force` is just finishing the cleanup" | The refusal means files exist only in that worktree. `--force` destroys them permanently. Show your human partner and ask. |
| "The merged-result failure is probably flaky" | A failing merged result stops everything. Branch and worktree stay put while you investigate. |
| "The base branch is obviously main" | Confirm the fork point or ask. Merging into the wrong base is expensive to undo. |
| "The push was rejected — force-push will fix it" | A rejected push means the remote moved. Investigate; force-push only on your human partner's explicit request. |
