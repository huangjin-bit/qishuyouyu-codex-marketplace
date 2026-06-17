Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
  ".github/copilot-instructions.md",
  ".github/skills/qishuyouyu-pr/SKILL.md",
  ".github/skills/qishuyouyu-dev-standards/SKILL.md",
  ".github/skills/qishuyouyu-pr/scripts/check-qishuyouyu-push.ps1",
  ".github/skills/qishuyouyu-pr/scripts/start-qishuyouyu-pr-branch.ps1",
  ".github/skills/qishuyouyu-pr/scripts/publish-qishuyouyu-draft-pr.ps1"
)

foreach ($file in $requiredFiles) {
  $path = Join-Path $root $file
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing Copilot support file: $file"
  }
}

$instructions = Get-Content -LiteralPath (Join-Path $root ".github/copilot-instructions.md") -Raw
foreach ($phrase in @("Copilot", "TDD", "draft", "AGENTS.md", "Codex marketplace")) {
  if ($instructions -notmatch [regex]::Escape($phrase)) {
    throw "copilot-instructions.md is missing required phrase: $phrase"
  }
}

$prSkill = Get-Content -LiteralPath (Join-Path $root ".github/skills/qishuyouyu-pr/SKILL.md") -Raw
foreach ($phrase in @("profile-name", "master", "draft", "scripts", "QISHUYOUYU_YICONG_GITHUB")) {
  if ($prSkill -notmatch [regex]::Escape($phrase)) {
    throw "qishuyouyu-pr skill is missing required phrase: $phrase"
  }
}

$devSkill = Get-Content -LiteralPath (Join-Path $root ".github/skills/qishuyouyu-dev-standards/SKILL.md") -Raw
foreach ($phrase in @("try-catch", "E2E", "README", "AGENTS.md", "Playwright")) {
  if ($devSkill -notmatch [regex]::Escape($phrase)) {
    throw "qishuyouyu-dev-standards skill is missing required phrase: $phrase"
  }
}

$failed = $false
Get-ChildItem -LiteralPath (Join-Path $root ".github/skills/qishuyouyu-pr/scripts") -Filter "*.ps1" | ForEach-Object {
  $errors = $null
  $tokens = $null
  [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$tokens, [ref]$errors) | Out-Null
  if ($errors.Count -gt 0) {
    $failed = $true
    $errors | ForEach-Object { Write-Error "$($_.Extent.File): $($_.Message)" }
  }
}

if ($failed) {
  exit 1
}

Write-Host "Copilot support OK"
