#requires -Version 7.0
# Run with: pwsh -NoProfile -File tests/powershell/test-plan-helpers.ps1
# No Pester or Bash dependency. Fixtures live in a disposable Git repository.
$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$ep = Join-Path $repoRoot 'skills/executing-plans/scripts'
$sdd = Join-Path $repoRoot 'skills/subagent-driven-development/scripts'
$pwsh = (Get-Command pwsh -CommandType Application | Select-Object -First 1).Source
$git = (Get-Command git -CommandType Application | Select-Object -First 1).Source
$script:failures = 0
$script:checks = 0

function Check([bool] $Condition, [string] $Name) {
    $script:checks++
    if ($Condition) { Write-Output "  [PASS] $Name" }
    else { Write-Output "  [FAIL] $Name"; $script:failures++ }
}

function Run([string] $File, [string[]] $Arguments = @()) {
    $start = [Diagnostics.ProcessStartInfo]::new($pwsh)
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $start.WorkingDirectory = $script:fixture
    # Prove the PowerShell route works without Bash or Unix utilities on PATH.
    $start.Environment['PATH'] = "$(Split-Path $pwsh)$([IO.Path]::PathSeparator)$(Split-Path $git)"
    foreach ($value in @('-NoProfile', '-File', $File) + $Arguments) {
        $start.ArgumentList.Add($value)
    }
    $process = [Diagnostics.Process]::Start($start)
    try {
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()
        return @{ Code = $process.ExitCode; Out = $stdout.GetAwaiter().GetResult(); Err = $stderr.GetAwaiter().GetResult() }
    } finally { $process.Dispose() }
}

function WriteText([string] $Path, [string] $Value) {
    [IO.File]::WriteAllText($Path, $Value, [Text.UTF8Encoding]::new($false))
}

foreach ($file in @("$ep/task-start.ps1", "$ep/task-done.ps1", "$sdd/sdd-workspace.ps1", "$sdd/task-brief.ps1", "$sdd/review-package.ps1")) {
    Check (Test-Path -LiteralPath $file -PathType Leaf) "native helper exists: $(Split-Path $file -Leaf)"
}
if ($script:failures) { exit 1 }

