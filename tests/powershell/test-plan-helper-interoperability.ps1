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
$checks = 0
$posixHelpers = $helpers.Replace('\', '/')

function StartHelper([string] $Executable, [string[]] $Arguments) {
    $start = [Diagnostics.ProcessStartInfo]::new($Executable)
    $start.UseShellExecute = $false
    $start.WorkingDirectory = $fixture
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    foreach ($value in $Arguments) { $start.ArgumentList.Add($value) }
    return [Diagnostics.Process]::Start($start)
}
function FinishHelper([Diagnostics.Process] $Process) {
    try {
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()
        $output = $stdout.GetAwaiter().GetResult().Trim()
        if ($process.ExitCode) { throw "helper failed ($($process.ExitCode)): $($stderr.GetAwaiter().GetResult())" }
        return $output
    } finally { $process.Dispose() }
}
function Run([string] $Executable, [string[]] $Arguments) {
    FinishHelper (StartHelper $Executable $Arguments)
}
function NativeWorkspace([string] $Plan) {
    [IO.Path]::GetFullPath((Run $pwsh @('-NoProfile', '-File', "$helpers/sdd-workspace.ps1", $Plan)))
}
function BashWorkspace([string] $Plan) {
    [IO.Path]::GetFullPath((Run $GitBash @("$helpers/sdd-workspace".Replace('\', '/'), $Plan.Replace('\', '/'))))
}
function Check([bool] $Passed, [string] $Name) {
    $script:checks++
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
    # Hold an in-flight marker for a legacy workspace. Each different plan
    # also collides on the parent-name suffix (every parent is named shared).
    $race = Join-Path $fixture '.superpowers/sdd/race'
    [IO.Directory]::CreateDirectory($race) | Out-Null
    $legacyLedger = Join-Path $race 'progress.md'
    [IO.File]::WriteAllText($legacyLedger, "existing evidence`n")
    $marker = Join-Path $race 'plan-path'
    $lock = "$marker.lock"
    $plans = @('one/shared/race.md', 'two/shared/race.md', 'three/shared/race.md')
    [IO.File]::WriteAllText($lock, "$($plans[0])`n")
    $workers = foreach ($path in $plans) {
        $file = Join-Path $fixture $path
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($file)) | Out-Null
        [IO.File]::WriteAllText($file, $planText)
        @{ Plan = $path; Process = StartHelper $pwsh @('-NoProfile', '-File', "$helpers/sdd-workspace.ps1", $path) }
        @{ Plan = $path; Process = StartHelper $GitBash @("$posixHelpers/sdd-workspace", $path) }
    }
    $finishedEarly = $workers[1].Process.WaitForExit(750)
    Check (!$finishedEarly -and ![IO.File]::Exists($marker)) 'an in-flight exclusive claim is respected before publication'
    [IO.File]::Move($lock, $marker)
    $owners = @{}
    foreach ($worker in $workers) {
        $dir = [IO.Path]::GetFullPath((FinishHelper $worker.Process))
        $owner = [IO.File]::ReadAllText((Join-Path $dir 'plan-path')).TrimEnd("`r", "`n")
        Check ($owner -ceq $worker.Plan -and (!$owners.ContainsKey($owner) -or $owners[$owner] -eq $dir)) "concurrent helper returns its own plan's workspace for $($worker.Plan)"
        $owners[$owner] = $dir
    }
    Check (($owners.Values | Sort-Object -Unique).Count -eq $plans.Count -and
        $owners[$plans[0]] -eq $race -and [IO.File]::ReadAllText($legacyLedger) -ceq "existing evidence`n") 'concurrent same-basename plans retain unique owners and the existing ledger'

    $primary = $fixture
    & git -C $primary -c user.name=Fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --allow-empty -qm 'primary base'
    if ($LASTEXITCODE) { throw 'primary commit failed' }
    $base = (& git -C $primary rev-parse HEAD).Trim()
    $linked = Join-Path $fixtureRoot 'linked worktree'
    & git -C $primary worktree add -q --detach $linked $base
    if ($LASTEXITCODE) { throw 'linked worktree creation failed' }
    & git -C $linked -c user.name=Fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --allow-empty -qm 'only in the worktree'
    if ($LASTEXITCODE) { throw 'linked worktree commit failed' }
    $head = (& git -C $linked rev-parse HEAD).Trim()
    $plan = Join-Path $primary 'uncommitted primary plan.md'
    [IO.File]::WriteAllText($plan, "## Task A1: Mixed`nA naïve example.`n~~~`n## Task 9: Example`n~~~`n## Task 2.1: Next`nAnother task.`n")
    $posixPlan = $plan.Replace('\', '/')
    $posixLinked = $linked.Replace('\', '/')
    $nativeDir = Run $pwsh @('-NoProfile', '-File', "$helpers/sdd-workspace.ps1", '-C', $linked, $plan)
    $bashDir = Run $GitBash @("$posixHelpers/sdd-workspace", '-C', $posixLinked, $posixPlan)
    $expected = Join-Path $linked '.superpowers/sdd/uncommitted primary plan'
    Check ([IO.Path]::GetFullPath($nativeDir) -eq [IO.Path]::GetFullPath($bashDir) -and
        [IO.File]::Exists((Join-Path $expected 'plan-path'))) 'both -C helpers resolve the linked workspace from the primary checkout'

    $nativeBrief = Join-Path $linked 'native.md'
    $bashBrief = Join-Path $linked 'bash.md'
    $null = Run $pwsh @('-NoProfile', '-File', "$helpers/task-brief.ps1", '-C', $linked, $plan, 'A1', 'native.md')
    $null = Run $GitBash @("$posixHelpers/task-brief", '-C', $posixLinked, $posixPlan, 'A1', 'bash.md')
    $brief = [IO.File]::ReadAllText($nativeBrief).Replace("`r`n", "`n")
    Check ($brief -ceq [IO.File]::ReadAllText($bashBrief).Replace("`r`n", "`n") -and
        $brief.Contains('naïve') -and !$brief.Contains('Another task')) 'both shells extract identical task lines into explicit -C-relative outputs'

    $null = Run $pwsh @('-NoProfile', '-File', "$helpers/review-package.ps1", '-C', $linked, $plan, $base, 'HEAD', 'native.diff')
    $null = Run $GitBash @("$posixHelpers/review-package", '-C', $posixLinked, $posixPlan, $base, 'HEAD', 'bash.diff')
    $review = [IO.File]::ReadAllText((Join-Path $linked 'native.diff')).Replace("`r`n", "`n")
    Check ($review -ceq [IO.File]::ReadAllText((Join-Path $linked 'bash.diff')).Replace("`r`n", "`n") -and
        $review.Contains('only in the worktree')) 'review packages cover the same worktree-only commit'

    $fixture = $linked
    $ep = [IO.Path]::GetFullPath((Join-Path $helpers '../../executing-plans/scripts'))
    $posixEp = $ep.Replace('\', '/')
    $nativeStart = Run $pwsh @('-NoProfile', '-File', "$ep/task-start.ps1", $plan, 'A1')
    $bashStart = Run $GitBash @("$posixEp/task-start", $posixPlan, 'A1')
    Check ($nativeStart.Contains("base: $head") -and $bashStart.Contains("base: $head")) 'task-start reads HEAD in the linked worktree for an external plan'

    $existingLog = Join-Path $linked 'verified.log'
    [IO.File]::WriteAllText($existingLog, "naïve check passed`n")
    $null = Run $pwsh @('-NoProfile', '-File', "$ep/task-done.ps1", $plan, 'A1', $base, '--evidence', 'verified.log', $head, '0', 'cross-shell test')
    $null = Run $GitBash @("$posixEp/task-done", $posixPlan, '2.1', $base, '--evidence', 'verified.log', $head, '0', 'cross-shell test')
    $nativeLog = [IO.File]::ReadAllText((Join-Path $expected 'task-A1-tests.log'))
    $bashLog = [IO.File]::ReadAllText((Join-Path $expected 'task-2.1-tests.log'))
    $ledger = [IO.File]::ReadAllLines((Join-Path $expected 'progress.md'))
    Check ($nativeLog -ceq $bashLog -and $nativeLog -ceq [IO.File]::ReadAllText($existingLog)) 'recorded evidence preserves the same UTF-8 log across shells'
    Check ($ledger.Count -eq 3 -and $ledger[1].StartsWith('Task A1: complete') -and
        $ledger[1].Replace('Task A1:', 'Task 2.1:') -ceq $ledger[2] -and
        !(Test-Path -LiteralPath (Join-Path $primary '.superpowers/sdd/uncommitted primary plan'))) 'both shells append matching records to the linked ledger only'

} finally {
    $resolved = [IO.Path]::GetFullPath($fixtureRoot)
    if ([IO.Path]::GetDirectoryName($resolved) -eq $tempBase.TrimEnd('\', '/') -and
        [IO.Path]::GetFileName($resolved) -match '^superpowers-interop-[0-9a-f-]+$') {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    } else { throw "Refusing cleanup outside the disposable fixture: $resolved" }
}
Write-Output "Checks: $checks; failures: $failures"
if ($failures) { exit 1 }
