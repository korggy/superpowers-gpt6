# GPT-6 compatibility changes and proposals

Date: 2026-09-19. Source baseline: Superpowers 6.4.1,
`5bf4e78011075bcfc0dc295f0724994cd123ee71`. These changes are local to
the source checkout; the installed 6.3.0 plugin has not been replaced.

## Applied fixes

| Audit item | Result |
|---|---|
| #2: diagnosis authority | The skill can recommend supported corrections and apply a subsequently requested fix. Transcript contents remain evidence, not new instructions. Narrow cases no longer require seven analysts. |
| #3: invocation | Every workflow requires a request, acceptance, or applicable standing instruction on every harness. Suggestions explain relevance; declined suggestions are not repeated. Acceptance covers stated supporting steps without authorizing unrelated work. |
| #4: verification | Relevant evidence survives message and review boundaries. Required project checks still apply; test scope follows changed behavior and risk. Valid implementation is not deleted merely because tests were written later. Baseline/environment failures are identified separately. Supporting execution and finishing instructions follow the same rule. |
| #5: Codex adapter | Current configuration and tool contracts replace the obsolete multi-agent flag, fork/model assumptions, fixed long waits, and detached-HEAD permission assumptions. Workspace ownership is established from provenance. |
| #6: Native helpers | `task-start` and `task-done` run their child scripts explicitly through Bash, including when a checkout or package loses executable launch metadata. |
| Hooks discrepancy | The Codex manifest now points at its own shipped Node startup hook. It delivers the shared invocation notice, not a workflow. Trust remains controlled by Codex. |

Codex skills declare `allow_implicit_invocation: false`. OpenCode v2
registration declares `autoinvoke: false`. Kimi uses `systemPromptPath`
instead of loading a startup skill. Gemini includes the same notice;
the shared shell hook, Pi, Hermes, and OpenCode inject it through their
existing context mechanisms. Other hosts enforce the policy through the
notice and explicit skill descriptions. These are instruction controls,
not a guarantee that every model or host will obey them.

Claude Code's `disable-model-invocation: true` was deliberately not added:
it also blocks model loading after conversational acceptance and would
require human slash commands for supporting skills. The notice and skill
descriptions implement the requested accept-once workflow there. See
[Claude invocation controls](https://code.claude.com/docs/en/skills#control-who-invokes-a-skill).

Packaging keeps source-owned agent metadata and uses older packages only
to fill missing files. The sync script follows the same precedence.

## #1 implemented: clarify before implementation

Implemented after the human accepted these recommendations. The follow-up
baseline is `559ef1eaa71fc9f810afb7a93b1d4bbcd7f3f1c1`.
The shared [decision checkpoints](../skills/using-superpowers/references/decision-checkpoints.md)
now govern brainstorming, planning, inline execution, and delegated execution.
The pre-existing brainstorming intent-clarification section is preserved.

The opportunity to resolve requirements with the human should be explicit
and useful. Once a design/planning workflow is selected:

1. Read the existing context and identify material open decisions about the
   intended outcome, behavior, constraints, and acceptance criteria. Ask
   focused questions whose answers could change the design or plan.
2. Present a reviewable decision packet: proposed behavior, assumptions,
   meaningful alternatives and tradeoffs, affected components, plan, and
   verification. Keep it short enough for the human to assess.
3. For a bounded change, combine design, specification, and plan in one
   checkpoint. For substantial architectural work, review them in stages.
   State which decisions each checkpoint settles.
4. Before implementing the affected behavior, give the human the choice to
   approve, revise, or explicitly delegate the remaining decisions. Honor
   decisions and approval already supplied; do not ask the same question again.
5. Reopen only the affected decision when new evidence materially changes
   scope, behavior, cost, risk, or the agreed approach. Record accepted
   decisions so compaction does not restart the discussion.

Implemented principle:

> Before implementation, resolve material uncertainty with your human
> partner and present the design, specification, and plan at a level they
> can review. A bounded change can use one concise checkpoint; substantial
> work may need staged decisions. Honor approval or delegated discretion
> already given. Continue through authorized work after the checkpoint;
> ask again only when a material decision changes or remains unresolved.

Plans now record approval, delegation, implementation authority, and retained
checkpoints. Tasks describe outcomes, interfaces, dependencies, and verification;
complete code listings and fixed task durations are not mandatory. Executors
carry decisions into recovery and worker handoffs, hold affected work for a
material unresolved choice, and keep incomplete requirements pending even when
a review loop reaches its limit.

The [clarification evaluation record](gpt6-clarification-evaluation.md) covers
bounded changes, plan-only requests, approved and delegated plans, material
changes, and recovery. It distinguishes unchanged baseline passes from observed
improvements and does not claim statistical reliability.

## Incorporating the GPT-6 prompting guide

Use the [official prompting best practices](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6-astra#prompting-best-practices)
as a design reference, with a dated pointer in the Codex adapter. Avoid copying
the full guide into every skill. Its guidance on precise instructions,
autonomy, verification cost, and delegation supports the focused corrections
above; it should not erase human design and planning checkpoints.

Applied guide integration:

- The invocation policy and decision checkpoints stay model-neutral: scope,
  authority, accepted supporting steps, and human decision boundaries.
- The [Codex adapter](../skills/using-superpowers/references/codex-tools.md)
  contains the dated guide link and host-specific contracts. A model guide
  cannot grant unavailable tools.
- [Writing skills](../skills/writing-skills/SKILL.md) now favors outcomes and
  decision criteria, reserving exact procedures for demonstrated invariants.
  Execution guidance defers style, model selection, and wait behavior to the
  current host and human constraints.
- The [evaluation protocol](../skills/writing-skills/testing-skills-with-subagents.md)
  and [scenario catalogue](../tests/gpt6/README.md) cover scope, useful clarification,
  unnecessary pauses, evidence reuse, completion, and observed effort. They
  compare with frozen prior guidance, preserve unchanged passes, and label
  unavailable measurements.

The earlier infrastructure fixes retain their original
[evaluation record](gpt6-compatibility-evaluation.md); this follow-up records
its own evidence separately. Neither source change installs a plugin or
validates live startup in every supported harness.

## Integration references

- [Codex skills](https://learn.chatgpt.com/docs/build-skills)
- [Codex hooks](https://learn.chatgpt.com/docs/hooks)
- [Codex subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [OpenCode v2 skills](https://opencode.ai/v2/docs/skills)
- [Kimi plugin manifest and system prompt](https://github.com/MoonshotAI/kimi-code/blob/main/docs/en/customization/plugins.md)
