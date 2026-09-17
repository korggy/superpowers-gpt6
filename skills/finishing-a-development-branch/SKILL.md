---
name: finishing-a-development-branch
description: Integrate completed work or clean up its workspace when merge, publication, or cleanup is requested.
---

# Finishing a Development Branch

Follow the [shared policy](../using-superpowers/references/workflow-policy.md), reading it once if needed.

Confirm the requested action, repository, source and target branches, and working-tree state. Reuse valid evidence; run required or affected checks when the integrated result differs.

Honor an integration choice already made. For implementation-only requests, report the result and leave work in place. If integration is requested but destination or action is unknown, ask about that missing decision.

For local integration, follow the project's merge policy and verified target. Do not automatically pull remote changes or invent a base branch. Preserve unrelated work and verify the combined result before cleanup. Failed checks leave the work recoverable while investigated.

Push and PR creation require authorization covering those actions. Use the configured forge's tools and template. Actual permissions determine what detached HEAD allows.

Before removing a worktree or branch, establish recorded task ownership or explicit user authorization, verify the resolved target, inspect uncommitted/untracked work, and confirm needed commits and evidence are retained. Directory names do not establish provenance. Preserve user-owned and host-managed workspaces unless cleanup is requested.

Use non-force removal. If refused, inspect the reason and preserve unique work; do not force or broaden cleanup to siblings. For an explicit discard request, ensure the exact work and consequences are understood. Use one shell end-to-end for Windows filesystem operations.

Report the actual state: locally implemented, locally integrated, pushed, or PR created. Local checks do not prove deployment.
