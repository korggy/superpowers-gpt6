#requires -Version 7.0
# Extract Task N only; the controller supplies plan-wide context separately.
# Usage: task-brief.ps1 PLAN_FILE TASK_NUMBER [OUTFILE]
$ErrorActionPreference = 'Stop'
if ($args.Count -lt 2 -or $args.Count -gt 3 -or [string] $args[1] -notmatch '^[1-9][0-9]*$') {
    [Console]::Error.WriteLine('usage: task-brief.ps1 PLAN_FILE TASK_NUMBER [OUTFILE] (positive task number)')
    exit 2
}
$plan = [string] $args[0]
$number = [string] $args[1]
if (!(Test-Path -LiteralPath $plan -PathType Leaf)) {
    [Console]::Error.WriteLine("no such plan file: $plan")
    exit 2
}
try {
    $lines = [Collections.Generic.List[string]]::new()
    $fence = ''
    $fenceLength = 0
    $inTask = $false
    $matchesFound = 0
    foreach ($line in [IO.File]::ReadAllLines((Resolve-Path -LiteralPath $plan).ProviderPath)) {
        if ($fence) {
            if ($line -match ('^ {0,3}' + [regex]::Escape($fence) + '{' + $fenceLength + ',}[ \t]*$')) { $fence = '' }
        } elseif ($line -match '^ {0,3}(`{3,}|~{3,})(.*)$' -and
                  !($Matches[1][0] -eq '`' -and $Matches[2].Contains('`'))) {
            $fence = [string] $Matches[1][0]
            $fenceLength = $Matches[1].Length
        } elseif ($line -cmatch '^ {0,3}#{1,6}[ \t]+Task[ \t]+([0-9]+)(?=[^0-9]|$)') {
            $inTask = $Matches[1] -ceq $number
            if ($inTask) { $matchesFound++ }
        }
        if ($inTask) { $lines.Add($line) }
    }
    if ($lines.Count -eq 0) {
        [Console]::Error.WriteLine("task $number not found in $plan (no heading matching 'Task $number')")
        exit 3
    }
    if ($matchesFound -ne 1) {
        [Console]::Error.WriteLine("task $number is ambiguous in $plan (duplicate task headings)")
        exit 3
    }
    # Validate before creating the workspace or touching an explicit output.
    if ($args.Count -eq 3) { $outFile = [string] $args[2] }
    else {
        $directory = & "$PSScriptRoot/sdd-workspace.ps1" $plan
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        $outFile = Join-Path $directory "task-$number-brief.md"
    }
    $outPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($outFile)
    [IO.File]::WriteAllLines($outPath, $lines, [Text.UTF8Encoding]::new($false))
    Write-Output "wrote ${outFile}: $($lines.Count) lines"
    exit 0
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 2
}
