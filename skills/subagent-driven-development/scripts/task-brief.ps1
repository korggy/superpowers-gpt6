#requires -Version 7.0
# Extract Task N only; the controller supplies plan-wide context separately.
# Usage: task-brief.ps1 [-C DIR] PLAN_FILE TASK_NUMBER [OUTFILE]
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/sdd-repo.ps1"
if ($args.Count -gt 0 -and $args[0] -ceq '-C') {
    Invoke-SddAtDirectory $PSCommandPath $args
}
if ($args.Count -lt 2 -or $args.Count -gt 3) {
    [Console]::Error.WriteLine('usage: task-brief.ps1 [-C DIR] PLAN_FILE TASK_NUMBER [OUTFILE]')
    exit 2
}
$plan = [string] $args[0]
$number = [string] $args[1]
if ($number -cnotmatch '\A[A-Za-z0-9]+(?:\.[A-Za-z0-9]+)*\z' -or $number -notmatch '[0-9]') {
    [Console]::Error.WriteLine("invalid task ID: $number")
    exit 2
}
if (!(Test-Path -LiteralPath $plan -PathType Leaf)) {
    [Console]::Error.WriteLine("no such plan file: $plan")
    exit 2
}
try {
    $null = Get-SddRepository
    $lines = [Collections.Generic.List[string]]::new()
    $shapedHeadings = [Collections.Generic.List[string]]::new()
    $spellings = [Collections.Generic.Dictionary[string,string]]::new([StringComparer]::OrdinalIgnoreCase)
    $heading = '^ {0,3}(#{1,6})[ \t]+Task[ \t]+([A-Za-z0-9]+(?:\.[A-Za-z0-9]+)*)'
    $fence = ''
    $inTask = $false
    $found = 0
    $tasks = 0
    $lineNumber = 0
    foreach ($line in [IO.File]::ReadAllLines((Resolve-Path -LiteralPath $plan).ProviderPath)) {
        $lineNumber++
        if ($fence) {
            if ($line -match ('^ {0,3}' + [regex]::Escape($fence) + '{' + $fenceLength + ',}[ \t]*$')) {
                $fence = ''
            } elseif ($line -cmatch $heading -and $Matches[2] -match '[0-9]') {
                $hiddenHeading = $true
            }
        } elseif ($line -match '^ {0,3}(`{3,}|~{3,})(.*)$' -and
                  !($Matches[1][0] -eq '`' -and $Matches[2].Contains('`'))) {
            $fence = [string] $Matches[1][0]
            $fenceLength = $Matches[1].Length
            $fenceLine = $lineNumber
            $hiddenHeading = $false
        } elseif ($line -cmatch $heading) {
            $depth = $Matches[1].Length
            $id = $Matches[2]
            if ($id -match '[0-9]') {
                if ($spellings.ContainsKey($id) -and $spellings[$id] -cne $id) {
                    [Console]::Error.WriteLine("task IDs $($spellings[$id]) and $id differ only by case in $plan")
                    exit 3
                }
                $spellings[$id] = $id
                $tasks++
                $child = $inTask -and $depth -gt $level -and $id.StartsWith($number, [StringComparison]::Ordinal) -and
                    $id.Substring($number.Length) -cmatch '^[A-Za-z.]'
                if (!$child) {
                    $inTask = $id -ceq $number
                    $level = $depth
                    if ($inTask) { $found++ }
                }
            }
        } elseif ($shapedHeadings.Count -lt 5 -and $line -match '^ {0,3}#{1,6}[ \t]+[^ \t]+[ \t]+[A-Za-z0-9.]*[0-9]') {
            $shapedHeadings.Add($line)
        }
        if ($inTask) { $lines.Add($line) }
    }
    if ($found -gt 1) {
        [Console]::Error.WriteLine("task $number is ambiguous in $plan (duplicate task headings)")
        exit 3
    }
    if ($fence) {
        $where = "the code fence opened at line $fenceLine of $plan never closes"
        if ($hiddenHeading -and ($inTask -or !$found)) {
            [Console]::Error.WriteLine("task-brief: $where and hides a Task heading. Close the fence and rerun.")
            if ($inTask) { exit 4 }
        } elseif ($inTask) {
            [Console]::Error.WriteLine("task-brief: warning: $where. It hides no Task heading, so this brief is complete.")
        }
    }
    if (!$found) {
        if (!$tasks -and $shapedHeadings.Count -and !($fence -and $hiddenHeading)) {
            [Console]::Error.WriteLine('Task headings must use the English word "Task". Headings shaped like tasks:')
            foreach ($item in $shapedHeadings) { [Console]::Error.WriteLine("  $item") }
        }
        [Console]::Error.WriteLine("task $number not found in $plan (no heading matching 'Task $number')")
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