$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$testRoot = Join-Path $tempBase "superpowers-plan-helpers-$([guid]::NewGuid())"
$script:fixture = Join-Path $testRoot 'repo with spaces'
New-Item -ItemType Directory -Path $script:fixture -Force | Out-Null
$originalLocation = Get-Location
try {
    Set-Location -LiteralPath $script:fixture
    & $git init -q -b main .
    if ($LASTEXITCODE) { throw 'git init failed' }
    $fixtureAlias = $script:fixture
    $script:fixture = (Resolve-Path -LiteralPath (& $git rev-parse --show-toplevel)).ProviderPath
    Set-Location -LiteralPath $script:fixture
    $plan = 'plan with spaces.md'
    WriteText (Join-Path $script:fixture $plan) @'
# Plan

Global constraint supplied separately by the controller.

## Task 1: First task

Keep this complete task text.
```markdown
## Task 2: This is a fenced example, not a boundary
```
Include the text after the fence.

## Task 2: Second task

Do not include this in Task 1.

## Task 10: Tenth task

Do not confuse task prefixes.
'@
    & $git add -- $plan
    & $git -c user.name=Fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit -qm fixture
    if ($LASTEXITCODE) { throw 'fixture commit failed' }
    $base = (& $git rev-parse HEAD).Trim()

    $result = Run "$ep/task-start.ps1" @($plan)
    Check ($result.Code -eq 2) 'task-start requires a task number'
    $result = Run "$ep/task-start.ps1" @('missing.md', '1')
    Check ($result.Code -eq 2 -and $result.Err -match 'no such plan') 'missing plan errors before creating artifacts'
    $result = Run "$ep/task-start.ps1" @($plan, '../outside')
    Check ($result.Code -eq 2) 'task number cannot escape the workspace'

    $result = Run "$ep/task-start.ps1" @($plan, '1')
    $workspace = [IO.Path]::GetFullPath((Join-Path $script:fixture '.superpowers/sdd/plan with spaces'))
    $brief = Join-Path $workspace 'task-1-brief.md'
    Check ($result.Code -eq 0 -and $result.Out.Contains("brief: $brief") -and $result.Out.Contains("base: $base")) 'task-start handles spaced paths and reports HEAD'
    if ($result.Code -ne 0 -or !$result.Out.Contains("brief: $brief")) { Write-Output "    expected brief: $brief; actual: $($result.Out) $($result.Err)" }
    $briefText = Get-Content -LiteralPath $brief -Raw
    Check ($briefText.Contains('fenced example') -and $briefText.Contains('after the fence') -and !$briefText.Contains('Second task') -and !$briefText.Contains('Tenth task')) 'task extraction respects fences and exact task boundaries'
    Check (!$briefText.Contains('Global constraint')) 'task-only extraction retains the controller-supplied global-context contract'
    $result = Run "$sdd/task-brief.ps1" @($plan, '99')
    Check ($result.Code -eq 3 -and $result.Err -match 'not found') 'missing task returns exit 3'
    $explicitBrief = Join-Path $testRoot 'explicit brief.md'
    $result = Run "$sdd/task-brief.ps1" @($plan, '2', $explicitBrief)
    Check ($result.Code -eq 0 -and (Get-Content -LiteralPath $explicitBrief -Raw).Contains('Second task')) 'task-brief honors an explicit output path'
    $result = Run "$sdd/sdd-workspace.ps1" @((Join-Path $fixtureAlias $plan))
    Check ($result.Code -eq 0 -and $result.Out.Trim() -eq $workspace) 'absolute and relative plan spellings reuse the same workspace'
    if ($result.Out.Trim() -ne $workspace) { Write-Output "    expected workspace: $workspace; actual: $($result.Out) $($result.Err)" }
    Check ((Get-Content -LiteralPath (Join-Path $workspace 'plan-path') -Raw).Trim() -eq $plan) 'workspace marker uses the repository-relative plan path'
    Check ((@(& $git status --porcelain) -join "`n") -notmatch '\.superpowers') 'workspace artifacts are self-ignoring'

    $otherPlanDir = Join-Path $script:fixture 'other'
    New-Item -ItemType Directory -Path $otherPlanDir | Out-Null
    Copy-Item -LiteralPath $plan -Destination (Join-Path $otherPlanDir $plan)
    $result = Run "$sdd/sdd-workspace.ps1" @("other/$plan")
    Check ($result.Code -eq 0 -and $result.Out.Trim() -eq "$workspace-other") 'same-basename plans receive distinct workspaces'
    $ignorePath = Join-Path $script:fixture '.superpowers/sdd/.gitignore'
    WriteText $ignorePath "*`n!*/progress.md`n"
    $result = Run "$sdd/sdd-workspace.ps1" @($plan)
    Check ((Get-Content -LiteralPath $ignorePath -Raw) -eq "*`n!*/progress.md`n") 'existing workspace ignore rules are preserved'

    WriteText (Join-Path $script:fixture 'work.txt') "new work`n"
    & $git add -- work.txt
    & $git -c user.name=Fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit -qm work
    if ($LASTEXITCODE) { throw 'fixture task commit failed' }
    $head = (& $git rev-parse HEAD).Trim()
    $testCommand = Join-Path $testRoot 'test command.ps1'
    WriteText $testCommand @'
[Console]::Out.WriteLine('first output')
1..8 | ForEach-Object { [Console]::Out.WriteLine("output $_") }
[Console]::Error.WriteLine('captured stderr')
[Console]::Out.WriteLine('PASS')
exit 0
'@
    $result = Run "$ep/task-done.ps1" @($plan, '1', $base, '--', $pwsh, '-NoProfile', '-File', $testCommand)
    $ledger = Join-Path $workspace 'progress.md'
    $log = Join-Path $workspace 'task-1-tests.log'
    $ledgerText = Get-Content -LiteralPath $ledger -Raw
    $logText = Get-Content -LiteralPath $log -Raw
    Check ($result.Code -eq 0 -and $ledgerText.Contains("Task 1: complete (commits $($base.Substring(0,7))..$($head.Substring(0,7))")) 'passing native command appends the task and commit range'
    Check ($logText.Contains('first output') -and $logText.Contains('captured stderr') -and $logText.Contains('PASS')) 'full stdout and stderr are captured'
    Check ($result.Out.Contains('PASS') -and !$result.Out.Contains('first output')) 'task-done prints only the log tail plus ledger result'

    WriteText $testCommand "[Console]::Error.WriteLine('FAILED'); exit 17`n"
    $result = Run "$ep/task-done.ps1" @($plan, '2', $base, '--', $pwsh, '-NoProfile', '-File', $testCommand)
    Check ($result.Code -eq 17 -and $result.Err -match 'NOT recorded') 'failed test exit status is propagated'
    Check ((Get-Content -LiteralPath $ledger -Raw) -eq $ledgerText) 'failed test leaves the completion ledger unchanged'
    Check ((Get-Content -LiteralPath (Join-Path $workspace 'task-2-tests.log') -Raw).Contains('FAILED')) 'failure output is retained'

    WriteText $testCommand 'exit 0'
    $result = Run "$ep/task-done.ps1" @($plan, '2', $base, '--', $testCommand)
    Check ($result.Code -eq 0 -and (Get-Content -LiteralPath $ledger -Raw).Contains('→ (no output)')) 'PowerShell script command and silent success are supported'

    $marker = Join-Path $testRoot 'must-not-run.txt'
    WriteText $testCommand "[IO.File]::WriteAllText('$($marker.Replace("'", "''"))', 'ran')"
    $result = Run "$ep/task-done.ps1" @($plan, '2', 'not-a-revision', '--', $pwsh, '-NoProfile', '-File', $testCommand)
    Check ($result.Code -eq 2 -and !(Test-Path -LiteralPath $marker)) 'invalid BASE prevents test execution'
    $result = Run "$ep/task-done.ps1" @('missing.md', '2', $base, '--', $pwsh, '-NoProfile', '-File', $testCommand)
    Check ($result.Code -eq 2 -and !(Test-Path -LiteralPath $marker)) 'invalid plan prevents test execution'
    $result = Run "$ep/task-done.ps1" @($plan, '2', $base, '--', 'superpowers-command-does-not-exist')
    Check ($result.Code -eq 127) 'missing test executable reports exit 127'

    WriteText $testCommand '[Console]::Out.WriteLine((ConvertTo-Json -InputObject @($args) -Compress))'
    $literalArguments = @('with spaces', '', 'say "hello"', "single'quote", '; echo injected', 'a&b|c', '$(touch should-not-exist)', '`literal', '--flag', 'trailing\')
    $result = Run "$ep/task-done.ps1" (@($plan, '3', $base, '--', $pwsh, '-NoProfile', '-File', $testCommand) + $literalArguments)
    $received = @(Get-Content -LiteralPath (Join-Path $workspace 'task-3-tests.log') -Raw | ConvertFrom-Json)
    Check ($result.Code -eq 0 -and (ConvertTo-Json -InputObject $received -Compress) -eq (ConvertTo-Json -InputObject $literalArguments -Compress)) 'native argv preserves empty strings, spaces, quotes, metacharacters, and boundaries'
    Check (!(Test-Path -LiteralPath 'should-not-exist')) 'test arguments are never evaluated as shell expressions'

    $result = Run "$sdd/review-package.ps1" @($plan, $base, $head)
    $package = (Get-ChildItem -LiteralPath $workspace -Filter 'review-*.diff').FullName
    $packageText = Get-Content -LiteralPath $package -Raw
    Check ($result.Code -eq 0 -and $packageText.Contains('## Commits') -and $packageText.Contains('## Files changed') -and $packageText.Contains('+new work')) 'review package contains commits, stat, and full task diff'
    $explicitPackage = Join-Path $testRoot 'explicit package.diff'
    $result = Run "$sdd/review-package.ps1" @($plan, $base, $head, $explicitPackage)
    Check ($result.Code -eq 0 -and (Test-Path -LiteralPath $explicitPackage)) 'review package honors an explicit output path'
    $result = Run "$sdd/review-package.ps1" @($plan, 'bad-base', $head)
    Check ($result.Code -eq 2) 'review package rejects invalid BASE'
    $result = Run "$sdd/review-package.ps1" @($plan, $base, 'bad-head')
    Check ($result.Code -eq 2) 'review package rejects invalid HEAD'
    $result = Run "$sdd/review-package.ps1" @($plan, $head, $head)
    Check ($result.Code -eq 3 -and $result.Err -match 'empty commit range') 'review package rejects empty commit ranges'
    $result = Run "$sdd/review-package.ps1" @($plan, $head, $base)
    Check ($result.Code -eq 3 -and $result.Err -match 'not a descendant') 'review package rejects a range not rooted at BASE'
} finally {
    Set-Location -LiteralPath $originalLocation.Path
    $resolvedTestRoot = [IO.Path]::GetFullPath($testRoot)
    if ($resolvedTestRoot.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase) -and
        (Split-Path $resolvedTestRoot -Leaf) -match '^superpowers-plan-helpers-[0-9a-f-]+$') {
        Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
    } else { throw "Refusing fixture cleanup outside the temporary test directory: $resolvedTestRoot" }
}
Write-Output "Checks: $script:checks; failures: $script:failures"
if ($script:failures) { exit 1 }
