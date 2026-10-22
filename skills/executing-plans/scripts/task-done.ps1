#requires -Version 7.0
# Usage: task-done.ps1 PLAN_FILE TASK_NUMBER BASE -- TEST_COMMAND [ARGS...]
#    or: task-done.ps1 PLAN_FILE TASK_NUMBER BASE --evidence LOG_FILE HEAD EXIT_CODE COMMAND_LABEL
# Run an executable or .ps1 entry point, capture both output streams, print the
# log tail, and record completion only on exit 0. Return the test's exit code.
# Arguments are passed directly, never parsed as a shell command string.
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
if ($args.Count -lt 5 -or [string] $args[1] -notmatch '^[1-9][0-9]*$' -or
    ($args[3] -ne '--' -and $args[3] -ne '--evidence') -or
    ($args[3] -eq '--evidence' -and ($args.Count -ne 8 -or [string] $args[6] -notmatch '^(0|[1-9][0-9]{0,2})$' -or [int] $args[6] -gt 255 -or [string]::IsNullOrWhiteSpace([string] $args[7])))) {
    [Console]::Error.WriteLine('usage: task-done.ps1 PLAN_FILE TASK_NUMBER BASE -- TEST_COMMAND [ARGS...] | --evidence LOG_FILE HEAD EXIT_CODE COMMAND_LABEL (positive task number)')
    exit 2
}
$plan = [string] $args[0]
$number = [string] $args[1]
$base = [string] $args[2]
$useEvidence = $args[3] -eq '--evidence'
$testCommand = [string] $args[4]
$testArguments = @()
if ($args.Count -gt 5) { $testArguments = @($args[5..($args.Count - 1)]) }

