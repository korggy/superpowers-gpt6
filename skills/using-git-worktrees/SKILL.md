---
name: using-git-worktrees
description: Create or inspect an isolated Git workspace when requested or needed for concurrent work.
---

# Using Git Worktrees

Follow the [shared policy](../using-superpowers/references/workflow-policy.md), reading it once if needed.

Respect the named checkout, branch, and established isolation preference. Inspect `git rev-parse --show-toplevel`, `git rev-parse --git-common-dir`, `git branch --show-current`, and `git worktree list --porcelain`. Account for submodules and existing isolation before creating anything.

When isolation is authorized, prefer the host's native facility or use Git. Ask if a new worktree would change the user's selected workspace or requires an unresolved preference; routine work can otherwise stay in place. A failed isolation operation does not authorize silently moving work elsewhere.

Choose an authorized location and branch. Confirm project-local worktree directories are ignored, without automatically committing an ignore change. Do not overwrite existing branches or directories.

Record creation provenance: absolute path, repository, branch, starting revision, creator/task identity, and purpose. A path under `.worktrees/` or `worktrees/` does not prove ownership. Preserve externally created workspaces unless cleanup is explicitly authorized.

Use documented project setup when dependencies are needed. Do not automatically install packages or run a full suite merely because a manifest exists. Establish an appropriate baseline and classify unrelated failures.

Consult the [Codex adapter](../using-superpowers/references/codex-tools.md) for Windows and host details. Report the resulting workspace and relevant evidence.
