param(
    [Parameter(Mandatory)][ValidateSet('control','baseline','candidate')][string]$Arm,
    [Parameter(Mandatory)][string]$CodexBinary,
    [Parameter(Mandatory)][string]$IsolatedCodexHome,
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$OutputDirectory,
    [string]$SourceRoot,
    [ValidateRange(5,100)][int]$Samples=5
)
$ErrorActionPreference='Stop'
if (!(Test-Path -LiteralPath $CodexBinary -PathType Leaf)) { throw 'Codex binary not found.' }
if (!(Test-Path -LiteralPath $IsolatedCodexHome -PathType Container)) { throw 'Prepare an isolated authenticated profile first.' }
if (!(Test-Path -LiteralPath $Workspace -PathType Container)) { throw 'Provide a disposable existing workspace.' }
if ($Arm -ne 'control' -and !(Test-Path -LiteralPath $SourceRoot -PathType Container)) { throw 'This arm requires a source snapshot.' }
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$prompt=Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'scenarios.txt')
if ($Arm -ne 'control') {
    $paths=@(Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'source-paths.json') | ConvertFrom-Json)
    if ($Arm -eq 'candidate') {
        $paths+='skills/executing-plans/references/final-review.md'
        $paths+='skills/subagent-driven-development/references/review-snapshot.md'
    }
    $hashes=foreach($path in $paths) {
        $file=Join-Path $SourceRoot $path
        [pscustomobject]@{path=$path;sha256=(Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant()}
    }
    $hashes | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $OutputDirectory "$Arm-hashes.json")
    $sources=foreach($path in $paths) { "`n<source path='$path'>`n$(Get-Content -Raw -LiteralPath (Join-Path $SourceRoot $path))`n</source>" }
    $prompt+="`nAvailable workflow source documents:`n"+($sources -join "`n")
}
$prompt | Set-Content -LiteralPath (Join-Path $OutputDirectory "$Arm.prompt.txt")
$priorCodexHome=$env:CODEX_HOME
try {
    $env:CODEX_HOME=$IsolatedCodexHome
    for($rep=1;$rep -le $Samples;$rep++) {
        $stem=Join-Path $OutputDirectory "$Arm-$rep"
        $arguments=@('exec','--ephemeral','--ignore-user-config','--ignore-rules','--skip-git-repo-check','-C',$Workspace,'-s','read-only','-m','gpt-6-astra','-c','model_reasoning_effort=medium','--json','-o',"$stem.txt",'-')
        $prompt | & $CodexBinary @arguments > "$stem.jsonl" 2> "$stem.stderr"
        if($LASTEXITCODE -ne 0) { throw "Sample $Arm-$rep failed; inspect its recorded output. No model substitution is allowed." }
    }
} finally {
    $env:CODEX_HOME=$priorCodexHome
}