try {
    $baseCommit = & git rev-parse --verify --quiet --end-of-options "$base^{commit}"
    if ($LASTEXITCODE -ne 0) { throw "bad BASE: $base" }
    $headCommit = & git rev-parse --verify --quiet --end-of-options 'HEAD^{commit}'
    if ($LASTEXITCODE -ne 0) { throw 'could not resolve current HEAD' }
    & git merge-base --is-ancestor $baseCommit $headCommit
    if ($LASTEXITCODE -ne 0) {
        [Console]::Error.WriteLine("HEAD is not a descendant of BASE: $base..$headCommit")
        exit 3
    }
    if ($useEvidence) {
        $evidenceHead = & git rev-parse --verify --quiet --end-of-options "$($args[5])^{commit}"
        if ($LASTEXITCODE -ne 0) { throw "bad evidence HEAD: $($args[5])" }
        if ($evidenceHead -ne $headCommit) {
            [Console]::Error.WriteLine('recorded evidence HEAD differs from current HEAD')
            exit 3
        }
        if (!(Test-Path -LiteralPath $args[4] -PathType Leaf)) { throw "no such evidence log: $($args[4])" }
        $logText = [IO.File]::ReadAllText((Resolve-Path -LiteralPath $args[4]).ProviderPath)
        $code = [int] $args[6]
        $displayCommand = "recorded evidence '$(([string] $args[7]).Replace("'", "''"))' from '$(([string] $args[4]).Replace("'", "''"))'"
    }
    $sdd = Join-Path $PSScriptRoot '../../subagent-driven-development/scripts'
    # task-brief validates the task before creating any artifact. Reuse its
    # path so execution and subagent helpers cannot select different workspaces.
    $briefResult = & "$sdd/task-brief.ps1" $plan $number
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if ($briefResult -notmatch '^wrote (.*): [0-9]+ lines$') { throw "task-brief did not report a path: $briefResult" }
    $directory = [IO.Path]::GetDirectoryName($Matches[1])
    $log = Join-Path $directory "task-$number-tests.log"
    $ledger = Join-Path $directory 'progress.md'

    if (!$useEvidence) {
      try {
        if (Test-Path -LiteralPath $testCommand -PathType Leaf) {
            $executable = (Resolve-Path -LiteralPath $testCommand).ProviderPath
        } else {
            if ([Management.Automation.WildcardPattern]::ContainsWildcardCharacters($testCommand)) { throw 'command name must be literal' }
            $executable = (Get-Command -Name $testCommand -CommandType Application, ExternalScript -ErrorAction Stop | Select-Object -First 1).Source
        }
      } catch {
        [Console]::Error.WriteLine("task-done: test command not found: $testCommand")
        exit 127
      }
        $extension = [IO.Path]::GetExtension($executable)
        if ($IsWindows -and $extension -notin '.exe', '.com', '.ps1') {
            [Console]::Error.WriteLine('task-done: use an .exe/.com executable or .ps1 entry point; invoke other scripts through their interpreter. Windows .cmd/.bat wrappers are not supported.')
            exit 126
        }
        $start = [Diagnostics.ProcessStartInfo]::new()
        $start.UseShellExecute = $false
        # Inherit the caller's console encoding. CREATE_NO_WINDOW makes pwsh on
        # Windows fall back to the OEM code page even when the caller uses UTF-8.
        $start.WorkingDirectory = (Get-Location).ProviderPath
        $start.RedirectStandardOutput = $true
        $start.RedirectStandardError = $true
        if ($extension -eq '.ps1') {
            $start.FileName = Join-Path $PSHOME $(if ($IsWindows) { 'pwsh.exe' } else { 'pwsh' })
            foreach ($value in @('-NoProfile', '-NonInteractive', '-File', $executable)) { $start.ArgumentList.Add($value) }
        } else { $start.FileName = $executable }
        foreach ($value in $testArguments) { $start.ArgumentList.Add([string] $value) }
        try { $process = [Diagnostics.Process]::Start($start) }
        catch {
            [Console]::Error.WriteLine("task-done: could not start test command: $($_.Exception.Message)")
            exit 126
        }
        try {
            # Drain both pipes concurrently so verbose tools cannot deadlock. The
            # log contains stdout then stderr; cross-stream chronology is not kept.
            $stdout = $process.StandardOutput.ReadToEndAsync()
            $stderr = $process.StandardError.ReadToEndAsync()
            $process.WaitForExit()
            $code = $process.ExitCode
            $logText = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
        } finally { $process.Dispose() }
        $displayCommand = (@($testCommand) + $testArguments | ForEach-Object {
            $value = [string] $_
            if ($value -cmatch '^[a-zA-Z0-9_./:\\=-]+$') { $value }
            else { "'$($value.Replace("'", "''"))'" }
        }) -join ' '
    }
    $displayCommand = $displayCommand.Replace("`r", '\r').Replace("`n", '\n')
    [IO.File]::WriteAllText($log, $logText, [Text.UTF8Encoding]::new($false))
    Get-Content -LiteralPath $log -Tail 5
    if ($code -ne 0) {
        [Console]::Error.WriteLine("task-done: test command exited $code; Task $number NOT recorded (full output: $log)")
        exit $code
    }
    $last = @($logText -split '\r?\n' | Where-Object { $_ -match '\S' } | Select-Object -Last 1)
    if ($last.Count -eq 0) { $last = @('(no output)') }
    $currentHead = & git rev-parse --verify --quiet --end-of-options 'HEAD^{commit}'
    if ($LASTEXITCODE -ne 0) { throw 'could not resolve HEAD after verification' }
    if ($currentHead -ne $headCommit) {
        [Console]::Error.WriteLine('HEAD changed during verification; completion NOT recorded')
        exit 3
    }
    $baseShort = & git rev-parse --short=7 $baseCommit
    if ($LASTEXITCODE -ne 0) { throw 'could not resolve BASE for the ledger' }
    $headShort = & git rev-parse --short=7 $headCommit
    if ($LASTEXITCODE -ne 0) { throw 'could not resolve HEAD for the ledger' }
    if (![IO.File]::Exists($ledger)) {
        [IO.File]::WriteAllText($ledger, "# SDD ledger — plan: $plan`n", [Text.UTF8Encoding]::new($false))
    }
    $line = "Task ${number}: complete (commits $baseShort..$headShort, tests: $displayCommand → $($last[0]))"
    [IO.File]::AppendAllText($ledger, "$line`n", [Text.UTF8Encoding]::new($false))
    Write-Output "ledger: $line"
    exit 0
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 2
}
