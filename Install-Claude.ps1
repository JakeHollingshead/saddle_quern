[CmdletBinding()]
param([string]$SkillsDirectory, [string]$RepoUrl)
$ErrorActionPreference = 'Stop'
if (-not $SkillsDirectory) { $SkillsDirectory = Join-Path $HOME '.claude/skills' }
if (-not $RepoUrl) { $RepoUrl = 'https://github.com/JakeHollingshead/saddle_quern.git' }
$SkillsDirectory = [IO.Path]::GetFullPath($SkillsDirectory)
$null = Get-Command git -ErrorAction Stop
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$work = Join-Path $tempRoot ('quern-install-' + [guid]::NewGuid().ToString('N'))
$names = @('quern-quick','quern-standard','quern-deep','quern-sec','quern-perform','quern-test','quern-deps')
try {
    $null = New-Item -ItemType Directory -Path $work
    $checkout = Join-Path $work 'repo'
    & git clone --depth 1 $RepoUrl $checkout
    if ($LASTEXITCODE -ne 0) { throw 'Git clone failed.' }
    foreach ($name in $names) {
        if (-not (Test-Path -LiteralPath (Join-Path $checkout "skills/$name/SKILL.md") -PathType Leaf)) { throw "Missing skill: $name" }
        if (Test-Path -LiteralPath (Join-Path $SkillsDirectory $name)) { throw "Already exists: $name; nothing installed." }
    }
    foreach ($doc in @('AGENTS.md','regression_testing.md')) {
        if (-not (Test-Path -LiteralPath (Join-Path $checkout $doc) -PathType Leaf)) { throw "Missing $doc" }
    }
    $null = New-Item -ItemType Directory -Path $SkillsDirectory -Force
    foreach ($name in $names) {
        $target = Join-Path $SkillsDirectory $name
        $null = New-Item -ItemType Directory -Path $target
        $refs = Join-Path $target 'references'
        $null = New-Item -ItemType Directory -Path $refs
        foreach ($doc in @('AGENTS.md','regression_testing.md')) { Copy-Item -LiteralPath (Join-Path $checkout $doc) -Destination $refs }
        $body = [IO.File]::ReadAllText((Join-Path $checkout "skills/$name/SKILL.md"))
        $body = $body.Replace('../../AGENTS.md','references/AGENTS.md').Replace('../../regression_testing.md','references/regression_testing.md')
        [IO.File]::WriteAllText((Join-Path $target 'SKILL.md'), $body, [Text.UTF8Encoding]::new($false))
        Write-Output "Installed $target"
    }
    Write-Output 'Start a new Claude Code session to discover the skills.'
} finally {
    $resolved = [IO.Path]::GetFullPath($work)
    $prefix = $tempRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if ($resolved.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase) -and
        [IO.Path]::GetFileName($resolved).StartsWith('quern-install-') -and
        (Test-Path -LiteralPath $resolved)) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
