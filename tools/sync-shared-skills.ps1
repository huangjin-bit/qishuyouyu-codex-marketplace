Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$sharedSkills = Join-Path $root "shared\skills"
$codexSkills = Join-Path $root "plugins\qishuyouyu-plugin\skills"
$copilotSkills = Join-Path $root ".github\skills"
$codexScripts = Join-Path $root "plugins\qishuyouyu-plugin\scripts"
$sharedPrScripts = Join-Path $sharedSkills "qishuyouyu-pr\scripts"

function Get-FullPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return [System.IO.Path]::GetFullPath($Path)
}

function Assert-UnderRoot {
  param([Parameter(Mandatory = $true)][string]$Path)

  $fullRoot = Get-FullPath $root
  $fullPath = Get-FullPath $Path
  if (-not $fullPath.StartsWith($fullRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to touch path outside repository: $fullPath"
  }
}

function Sync-SkillDirectory {
  param([Parameter(Mandatory = $true)][string]$Target)

  Assert-UnderRoot $Target

  if (-not (Test-Path -LiteralPath $sharedSkills)) {
    throw "Missing shared skills directory: $sharedSkills"
  }

  if (Test-Path -LiteralPath $Target) {
    Remove-Item -LiteralPath $Target -Recurse -Force
  }
  New-Item -ItemType Directory -Path $Target | Out-Null

  Get-ChildItem -LiteralPath $sharedSkills -Directory | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $Target $_.Name) -Recurse
  }
}

Sync-SkillDirectory $codexSkills
Sync-SkillDirectory $copilotSkills

if (Test-Path -LiteralPath $sharedPrScripts) {
  Assert-UnderRoot $codexScripts
  if (Test-Path -LiteralPath $codexScripts) {
    Remove-Item -LiteralPath $codexScripts -Recurse -Force
  }
  New-Item -ItemType Directory -Path $codexScripts | Out-Null
  Get-ChildItem -LiteralPath $sharedPrScripts | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $codexScripts $_.Name) -Recurse
  }
}

Write-Host "Shared skills synced to Codex and GitHub Copilot outputs."
