# Codex Tool Notes

Use the current host's tools and schemas. A reference describes a workflow;
it does not grant a tool or override its permissions.

## Workflow Discovery and Startup

All skills carry `policy.allow_implicit_invocation: false` in
`agents/openai.yaml`. Explicit requests and accepted workflow suggestions
are the entry points. The Codex manifest registers a SessionStart hook that
loads only the invocation policy, so the agent can suggest relevant workflows
without loading or executing them. Codex must trust the hook before it runs;
do not change trust or user configuration automatically. Node.js is required
for this small hook. Skill invocation remains available if hooks are disabled.

## Subagents

Check the tools exposed in this session before selecting an execution mode.
Current Codex configuration uses `[agents]` with `enabled = true` by default.
If tools are absent, explain the limitation and use a suitable inline path;
do not add a legacy feature flag or change machine settings unprompted.

For hosts exposing the collaboration V2 tools:

- Use `spawn_agent` with `fork_turns: "none"` for a self-contained task.
  Supply the task, boundaries, evidence, and required context explicitly.
- Full-history forks (`fork_turns: "all"` or omitted) inherit the parent
  model and reasoning effort on this host and do not accept overrides.
  Use an isolated or supported limited-history fork when a selected workflow
  calls for an explicit model or effort.
- Use only models and effort combinations in the current tool allowlist.
  If selecting a model explicitly, also select its supported effort when
  required by the workflow. Do not infer model availability from old examples.
- Resume a worker with `followup_task` when available; `send_message` alone
  may not start a new turn. Follow the actual lifecycle contract instead of
  assuming a `close_agent` tool exists.
- Role files and `agent_type` are host-dependent. Pass them only if the
  current spawn schema supports them.
- Dispatch only independent, bounded work that benefits from delegation and
  is allowed by the user's selected workflow and host instructions.

## Waiting

Keep doing independent work while workers run. When idle, use the host's
event-driven wait rather than repeated status polling. Choose a bounded
timeout compatible with that host's responsiveness and progress-update rules.
Do not impose a universal five-minute minimum. Reconcile completed or failed
workers when notified, and continue until the requested work is finished.

## Workspaces and Finishing

Inspect `git rev-parse --git-dir`, `--git-common-dir`,
`--show-superproject-working-tree`, and `git branch --show-current`.
Distinguish a linked worktree from a submodule before deciding it is isolated.

Detached HEAD describes Git state, not sandbox permissions. Use native
workspace tools when available and when isolation is authorized. Preserve
the named checkout and branch. Follow real tool errors and permissions
instead of assuming branch creation or network operations are impossible.

Carry out authorized integration using current tools. If a necessary action
is blocked, preserve the work, report the exact limitation, and describe the
available app handoff. A skill does not authorize an otherwise unrequested
commit, push, PR, or cleanup.

Sources checked 2026-09-19:
- [Codex subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [Codex hooks](https://learn.chatgpt.com/docs/hooks)
- The active Codex collaboration tool schemas take precedence over this file.

## GPT-6 prompting reference

Checked 2026-09-19: [OpenAI GPT-6 prompting best practices](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6-astra#prompting-best-practices).
Use this as a dated design reference; actual host instructions and tool schemas
remain authoritative. Keep responses appropriate to the human and host, persist
within authorized scope, and scale delegation and verification to the work.

The model-neutral [invocation policy](invocation-policy.md) and
[decision checkpoints](decision-checkpoints.md) define selection and human
review boundaries. [Writing skills](../../writing-skills/SKILL.md) defines
outcome-oriented authoring and comparative evaluation. Test changes against
scope, useful clarification, repeated questions/checks, and observed effort.
Do not copy the whole model guide into each skill or treat it as permission to
skip a retained checkpoint, change models, or enable unavailable tools.
