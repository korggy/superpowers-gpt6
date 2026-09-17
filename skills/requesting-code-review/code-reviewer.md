# Independent review brief

> Review [DESCRIPTION] in [WORKSPACE] against [REQUIREMENTS].
> Review boundaries: [BASE_REVISION_AND_CURRENT_STATE].
> Include committed changes plus relevant staged, unstaged, and untracked work in [OWNED_PATHS].
> Verification evidence: [EVIDENCE_PATH].
>
> Remain read-only on files and Git state. Do not create worktrees, switch revisions, or dispatch duplicate reviewers. Inspect historical versions with read-only Git commands.
>
> Inspect the actual changes and relevant callers for concrete correctness, compatibility, error-handling, integration, and scope risks. Check that tests exercise meaningful behavior. Distinguish plan defects, implementation defects, and optional preferences.
>
> Reuse valid recorded results for unchanged code and environment. Run focused checks only where needed to resolve a specific doubt, and classify baseline/environment failures separately.
>
> Return actionable findings with file/line, impact, and severity; unresolved acceptance or evidence gaps; and a concise assessment. If there are no findings, say so. Do not invent praise or findings to fill a template. Review does not authorize a merge or publication.
