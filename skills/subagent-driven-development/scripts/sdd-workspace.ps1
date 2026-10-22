#requires -Version 7.0
# Native PowerShell equivalent of sdd-workspace. Usage: sdd-workspace.ps1 PLAN_FILE
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false

if ($args.Count -ne 1) {
    [Console]::Error.WriteLine('usage: sdd-workspace.ps1 PLAN_FILE')
    exit 2
}
$plan = [string] $args[0]
if (!(Test-Path -LiteralPath $plan -PathType Leaf)) {
    [Console]::Error.WriteLine("no such plan file: $plan")
    exit 2
}

try {
    # Resolve-Path keeps Windows short names (MICHAE~1), while Git returns
    # long names. Rebuild existing path components from their actual names
    # so absolute and relative spellings produce the same ownership marker.
    function Normalize-ExistingPath([string] $Path) {
        $item = Get-Item -LiteralPath $Path -Force
        $parent = Split-Path $item.FullName -Parent
        if (!$parent) { return $item.FullName }
        return Join-Path (Normalize-ExistingPath $parent) $item.Name
    }
    $planPath = Normalize-ExistingPath (Resolve-Path -LiteralPath $plan).ProviderPath
    $slug = [IO.Path]::GetFileName($planPath)
    if ($slug.EndsWith('.md', [StringComparison]::Ordinal)) { $slug = $slug.Substring(0, $slug.Length - 3) }
    if (!$slug -or $slug -in '.', '..') { throw "cannot derive a workspace name from: $plan" }
    $root = & git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'sdd-workspace requires a Git working tree' }
    $root = (Resolve-Path -LiteralPath $root).ProviderPath
    $workspaceBase = Join-Path $root '.superpowers/sdd'
    $relative = [IO.Path]::GetRelativePath($root, $planPath)
    $planId = if ($relative -eq '..' -or $relative.StartsWith("..$([IO.Path]::DirectorySeparatorChar)") -or [IO.Path]::IsPathRooted($relative)) {
        $planPath.Replace('\', '/')
    } else { $relative.Replace('\', '/') }

    function Owns([string] $Directory) {
        $marker = Join-Path $Directory 'plan-path'
        if ([IO.File]::Exists($marker)) {
            $owner = [IO.File]::ReadAllText($marker).TrimEnd("`r", "`n")
            if ($IsWindows) {
                # Git Bash writes outside-repository paths as /c/... while
                # native PowerShell writes C:/.... Accept either existing form.
                if ($owner -match '^/([a-zA-Z])/(.*)$') { $owner = "$($Matches[1]):/$($Matches[2])" }
                return [string]::Equals($owner, $planId, [StringComparison]::OrdinalIgnoreCase)
            }
            return $owner -ceq $planId
        }
        [IO.Directory]::CreateDirectory($Directory) | Out-Null
        [IO.File]::WriteAllText($marker, "$planId`n", [Text.UTF8Encoding]::new($false))
        return $true
    }

    $directory = Join-Path $workspaceBase $slug
    if (!(Owns $directory)) {
        $parentName = Split-Path (Split-Path $planPath -Parent) -Leaf
        $directory = Join-Path $workspaceBase "$slug-$parentName"
        $counter = 2
        while (!(Owns $directory)) {
            $directory = Join-Path $workspaceBase "$slug-$parentName-$counter"
            $counter++
        }
    }
    $ignore = Join-Path $workspaceBase '.gitignore'
    if (![IO.File]::Exists($ignore)) {
        [IO.File]::WriteAllText($ignore, "*`n", [Text.UTF8Encoding]::new($false))
    }
    Write-Output $directory
    exit 0
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 2
}
