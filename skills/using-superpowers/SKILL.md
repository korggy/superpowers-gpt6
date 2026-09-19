---
name: using-superpowers
description: Suggest when the human wants help choosing a development workflow. Invoke only when requested or accepted.
---

# Choosing a Superpowers Workflow

Follow the [invocation policy](references/invocation-policy.md). Superpowers
is opt-in; loading a startup notice does not start a workflow.

## The Rule

Use the conversation to identify the outcome and any unresolved decisions.
Suggest one workflow that would materially help, explain its purpose and
checkpoints briefly, and wait for acceptance before invoking it. If the
human already requested it, proceed without asking again.

- Clarify a design: brainstorming.
- Write an implementation plan: writing-plans.
- Execute an accepted plan: executing-plans or subagent-driven-development,
  preserving the human's chosen execution method.
- Investigate a failure: systematic-debugging.
- Add behavioral regression protection: test-driven-development.
- Review work or feedback: requesting-code-review or receiving-code-review.
- Coordinate independent investigations: dispatching-parallel-agents.
- Set up requested isolation: using-git-worktrees.
- Investigate a problematic session: diagnosing-superpowers.
- Develop or evaluate skills: writing-skills.

Load only the selected skill and the supporting references needed for it.
Use verification-before-completion when it is part of the accepted workflow
or explicitly requested. Ordinary evidence-based reporting does not require
a separate workflow offer.

For integration and cleanup, follow the repository's existing guidance and
the user's instructions.

## Platform Adaptation

Read the relevant reference when the chosen workflow needs harness-specific
tools. Actual tool schemas and host instructions take precedence.

- Claude Code: `references/claude-code-tools.md`
- Codex: `references/codex-tools.md`
- Pi: `references/pi-tools.md`
- Antigravity: `references/antigravity-tools.md`
- Hermes: `references/hermes-tools.md`
- Muse: `references/muse-tools.md`

## Human decisions

Within an accepted design, planning, or execution workflow, use the shared
[decision checkpoints](references/decision-checkpoints.md). Give the human a
reviewable opportunity to shape unresolved material choices. Honor approval
or delegated discretion already supplied and carry decisions into handoffs.
