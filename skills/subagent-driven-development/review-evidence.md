# Review evidence for committed and uncommitted work

Use this reference within an accepted execution or review workflow. Review the
actual implementation state; commit permission is not a prerequisite for review.

## Establish the scope

At task start, record the current commit, status, and relevant existing working
changes. Preserve unrelated work. At review time, identify the task's paths and
changes against that starting state. Do not claim an empty commit range covers
new implementation.

## Choose the package

- **Fully committed scope:** Use `bash scripts/review-package PLAN_FILE BASE HEAD`
  from the subagent-driven-development skill directory. BASE is the task or
  branch starting commit, not automatically `HEAD~1`.
- **Uncommitted or mixed scope:** Build a review artifact from current files and
  diffs using the host's tools. Include relevant tracked changes against the
  starting commit (for example, `git diff BASE -- <paths>`), which covers staged
  and unstaged tracked content together. Inspect `git status --short` and include
  the contents of relevant new untracked files; a Git diff alone omits them.
  Describe pre-existing changes separately so they are not attributed to this
  task. Include the plan/spec paths, task boundaries, decision record, and
  verification evidence. Do not run a commit-range helper as a substitute.

For a scoped re-review, retain the exact content or diff the previous reviewer
saw and compare the corrected files with that state. HEAD may be unchanged
through several rounds, so it cannot identify these revisions by itself.

## Record coverage

Give the reviewer the artifact path and relevant current-file paths. Record the
reviewed commit range or working-tree snapshot, changed paths, and verification
scope in the ledger. Use a content snapshot or hashes where needed to distinguish
uncommitted revisions. Preserve evidence until authorized cleanup.

If the helper's completion format mentions only commits, record working-tree
evidence directly in the ledger instead. Mark complete only when requirements,
checks, and review are satisfied. Do not create a commit just to satisfy a
reporting format.
