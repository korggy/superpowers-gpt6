# Plan helpers by shell

The `superpowers-gpt6` helpers use PowerShell 7+ and Git on Windows. Bash is
optional. Resolve helper paths from the installed skill directories, run in
the intended repository, and quote paths containing spaces. Plan paths may
be relative to the current directory or absolute.

| Helper | Arguments after the helper path |
| --- | --- |
| `sdd-workspace.ps1` | `PLAN_FILE` |
| `task-brief.ps1` | `PLAN_FILE TASK_NUMBER [OUTFILE]` |
| `review-package.ps1` | `PLAN_FILE BASE HEAD [OUTFILE]` |
| `task-start.ps1` (executing-plans) | `PLAN_FILE TASK_NUMBER` |
| `task-done.ps1` (executing-plans) | `PLAN_FILE TASK_NUMBER BASE -- TEST_COMMAND [ARGS...]` |
| `task-done.ps1` with existing evidence | `PLAN_FILE TASK_NUMBER BASE --evidence LOG_FILE VERIFIED_HEAD EXIT_CODE COMMAND_LABEL` |

In an existing PowerShell 7 session, use the call operator and argument arrays
when needed. This avoids older PowerShell versions changing empty strings or
quotes while launching a second `pwsh` through native-command argument passing.
For ordinary arguments, `pwsh -NoProfile -File HELPER.ps1 ...` also works.

```powershell
$ep = 'C:/path/to/superpowers-gpt6/skills/executing-plans/scripts'
& "$ep/task-start.ps1" 'docs/feature plan.md' 1
# Use the BASE printed by task-start and the task's actual verification command.
& "$ep/task-done.ps1" 'docs/feature plan.md' 1 BASE -- dotnet test --filter ParserTests
```

In Bash, use the extensionless helpers with explicit `bash`, including after
archive extraction strips execute bits. Nested helper calls also use Bash.

```bash
ep='/path/to/superpowers-gpt6/skills/executing-plans/scripts'
bash "$ep/task-start" 'docs/feature plan.md' 1
bash "$ep/task-done" 'docs/feature plan.md' 1 BASE -- npm test -- parser
```

Both shells use `.superpowers/sdd/<plan-basename>/`, `plan-path` ownership
markers, and the same `progress.md` completion format. Same-basename plans
receive parent-directory and, if needed, numeric suffixes. Existing ignore
rules and legacy markerless workspaces are preserved. Native Windows and
Git Bash absolute-path markers are recognized across shells. A workspace is
shared by executions of the same plan in the same working tree; serialize
updates to that workspace.

A brief includes the named task only. Task IDs are positive integers, and a
missing or duplicate task fails before an output file is replaced. ATX task
headings inside backtick or tilde fences are ignored, including longer fences
and up to three leading spaces. The controller still supplies global plan
constraints and relevant prior decisions separately. Explicit output paths
require an existing parent directory.

`review-package` requires two commit revisions, a nonempty range, and a HEAD
descended from BASE. `task-done` validates the plan, task, BASE, and current
HEAD before invoking verification; BASE must be an ancestor of current HEAD.
It records completion only for exit 0 and an unchanged HEAD. The captured log
is retained on command failure, and that failure status is returned. Silent
successful commands are recorded as `(no output)`.

Everything after `--` is an executable and literal arguments. The helpers do
not evaluate a command string. On Windows the native helper supports `.exe`,
`.com`, and `.ps1` entry points; `.ps1` runs in `pwsh -NoProfile -NonInteractive
-File`. `.cmd` and `.bat` wrappers are rejected. Use a native entry point or an
appropriate interpreter for other script types. PowerShell functions, aliases,
and cmdlets are not executable entry points. A verification script must return
a nonzero exit code when checks fail; for native commands inside `.ps1`,
propagate `$LASTEXITCODE`. Pipelines or other shell expressions belong in a
script run by its intended interpreter.

The PowerShell log captures text stdout followed by text stderr, draining both
pipes concurrently. It does not preserve chronology between streams; the last
log line may come from stderr even on success. Bash redirects both streams to
one log as the command writes them. Neither helper treats stderr text alone as
a failing exit status. The console displays the last five log lines and the
ledger result. Command descriptions escape newlines to keep one ledger record
per completion.

When applicable verification already ran, use `--evidence` instead of rerunning
checks or inventing a passing command. Supply its saved text log, the commit
that was verified, its real exit code (0–255), and a meaningful command label.
The supplied revision must resolve to current HEAD; failures and mismatches
cannot record completion. The caller must establish that this evidence covers
the task and the current files, including any uncommitted changes. HEAD equality
does not prove that uncommitted files, inputs, or the environment are unchanged.
Inspect applicability and record the covered state in the evidence log or label;
an arbitrary log and a zero exit code are not verification. The helper checks
the revision and reported status, not the provenance or sufficiency of the log.
The existing log is copied into the task workspace, and its source is named in
the ledger.

```powershell
& "$ep/task-done.ps1" 'docs/feature plan.md' 1 BASE --evidence 'artifacts/parser-tests.log' VERIFIED_HEAD 0 'dotnet test --filter ParserTests'
```

Exit 2 means invalid arguments, plan/revision, or an I/O error; exit 3 means
missing/ambiguous task, invalid commit range, or changed evidence/HEAD. Native
command lookup/start failures return 127/126. Otherwise `task-done` returns the
verification command's status. These helpers record evidence; they do not
commit, push, deploy, or prove acceptance beyond the checks supplied.
