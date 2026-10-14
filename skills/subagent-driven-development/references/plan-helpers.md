# Plan helpers by shell

On Windows, prefer the native PowerShell helpers. They require PowerShell 7+
(`pwsh`) and Git; they do not require Bash. In a Bash environment, invoke the
extensionless helpers with `bash`, even when executable bits are present.

Resolve helper paths from the installed skill directory, and run them with
the intended repository as the current directory. Quote paths containing
spaces. The plan path is relative to that repository or absolute.

| Helper | PowerShell invocation (replace `./scripts` with the installed helper path) |
| --- | --- |
| Plan workspace | `pwsh -NoProfile -File ./scripts/sdd-workspace.ps1 PLAN_FILE` |
| Task brief | `pwsh -NoProfile -File ./scripts/task-brief.ps1 PLAN_FILE N` |
| Review package | `pwsh -NoProfile -File ./scripts/review-package.ps1 PLAN_FILE BASE HEAD` |
| Start task (executing-plans) | `pwsh -NoProfile -File ./scripts/task-start.ps1 PLAN_FILE N` |
| Verify task (executing-plans) | `pwsh -NoProfile -File ./scripts/task-done.ps1 PLAN_FILE N BASE -- dotnet test` |

`task-brief` and `review-package` accept an optional output path as their
last argument. The PowerShell and Bash helpers use the same workspace and
ledger format. A brief contains the named task only; the parent still supplies
the plan's global constraints and relevant prior decisions.

In `task-done`, everything after `--` is a command and its literal arguments,
not a shell expression. Use a native executable or a `.ps1` script such as
`npm.ps1`; `.cmd` and `.bat` wrappers are not supported. To use pipelines or
other shell syntax, put it in a script and invoke the intended interpreter
explicitly. The captured log contains stdout followed by stderr; it does not
preserve ordering between the two streams.

Examples from the target repository (substitute actual installed paths):

```powershell
pwsh -NoProfile -File 'C:/skills/executing-plans/scripts/task-start.ps1' 'docs/feature plan.md' 1
pwsh -NoProfile -File 'C:/skills/executing-plans/scripts/task-done.ps1' 'docs/feature plan.md' 1 BASE -- dotnet test --filter ParserTests
```

```bash
bash '/skills/executing-plans/scripts/task-start' 'docs/feature plan.md' 1
bash '/skills/executing-plans/scripts/task-done' 'docs/feature plan.md' 1 BASE -- npm test -- parser
```
