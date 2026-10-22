# Review the actual candidate

Resolve the verified task base from the assignment or ledger. Run Git commands
in the task checkout and resolve helper paths from the installed skill directory.
Inspect status before choosing a package route:

- **Committed changes only, with a nonempty BASE..HEAD range:** use the
  PowerShell `review-package.ps1` helper on Windows or `bash review-package`
  elsewhere, with the verified plan, base and head. Pass its output path.
- **Uncommitted or new files, including BASE == HEAD:** assemble a review
  file directly. Include `git diff --no-ext-diff --no-textconv BASE --`, the
  intended new files from `git ls-files --others --exclude-standard`, their
  full contents, and exact file hashes. Include applicable verification logs
  and describe any unrelated changes excluded from the task. Do not call the
  commit-only helper for an empty range; it correctly rejects that input.

Mixed committed and uncommitted work uses the second route: the diff against
BASE covers tracked changes across both. Preserve untracked files in the review
package without staging or committing merely for review. Identify the reviewed
snapshot and recheck hashes if relevant files change while review is running.
The base revision is provenance, not the uncommitted candidate's identity.

For a fix review, use the saved prior candidate diff/files/hashes as the starting
snapshot when it was uncommitted. Comparing HEAD to itself cannot show that fix.
