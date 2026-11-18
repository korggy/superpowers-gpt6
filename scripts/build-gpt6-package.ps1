#requires -Version 7.0
[CmdletBinding()]
param([string]$OutputDirectory)

$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$manifest = Get-Content -Raw -LiteralPath (Join-Path $repoRoot '.codex-plugin/plugin.json') | ConvertFrom-Json
if ($manifest.name -ne 'superpowers-gpt6') { throw 'Unexpected plugin identity.' }
if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $repoRoot ('dist/' + $manifest.version + '-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
}
$outputRoot = [IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $outputRoot) { throw "Choose a new output directory: $outputRoot" }

# Limit untracked inputs to the named fork additions. An editor backup, local
# credential file or evaluation transcript next to a skill must stay local.
$skillFiles = @(& git -C $repoRoot -c core.quotePath=false ls-files -- skills)
if ($LASTEXITCODE -ne 0 -or -not $skillFiles) { throw 'Cannot enumerate tracked skills.' }
$forkSkillFiles = @(
    'skills/executing-plans/references/final-review.md'
    'skills/executing-plans/scripts/task-done.ps1'
    'skills/executing-plans/scripts/task-start.ps1'
    'skills/subagent-driven-development/references/plan-helpers.md'
    'skills/subagent-driven-development/references/review-snapshot.md'
    'skills/subagent-driven-development/scripts/review-package.ps1'
    'skills/subagent-driven-development/scripts/sdd-repo.ps1'
    'skills/subagent-driven-development/scripts/sdd-workspace.ps1'
    'skills/subagent-driven-development/scripts/task-brief.ps1'
)
$runtimeFiles = @(
    'assets/antigravity-logo.png', 'assets/app-icon.png', 'assets/superpowers-small.svg'
    'hooks/hooks-cursor.json', 'hooks/hooks.json', 'hooks/run-hook.cmd', 'hooks/session-start'
    '.antigravity-plugin/plugin.json', '.claude-plugin/plugin.json', '.codex-plugin/plugin.json'
    '.cursor-plugin/plugin.json', '.devin-plugin/plugin.json', '.kimi-plugin/plugin.json'
    '.muse-plugin/plugin.json', '.hermes-plugin/plugin.yaml', '.hermes-plugin/__init__.py'
    '.opencode/plugins/superpowers.js', '.pi/extensions/superpowers.ts'
    'GEMINI.md', 'gemini-extension.json', 'index.js', 'package.json', 'README.md', 'LICENSE'
    'docs/GPT6-RELEASE.md'
)
$payloadPaths = @($skillFiles + $forkSkillFiles + $runtimeFiles | Sort-Object -Unique)
$base = & git -C $repoRoot rev-parse --verify HEAD
if ($LASTEXITCODE -ne 0) { throw 'Cannot establish the source revision.' }
$inputPaths = @($payloadPaths + @('.agents/plugins/marketplace.json', '.version-bump.json', 'scripts/build-gpt6-package.ps1') | Sort-Object -Unique)
$inputs = foreach ($relative in $inputPaths) {
    $source = Join-Path $repoRoot $relative
    $item = Get-Item -LiteralPath $source -Force
    if ($item.PSIsContainer) { throw "Expected file: $relative" }
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked input: $relative" }
    for ($parent = $item.Directory; $parent.FullName -ne $repoRoot; $parent = $parent.Parent) {
        if ($parent.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked input directory: $relative" }
    }
    [ordered]@{path=$relative; sha256=(Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()}
}

$marketRoot = Join-Path $outputRoot 'bettergood'
$pluginRoot = Join-Path $marketRoot 'plugins/superpowers-gpt6'
New-Item -ItemType Directory -Path $outputRoot | Out-Null
$packagedFiles = foreach ($inputFile in $inputs) {
    if ($inputFile.path -notin $payloadPaths) { continue }
    $target = Join-Path $pluginRoot $inputFile.path
    New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $repoRoot $inputFile.path) -Destination $target
    if ((Get-FileHash -LiteralPath $target).Hash -ne $inputFile.sha256) { throw "Input changed during build: $($inputFile.path)" }
    $inputFile
}

$catalog = Get-Content -Raw -LiteralPath (Join-Path $repoRoot '.agents/plugins/marketplace.json') | ConvertFrom-Json
if ($catalog.name -ne 'bettergood' -or $catalog.plugins.Count -ne 1 -or $catalog.plugins[0].name -ne $manifest.name -or
    $catalog.plugins[0].source.source -ne 'local' -or $catalog.plugins[0].source.path -ne './') {
    throw 'Invalid repository-root BetterGood catalog.'
}
$catalog.plugins[0].source.path = './plugins/superpowers-gpt6'
$catalogDir = New-Item -ItemType Directory -Path (Join-Path $marketRoot '.agents/plugins') -Force
$catalog | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $catalogDir 'marketplace.json') -Encoding utf8NoBOM

$provenance = [ordered]@{
    plugin=$manifest.name
    version=$manifest.version
    upstreamVersion='7.0.2'
    upstreamRevision='22f0b463e7a5e579904dd6211a520321035526f7'
    priorCustomization='a202a7e8dbeed17bf650d262cae661822b67a4d8'
    priorCatalogFix='822d51227aab80d68d102ed0cf25cb178732b6a1'
    candidate=[ordered]@{kind='working-tree';baseRevision=$base;sourceFiles=@($inputs)}
    packagedFiles=@($packagedFiles)
    hashScope='SHA-256 of each build input and copied payload file. The external checksums cover the finished archives, including this manifest.'
}
$provenanceFile = Join-Path $pluginRoot 'PROVENANCE.json'
$provenance | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $provenanceFile -Encoding utf8NoBOM

$pluginZip = Join-Path $outputRoot ($manifest.name + '-' + $manifest.version + '.zip')
$marketZip = Join-Path $outputRoot ('bettergood-marketplace-' + $manifest.version + '.zip')
[IO.Compression.ZipFile]::CreateFromDirectory($pluginRoot,$pluginZip)
[IO.Compression.ZipFile]::CreateFromDirectory($marketRoot,$marketZip)
$sums = Join-Path $outputRoot 'SHA256SUMS.txt'
@($pluginZip,$marketZip) | ForEach-Object {
    (Get-FileHash -LiteralPath $_ -Algorithm SHA256).Hash.ToLowerInvariant() + '  ' + [IO.Path]::GetFileName($_)
} | Set-Content -LiteralPath $sums -Encoding utf8NoBOM
[ordered]@{plugin=$pluginZip;marketplace=$marketZip;marketplaceDirectory=$marketRoot;provenance=$provenanceFile;hashes=$sums} | ConvertTo-Json
