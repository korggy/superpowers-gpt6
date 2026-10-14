#requires -Version 7.0
# Usage: task-done.ps1 PLAN_FILE TASK_NUMBER BASE -- TEST_COMMAND [ARGS...]
# Run an executable or .ps1 entry point, capture both output streams, print the
# log tail, and record completion only on exit 0. Return the test's exit code.
# Arguments are passed directly, never parsed as a shell command string.
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
if ($args.Count -lt 5 -or $args[3] -ne '--' -or [string] $args[1] -notmatch '^[1-9][0-9]*$') {
    [Console]::Error.WriteLine('usage: task-done.ps1 PLAN_FILE TASK_NUMBER BASE -- TEST_COMMAND [ARGS...] (positive task number)')
    exit 2
}
$plan = [string] $args[0]
$number = [string] $args[1]
$base = [string] $args[2]
$testCommand = [string] $args[4]
$testArguments = @()
if ($args.Count -gt 5) { $testArguments = @($args[5..($args.Count - 1)]) }

try {
    $baseCommit = & git rev-parse --verify --quiet --end-of-options "$base^{commit}"
    if ($LASTEXITCODE -ne 0) { throw "bad BASE: $base" }
    $sdd = Join-Path $PSScriptRoot '../../subagent-driven-development/scripts'
    $directory = & "$sdd/sdd-workspace.ps1" $plan
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    $log = Join-Path $directory "task-$number-tests.log"
    $ledger = Join-Path $directory 'progress.md'

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
    if ($IsWindows -and $extension -in '.cmd', '.bat') {
        [Console]::Error.WriteLine('task-done: use an executable or .ps1 entry point instead of a .cmd/.bat wrapper (for example, npm.ps1).')
        exit 126
    }
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.WorkingDirectory = (Get-Location).ProviderPath
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    if ($extension -eq '.ps1') {
        $start.FileName = Join-Path $PSHOME $(if ($IsWindows) { 'pwsh.exe' } else { 'pwsh' })
        foreach ($value in @('-NoProfile', '-File', $executable)) { $start.ArgumentList.Add($value) }
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
    [IO.File]::WriteAllText($log, $logText, [Text.UTF8Encoding]::new($false))
    Get-Content -LiteralPath $log -Tail 5
    if ($code -ne 0) {
        [Console]::Error.WriteLine("task-done: test command exited $code; Task $number NOT recorded (full output: $log)")
        exit $code
    }
    $last = @($logText -split '\r?\n' | Where-Object { $_ -match '\S' } | Select-Object -Last 1)
    if ($last.Count -eq 0) { $last = @('(no output)') }
    $displayCommand = (@($testCommand) + $testArguments | ForEach-Object {
        $value = [string] $_
        if ($value -cmatch '^[a-zA-Z0-9_./:\\=-]+$') { $value }
        else { "'$($value.Replace("'", "''"))'" }
    }) -join ' '
    $baseShort = & git rev-parse --short=7 $baseCommit
    if ($LASTEXITCODE -ne 0) { throw 'could not resolve BASE for the ledger' }
    $headShort = & git rev-parse --short=7 HEAD
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
