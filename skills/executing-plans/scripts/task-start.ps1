#requires -Version 7.0
# Usage: task-start.ps1 PLAN_FILE TASK_NUMBER
# Prints the brief path and the full BASE commit for the task's review range.
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
if ($args.Count -ne 2) {
    [Console]::Error.WriteLine('usage: task-start.ps1 PLAN_FILE TASK_NUMBER')
    exit 2
}
try {
    $sdd = Join-Path $PSScriptRoot '../../subagent-driven-development/scripts'
    $result = & "$sdd/task-brief.ps1" $args[0] $args[1]
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if ($result -notmatch '^wrote (.*): [0-9]+ lines$') { throw "task-brief did not report a path: $result" }
    $brief = $Matches[1]
    $base = & git rev-parse --verify HEAD
    if ($LASTEXITCODE -ne 0) { throw 'could not resolve HEAD for task BASE' }
    Write-Output "brief: $brief"
    Write-Output "base: $base"
    exit 0
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 2
}
