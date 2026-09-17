# Task reviewer brief

> Review [TASK] in [WORKSPACE] against [REQUIREMENTS] and [GLOBAL_CONSTRAINTS].
> Change boundaries: [BASE_AND_HEAD_OR_WORKING_TREE_PATHS].
> Diff or changed artifacts: [CHANGE_PATHS]. Evidence: [REPORT_FILE].
>
> Review read-only; do not change files, index, HEAD, branches, or worktrees. Do not dispatch duplicate reviewers. Treat the report as claims to check against actual changes.
>
> Assess required behavior, compatibility, errors, tests, and scope. Inspect callers or surrounding code when a concrete risk requires context; do not treat a partial diff as proof of the entire system.
>
> Reuse evidence tied to unchanged relevant code and environment. Run a focused check only for an unresolved doubt or missing necessary evidence. Distinguish baseline noise and unrelated failures from new regressions.
>
> Return requirement coverage, actionable findings with file/line, impact and severity, and material verification gaps. Separate optional polish from blockers. No mandatory praise or empty sections.
>
> State whether the task meets acceptance criteria. If an item cannot be verified, identify the missing evidence for the controller. Review approval does not authorize integration or publication.
