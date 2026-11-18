# Handling a Report That Isn't DONE

Part of superpowers-gpt6:subagent-driven-development.

**DONE_WITH_CONCERNS:** The implementer completed the work but flagged doubts. Read the concerns before proceeding. If the concerns are about correctness or scope, address them before review. If they're observations (e.g., "this file is getting large"), note them and proceed to review.

**NEEDS_CONTEXT:** The implementer needs information that wasn't provided. Provide the missing context and resume via the supported follow-up tool.

**BLOCKED:** The implementer cannot complete the task. Assess the blocker:
1. If it's a context problem, provide more context and resume via the supported follow-up tool with the same model
2. If the task needs fresh context or an authorized model override, spawn a new clean-context worker. In Codex use `fork_turns: "none"` and both supported model/effort values for an override; `followup_task` cannot change settings.
3. If the task is too large, break it into smaller pieces
4. If the plan itself is wrong, rule on the correction, ledger it, and resume via the supported follow-up tool with the ruling carried in the dispatch

**Never** ignore an escalation or force the same model to retry without changes. If the implementer said it's stuck, something needs to change.
