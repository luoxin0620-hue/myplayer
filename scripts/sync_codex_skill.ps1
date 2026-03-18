param(
    [string]$SkillName = "code-quality-coach",
    [string]$CodexHome = "$env:USERPROFILE\.codex"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot ".codex\skills\$SkillName"
$skillsRoot = Join-Path $CodexHome "skills"
$destination = Join-Path $skillsRoot $SkillName

if (-not (Test-Path $source)) {
    throw "Repository skill not found: $source"
}

if (-not (Test-Path $skillsRoot)) {
    New-Item -ItemType Directory -Path $skillsRoot | Out-Null
}

if (Test-Path $destination) {
    Remove-Item -Path $destination -Recurse -Force
}

Copy-Item -Path $source -Destination $destination -Recurse -Force

Write-Output "Synced skill '$SkillName'"
Write-Output "From: $source"
Write-Output "To:   $destination"
