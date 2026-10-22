#requires -Version 7.0
# Optional Windows interoperability suite; the native suite needs only Git and pwsh.
param(
    [Parameter(Mandatory)] [string] $GitBash,
    [string] $TempRoot = [IO.Path]::GetTempPath()
)
$ErrorActionPreference = 'Stop'
$helpers = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../skills/subagent-driven-development/scripts'))
$pwsh = Join-Path $PSHOME 'pwsh.exe'
$tempBase = (Resolve-Path -LiteralPath $TempRoot).ProviderPath
$fixtureRoot = Join-Path $tempBase "superpowers-interop-$([guid]::NewGuid())"
$fixture = Join-Path $fixtureRoot 'repo with spaces'
[IO.Directory]::CreateDirectory($fixture) | Out-Null
$failures = 0

function Run([string] $Executable, [string[]] $Arguments) {
    $start = [Diagnostics.ProcessStartInfo]::new($Executable)
    $start.UseShellExecute = $false
    $start.WorkingDirectory = $fixture
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    foreach ($value in $Arguments) { $start.ArgumentList.Add($value) }
    $process = [Diagnostics.Process]::Start($start)
    try {
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()
        $output = $stdout.GetAwaiter().GetResult().Trim()
        if ($process.ExitCode) { throw "helper failed ($($process.ExitCode)): $($stderr.GetAwaiter().GetResult())" }
        if ($output -match '^/([a-zA-Z])/(.*)$') { $output = "$($Matches[1]):/$($Matches[2])" }
        return [IO.Path]::GetFullPath($output)
    } finally { $process.Dispose() }
}
function NativeWorkspace([string] $Plan) {
    Run $pwsh @('-NoProfile', '-File', "$helpers/sdd-workspace.ps1", $Plan)
}
function BashWorkspace([string] $Plan) {
    Run $GitBash @("$helpers/sdd-workspace".Replace('\', '/'), $Plan.Replace('\', '/'))
}
function Check([bool] $Passed, [string] $Name) {
    if ($Passed) { Write-Output "[PASS] $Name" }
    else { Write-Output "[FAIL] $Name"; $script:failures++ }
}
try {
    & git init -q $fixture
    if ($LASTEXITCODE) { throw 'fixture git init failed' }
    $planText = "## Task 1: Shared plan`nSame workspace across shells.`n"
    [IO.File]::WriteAllText((Join-Path $fixture 'plan.md'), $planText)
    Check ((NativeWorkspace 'plan.md') -eq (BashWorkspace 'plan.md')) 'in-repository plan reuses one workspace across shells'
    $nativeFirst = Join-Path $fixtureRoot 'outside native first.md'
    [IO.File]::WriteAllText($nativeFirst, $planText)
    Check ((NativeWorkspace $nativeFirst) -eq (BashWorkspace $nativeFirst)) 'outside plan created by PowerShell is reused by Git Bash'
    $bashFirst = Join-Path $fixtureRoot 'outside bash first.md'
    [IO.File]::WriteAllText($bashFirst, $planText)
    Check ((BashWorkspace $bashFirst) -eq (NativeWorkspace $bashFirst)) 'outside plan created by Git Bash is reused by PowerShell'
} finally {
    $resolved = [IO.Path]::GetFullPath($fixtureRoot)
    if ([IO.Path]::GetDirectoryName($resolved) -eq $tempBase.TrimEnd('\', '/') -and
        [IO.Path]::GetFileName($resolved) -match '^superpowers-interop-[0-9a-f-]+$') {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    } else { throw "Refusing cleanup outside the disposable fixture: $resolved" }
}
Write-Output "Checks: 3; failures: $failures"
if ($failures) { exit 1 }
