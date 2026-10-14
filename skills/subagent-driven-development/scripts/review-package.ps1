#requires -Version 7.0
# Usage: review-package.ps1 PLAN_FILE BASE HEAD [OUTFILE]
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
if ($args.Count -lt 3 -or $args.Count -gt 4) {
    [Console]::Error.WriteLine('usage: review-package.ps1 PLAN_FILE BASE HEAD [OUTFILE]')
    exit 2
}
$plan = [string] $args[0]
$base = [string] $args[1]
$head = [string] $args[2]
if (!(Test-Path -LiteralPath $plan -PathType Leaf)) {
    [Console]::Error.WriteLine("no such plan file: $plan")
    exit 2
}
try {
    $baseCommit = & git rev-parse --verify --quiet --end-of-options "$base^{commit}"
    if ($LASTEXITCODE -ne 0) { throw "bad BASE: $base" }
    $headCommit = & git rev-parse --verify --quiet --end-of-options "$head^{commit}"
    if ($LASTEXITCODE -ne 0) { throw "bad HEAD: $head" }
    & git merge-base --is-ancestor $baseCommit $headCommit
    if ($LASTEXITCODE -ne 0) {
        [Console]::Error.WriteLine("HEAD is not a descendant of BASE: $base..$head")
        exit 3
    }
    $range = "$baseCommit..$headCommit"
    $commits = & git rev-list --count $range
    if ($LASTEXITCODE -ne 0) { throw 'could not count review commits' }
    if ([int] $commits -eq 0) {
        [Console]::Error.WriteLine("empty commit range: $base..$head")
        exit 3
    }
    if ($args.Count -eq 4) { $outFile = [string] $args[3] }
    else {
        $directory = & "$PSScriptRoot/sdd-workspace.ps1" $plan
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        $baseShort = & git rev-parse --short $baseCommit
        $headShort = & git rev-parse --short $headCommit
        $outFile = Join-Path $directory "review-$baseShort..$headShort.diff"
    }
    $commitLog = & git log --oneline $range
    if ($LASTEXITCODE -ne 0) { throw 'could not read review commits' }
    $stat = & git diff --stat $range
    if ($LASTEXITCODE -ne 0) { throw 'could not read review diff summary' }
    $diff = & git diff -U10 $range
    if ($LASTEXITCODE -ne 0) { throw 'could not read review diff' }
    $lines = @("# Review package: $base..$head", '', '## Commits') + @($commitLog) + @('', '## Files changed') + @($stat) + @('', '## Diff') + @($diff)
    $outPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($outFile)
    [IO.File]::WriteAllLines($outPath, [string[]] $lines, [Text.UTF8Encoding]::new($false))
    Write-Output "wrote ${outFile}: $commits commit(s), $([IO.FileInfo]::new($outPath).Length) bytes"
    exit 0
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 2
}
