Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
  ".github/copilot-instructions.md",
  ".github/skills/qishuyouyu-pr/SKILL.md",
  ".github/skills/qishuyouyu-dev-standards/SKILL.md",
  ".github/skills/qishuyouyu-business-context/SKILL.md",
  ".github/skills/qsyy-kun/SKILL.md",
  ".github/skills/qsyy-kun/qsyyKunCreateWorkItems.md",
  ".github/skills/qsyy-kun/qsyyKunCreateTaskItems.md",
  ".github/skills/qishuyouyu-pr/scripts/check-qishuyouyu-push.ps1",
  ".github/skills/qishuyouyu-pr/scripts/start-qishuyouyu-pr-branch.ps1",
  ".github/skills/qishuyouyu-pr/scripts/publish-qishuyouyu-draft-pr.ps1",
  "docs/install-copilot.md"
)

foreach ($file in $requiredFiles) {
  $path = Join-Path $root $file
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing Copilot support file: $file"
  }
}

function Assert-FileContains {
  param(
    [Parameter(Mandatory = $true)]
    [string]$RelativePath,

    [Parameter(Mandatory = $true)]
    [string[]]$Phrases
  )

  $path = Join-Path $root $RelativePath
  foreach ($phrase in $Phrases) {
    if (-not (Select-String -LiteralPath $path -Pattern $phrase -SimpleMatch -Quiet)) {
      throw "$RelativePath is missing required phrase: $phrase"
    }
  }
}

Assert-FileContains ".github/copilot-instructions.md" @("Copilot", "drama", "Kun", "Work Item", "Kun MCP", "TDD", "draft", "AGENTS.md", "Codex marketplace", "shared/skills")
Assert-FileContains ".github/skills/qishuyouyu-pr/SKILL.md" @("feature", "fix", "chore", "master", "draft", "Summary", "scripts")
Assert-FileContains ".github/skills/qishuyouyu-dev-standards/SKILL.md" @("try-catch", "E2E", "README", "AGENTS.md", "Playwright")
Assert-FileContains ".github/skills/qishuyouyu-business-context/SKILL.md" @("drama-react", "drama-backend", "drama-processor", "Kun", "GitHub", "Jenkins")
Assert-FileContains ".github/skills/qsyy-kun/SKILL.md" @("qsyy-kun", "qsyyKunCreateWorkItems.md", "qsyyKunCreateTaskItems.md", "Kun MCP")
Assert-FileContains ".github/skills/qsyy-kun/qsyyKunCreateWorkItems.md" @("qsyyKunCreateWorkItems", "repository", "title", "content", "Kun MCP")
Assert-FileContains ".github/skills/qsyy-kun/qsyyKunCreateTaskItems.md" @("qsyyKunCreateTaskItems", "repository", "title", "content", "Kun MCP")

if (Test-Path -LiteralPath (Join-Path $root ".github/skills/qishuyouyu-kun-work-item/SKILL.md")) {
  throw "Old Copilot Kun skill still exists."
}

$kunSkillFiles = @(
  ".github/skills/qsyy-kun/qsyyKunCreateWorkItems.md",
  ".github/skills/qsyy-kun/qsyyKunCreateTaskItems.md"
)
foreach ($kunSkillFile in $kunSkillFiles) {
  $kunSkillText = [System.IO.File]::ReadAllText((Join-Path $root $kunSkillFile), [System.Text.Encoding]::UTF8)
  foreach ($forbidden in @("backend-api", "appId", "component_id", "block_by_id", "plane_id", "TQ-Authorization")) {
    if ($kunSkillText.Contains($forbidden)) {
      throw "$kunSkillFile exposes forbidden backend detail: $forbidden"
    }
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
