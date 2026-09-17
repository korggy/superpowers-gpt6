# Codex runtime adapter

Current tool descriptions and host instructions are authoritative. Model capability and host support are separate. Do not enable features, change machine configuration, or install tools merely because a skill mentions them.

## Delegation

Use collaboration tools when available and authorized. Give workers bounded objectives, acceptance criteria, owned paths, shared constraints, and necessary context. Prefer isolated context for a self-contained brief; use inherited context when it is actually needed.

In hosts exposing `fork_turns`, full-history forks may prohibit model and reasoning overrides. This desktop contract requires `fork_turns: "none"` or a supported positive count for overrides. Do not send unsupported fields such as `agent_type`; inspect the live schema.

Keep inherited model and reasoning settings unless task requirements or an explicit routing policy justify overrides. Select only supported model/effort combinations. Evaluate quality, turns, latency, and tokens; do not assume the cheapest token price wins or force every helper onto GPT-6.

Use `followup_task` to resume workers when available; messaging and resuming are not interchangeable. Do not call nonexistent lifecycle tools. Keep independent local work moving while workers run. When idle, use event-driven waits compatible with host progress-update requirements. Avoid busy polling and universal five-minute waits.

The controller owns review assignment; workers do not duplicate reviewers. Parallel reads can share a checkout. Parallel writes require disjoint ownership; Git index, commit, checkout, merge, and shared build operations must be serialized.

## Workspace and shell

Respect the user's named checkout and branch. Inspect repository root, common Git directory, branch, and worktree list using read-only Git commands. Detached HEAD alone does not establish that branch creation or push is forbidden; actual permissions decide.

Prefer authorized host-native workspace facilities. Do not create a user-visible task as a substitute for an internal worker. Preserve host-managed and user-owned worktrees. Directory names do not prove ownership.

Use the active shell's syntax. POSIX helpers require Bash; on Windows use Git Bash explicitly when available or equivalent native commands. Use one shell end-to-end for recursive deletion and verify resolved target and ownership.

The source-only package builder needs Python 3.10+ and PyYAML. Bundled SDD helpers require Bash and Git. If unavailable, write briefs directly and use native Git commands rather than blocking on a convenience helper.
