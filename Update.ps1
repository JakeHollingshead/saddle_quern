[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SkillsDirectory,
    [string]$RepoUrl
)
$ErrorActionPreference = 'Stop'
if (-not $RepoUrl) { $RepoUrl = 'https://github.com/JakeHollingshead/saddle_quern.git' }
$SkillsDirectory = [IO.Path]::GetFullPath($SkillsDirectory)
if (-not (Test-Path -LiteralPath $SkillsDirectory -PathType Container)) { throw "Not a directory: $SkillsDirectory" }
$null = Get-Command git -ErrorAction Stop
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$work = Join-Path $tempRoot ('quern-update-' + [guid]::NewGuid().ToString('N'))
$names = @('quern-quick','quern-standard','quern-deep','quern-sec','quern-perform','quern-test','quern-deps')
$updated = @()
$unchanged = @()
$skipped = @()
try {
    $null = New-Item -ItemType Directory -Path $work
    $checkout = Join-Path $work 'repo'
    & git clone --depth 1 $RepoUrl $checkout
    if ($LASTEXITCODE -ne 0) { throw 'Git clone failed.' }
    foreach ($name in $names) {
        $target = Join-Path $SkillsDirectory $name
        $skill = Join-Path $target 'SKILL.md'
        if (-not (Test-Path -LiteralPath $skill -PathType Leaf)) {
            $skipped += "$name (not installed)"
            continue
        }
        $existing = [IO.File]::ReadAllText($skill)
        if ($existing -notmatch "(?m)^name: $([regex]::Escape($name))\$") {
            $skipped += "$name (SKILL.md present but does not identify itself as $name; left untouched)"
            continue
        }
        $refs = Join-Path $target 'references'
        $null = New-Item -ItemType Directory -Path $refs -Force
        $newBody = [IO.File]::ReadAllText((Join-Path $checkout "skills/$name/SKILL.md"))
        $newBody = $newBody.Replace('../../AGENTS.md','references/AGENTS.md').Replace('../../regression_testing.md','references/regression_testing.md')
        $agentsNew = [IO.File]::ReadAllText((Join-Path $checkout 'AGENTS.md'))
        $regressNew = [IO.File]::ReadAllText((Join-Path $checkout 'regression_testing.md'))
        $agentsRefPath = Join-Path $refs 'AGENTS.md'
        $regressRefPath = Join-Path $refs 'regression_testing.md'
        $changed = $false
        if ($existing -ne $newBody) { $changed = $true }
        if ((-not (Test-Path -LiteralPath $agentsRefPath)) -or ([IO.File]::ReadAllText($agentsRefPath) -ne $agentsNew)) { $changed = $true }
        if ((-not (Test-Path -LiteralPath $regressRefPath)) -or ([IO.File]::ReadAllText($regressRefPath) -ne $regressNew)) { $changed = $true }
        [IO.File]::WriteAllText($skill, $newBody, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($agentsRefPath, $agentsNew, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($regressRefPath, $regressNew, [Text.UTF8Encoding]::new($false))
        if ($changed) { $updated += $name } else { $unchanged += $name }
    }
    Write-Output ("Updated: " + $(if ($updated.Count) { $updated -join ', ' } else { 'none' }))
    Write-Output ("Unchanged: " + $(if ($unchanged.Count) { $unchanged -join ', ' } else { 'none' }))
    foreach ($s in $skipped) { Write-Output "Skipped: $s" }
} finally {
    $resolved = [IO.Path]::GetFullPath($work)
    $prefix = $tempRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if ($resolved.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase) -and
        [IO.Path]::GetFileName($resolved).StartsWith('quern-update-') -and
        (Test-Path -LiteralPath $resolved)) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
