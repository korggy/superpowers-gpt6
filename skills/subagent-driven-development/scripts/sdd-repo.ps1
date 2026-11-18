#requires -Version 7.0
# Dot-sourced by the native plan helpers. Git selects the caller's worktree.
function Get-SddRepository([switch] $WithCommit) {
    $result = @(& git rev-parse --show-toplevel 2>&1)
    if ($LASTEXITCODE -eq 0) {
        $root = [string] $result[0]
        if (!$WithCommit) { return $root }
        $result = @(& git -C $root rev-parse --verify 'HEAD^{commit}' 2>&1)
        if ($LASTEXITCODE -eq 0) { return $root }
    }
    throw "Run the SDD helper from the Git working tree you're executing in (current directory: $PWD). For operations requiring HEAD, make a first commit. Git said: $($result[0])"
}

# Apply a leading -C once and restore the caller's PowerShell session location.
function Invoke-SddAtDirectory([string] $File, [object[]] $Arguments) {
    $directory = [string] $Arguments[1]
    if (!$directory -or !(Test-Path -LiteralPath $directory -PathType Container)) {
        [Console]::Error.WriteLine("bad -C directory: $directory")
        exit 2
    }
    $remaining = @($Arguments | Select-Object -Skip 2)
    if ($remaining.Count -gt 0 -and $remaining[0] -ceq '-C') {
        [Console]::Error.WriteLine('expected plan file after -C DIR')
        exit 2
    }
    Push-Location -LiteralPath $directory
    try {
        & $File @remaining
        $code = $LASTEXITCODE
    } finally { Pop-Location }
    exit $code
}
