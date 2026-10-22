#requires -Version 7.0
[CmdletBinding()]
param([string]$OutputDirectory)
$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$manifest = Get-Content -Raw -LiteralPath (Join-Path $repoRoot '.codex-plugin/plugin.json') | ConvertFrom-Json
if ($manifest.name -ne 'superpowers-gpt6') { throw 'Unexpected plugin identity.' }
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $repoRoot ('dist/' + $manifest.version + '-' + (Get-Date -Format 'yyyyMMdd-HHmmss')) }
$outputRoot = [IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $outputRoot) { throw "Output already exists; choose a new directory: $outputRoot" }
$marketRoot = Join-Path $outputRoot 'bettergood'
$pluginRoot = Join-Path $marketRoot 'plugins/superpowers-gpt6'
New-Item -ItemType Directory -Path $pluginRoot -Force | Out-Null

# Explicit package allowlist: no repository history, active profile, tests or caches.
$include = @('skills','assets','hooks','.codex-plugin','.claude-plugin','.cursor-plugin','.devin-plugin','.kimi-plugin','.antigravity-plugin','.muse-plugin','.hermes-plugin','.pi','.opencode','index.js','package.json','gemini-extension.json','GEMINI.md','README.md','LICENSE','AGENTS.md','docs/testing.md','docs/prompts/superpowers-7.0.1-gpt6-customization.md','docs/GPT6-RELEASE.md','docs/GPT6-VALIDATION.md')
$excludedSegments = @('.git','node_modules','__pycache__','.superpowers')
foreach ($relative in $include) {
    $source = Join-Path $repoRoot $relative
    if (-not (Test-Path -LiteralPath $source)) { throw "Required package input missing: $relative" }
    $item = Get-Item -LiteralPath $source -Force
    $files = if ($item.PSIsContainer) { Get-ChildItem -LiteralPath $source -Recurse -Force -File } else { @($item) }
    foreach ($file in $files) {
        if ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Package inputs cannot be links: $($file.FullName)" }
        $rel = [IO.Path]::GetRelativePath($repoRoot, $file.FullName).Replace('\','/')
        if (($rel.Split('/') | Where-Object { $_ -in $excludedSegments }).Count -gt 0) { continue }
        if ($file.Name -eq 'marketplace.json' -or $file.Extension -eq '.pyc') { continue }
        $target = Join-Path $pluginRoot $rel
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $target
    }
}

$catalogDir = Join-Path $marketRoot '.agents/plugins'
New-Item -ItemType Directory -Path $catalogDir -Force | Out-Null
$catalog = [ordered]@{name='bettergood'; interface=@{displayName='BetterGood'}; plugins=@(@{name=$manifest.name; source=@{source='local';path='./plugins/superpowers-gpt6'};category='Developer Tools'})}
$catalog | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $catalogDir 'marketplace.json') -Encoding utf8NoBOM

$base = (& git -C $repoRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Cannot establish source base revision.' }
$sourceFiles = @(& git -C $repoRoot ls-files --cached --others --exclude-standard) | Sort-Object -Unique
if ($LASTEXITCODE -ne 0) { throw 'Cannot enumerate source files.' }
$sourceHashes = foreach ($rel in $sourceFiles) {
    $file = Join-Path $repoRoot $rel
    if (Test-Path -LiteralPath $file -PathType Leaf) { [ordered]@{path=$rel;sha256=(Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant()} }
}
$payloadHashes = foreach ($file in (Get-ChildItem -LiteralPath $pluginRoot -Recurse -Force -File | Sort-Object FullName)) {
    [ordered]@{path=[IO.Path]::GetRelativePath($pluginRoot,$file.FullName).Replace('\','/');sha256=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()}
}
$provenance = [ordered]@{plugin=$manifest.name;version=$manifest.version;upstreamVersion='7.0.1';upstreamRevision='2ce8aa15d05bd57213e6f746f953aafb7ded7a8b';priorCustomization='6ff96f4a47f2291ca20a3ddb3a01e3e236ba0246';candidate=@{kind='uncommitted-working-tree';baseRevision=$base;sourceFiles=$sourceHashes};packagedFiles=$payloadHashes;hashScope='SHA256 of exact file bytes. PROVENANCE.json excludes its own hash; archive hash is recorded separately.'}
$provenance | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $pluginRoot 'PROVENANCE.json') -Encoding utf8NoBOM

$pluginZip = Join-Path $outputRoot ($manifest.name + '-' + $manifest.version + '.zip')
$marketZip = Join-Path $outputRoot ('bettergood-marketplace-' + $manifest.version + '.zip')
[IO.Compression.ZipFile]::CreateFromDirectory($pluginRoot,$pluginZip)
[IO.Compression.ZipFile]::CreateFromDirectory($marketRoot,$marketZip)
@($pluginZip,$marketZip) | ForEach-Object { (Get-FileHash -LiteralPath $_ -Algorithm SHA256).Hash.ToLowerInvariant() + '  ' + [IO.Path]::GetFileName($_) } | Set-Content -LiteralPath (Join-Path $outputRoot 'SHA256SUMS.txt') -Encoding utf8NoBOM
[ordered]@{plugin=$pluginZip;marketplace=$marketZip;marketplaceDirectory=$marketRoot;provenance=(Join-Path $pluginRoot 'PROVENANCE.json');hashes=(Join-Path $outputRoot 'SHA256SUMS.txt')} | ConvertTo-Json
