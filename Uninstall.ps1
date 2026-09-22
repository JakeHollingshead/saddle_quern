[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SkillsDirectory,
    [string[]]$Name
)
$ErrorActionPreference = 'Stop'
$SkillsDirectory = [IO.Path]::GetFullPath($SkillsDirectory)
if (-not (Test-Path -LiteralPath $SkillsDirectory -PathType Container)) { throw "Not a directory: $SkillsDirectory" }
$allNames = @('quern-quick','quern-standard','quern-deep','quern-sec','quern-perform','quern-test','quern-deps')
$names = if ($Name) { $Name } else { $allNames }
$removed = @()
$skipped = @()
foreach ($n in $names) {
    $target = Join-Path $SkillsDirectory $n
    $skill = Join-Path $target 'SKILL.md'
    if (-not (Test-Path -LiteralPath $target)) {
        $skipped += "$n (not present)"
        continue
    }
    if (-not (Test-Path -LiteralPath $skill -PathType Leaf)) {
        $skipped += "$n (does not look like a saddle_quern skill; left in place)"
        continue
    }
    $body = [IO.File]::ReadAllText($skill)
    if ($body -notmatch "(?m)^name: $([regex]::Escape($n))\$") {
        $skipped += "$n (does not look like a saddle_quern skill; left in place)"
        continue
    }
    Remove-Item -LiteralPath $target -Recurse -Force
    $removed += $n
}
Write-Output ("Removed: " + $(if ($removed.Count) { $removed -join ', ' } else { 'none' }))
foreach ($s in $skipped) { Write-Output "Skipped: $s" }
