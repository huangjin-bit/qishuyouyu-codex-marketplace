Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

function Assert-File {
  param([Parameter(Mandatory = $true)][string]$RelativePath)

  $path = Join-Path $root $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required file: $RelativePath"
  }
}

function Assert-Contains {
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

foreach ($file in @(
  "README.md",
  "VERSION",
  "CHANGELOG.md",
  "docs/install-codex.md",
  "docs/install-copilot.md",
  "docs/maintenance.md",
  "tools/sync-shared-skills.ps1",
  "shared/skills/qishuyouyu-business-context/SKILL.md",
  "shared/skills/qishuyouyu-dev-standards/SKILL.md",
  "shared/skills/qishuyouyu-pr/SKILL.md",
  "shared/skills/qishuyouyu-pr/scripts/check-qishuyouyu-push.ps1",
  "shared/skills/qishuyouyu-pr/scripts/create-qishuyouyu-draft-pr.ps1",
  "shared/skills/qishuyouyu-pr/scripts/publish-qishuyouyu-draft-pr.ps1",
  "shared/skills/qishuyouyu-pr/scripts/start-qishuyouyu-pr-branch.ps1",
  "shared/skills/qsyy-kun/SKILL.md",
  "shared/skills/qsyy-kun/qsyyKunCreateWorkItems.md",
  "shared/skills/qsyy-kun/qsyyKunCreateTaskItems.md",
  "plugins/qishuyouyu-plugin/scripts/check-qishuyouyu-push.ps1",
  "plugins/qishuyouyu-plugin/scripts/create-qishuyouyu-draft-pr.ps1",
  "plugins/qishuyouyu-plugin/scripts/publish-qishuyouyu-draft-pr.ps1",
  "plugins/qishuyouyu-plugin/scripts/start-qishuyouyu-pr-branch.ps1",
  ".agents/plugins/marketplace.json",
  "plugins/qishuyouyu-plugin/.codex-plugin/plugin.json",
  ".github/copilot-instructions.md"
)) {
  Assert-File $file
}

[System.IO.File]::ReadAllText((Join-Path $root ".agents/plugins/marketplace.json"), [System.Text.Encoding]::UTF8) | ConvertFrom-Json | Out-Null
[System.IO.File]::ReadAllText((Join-Path $root "plugins/qishuyouyu-plugin/.codex-plugin/plugin.json"), [System.Text.Encoding]::UTF8) | ConvertFrom-Json | Out-Null

$version = (Get-Content -LiteralPath (Join-Path $root "VERSION") -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') {
  throw "VERSION must use MAJOR.MINOR.PATCH format."
}

Assert-Contains "README.md" @("Codex marketplace", "GitHub Copilot", "Kun agent", "qsyy-kun")
Assert-Contains "plugins/qishuyouyu-plugin/.codex-plugin/plugin.json" @("Personal Codex plugin")
Assert-Contains "docs/install-codex.md" @("codex plugin marketplace add", "qishuyouyu-plugin")
Assert-Contains "docs/install-copilot.md" @("gh skill install", "qsyy-kun")
Assert-Contains "docs/maintenance.md" @("plugins/qishuyouyu-plugin/skills", ".github/skills", "GitHub Copilot", "VERSION")
Assert-Contains "CHANGELOG.md" @($version, "Codex marketplace", "GitHub Copilot")

Assert-Contains "README.md" @("shared/skills", "qsyy-kun", "qsyyKunCreateWorkItems", "qsyyKunCreateTaskItems")
Assert-Contains "docs/install-codex.md" @("qsyy-kun", "Kun MCP")
Assert-Contains "docs/install-copilot.md" @("qsyy-kun", "qsyyKunCreateWorkItems", "qsyyKunCreateTaskItems")
Assert-Contains "docs/maintenance.md" @("shared/skills", "sync-shared-skills.ps1", "Git tag")
Assert-Contains "CHANGELOG.md" @($version, "qsyy-kun", "Kun MCP")
Assert-Contains "shared/skills/qsyy-kun/SKILL.md" @("qsyy-kun", "qsyyKunCreateWorkItems.md", "qsyyKunCreateTaskItems.md", "MCP")
Assert-Contains "shared/skills/qsyy-kun/qsyyKunCreateWorkItems.md" @("qsyyKunCreateWorkItems", "repository", "title", "content", "Kun MCP")
Assert-Contains "shared/skills/qsyy-kun/qsyyKunCreateTaskItems.md" @("qsyyKunCreateTaskItems", "repository", "title", "content", "Kun MCP")
Assert-Contains "shared/skills/qishuyouyu-pr/SKILL.md" @("feature", "fix", "chore", "draft", "Summary", "git stash push")
Assert-Contains "shared/skills/qishuyouyu-pr/scripts/create-qishuyouyu-draft-pr.ps1" @("ValidateSet", "feature", "fix", "chore", "stash push", "pr", "create", "--draft")
Assert-Contains "shared/skills/qishuyouyu-pr/scripts/publish-qishuyouyu-draft-pr.ps1" @("feature|fix|chore", "--draft", "Summary")
Assert-Contains "shared/skills/qishuyouyu-business-context/SKILL.md" @("qishuyouyu-business-context", "drama-react")
Assert-Contains "shared/skills/qishuyouyu-dev-standards/SKILL.md" @("qishuyouyu-dev-standards", "TDD")
Assert-Contains "shared/skills/qsyy-kun/SKILL.md" @("qsyy-kun", "Kun MCP")

foreach ($removedPath in @(
  "plugins/qishuyouyu-plugin/skills/qishuyouyu-kun-work-item/SKILL.md",
  ".github/skills/qishuyouyu-kun-work-item/SKILL.md"
)) {
  if (Test-Path -LiteralPath (Join-Path $root $removedPath)) {
    throw "Removed skill still exists: $removedPath"
  }
}

$kunSkillFiles = @(
  "shared/skills/qsyy-kun/qsyyKunCreateWorkItems.md",
  "shared/skills/qsyy-kun/qsyyKunCreateTaskItems.md"
)
foreach ($kunSkillFile in $kunSkillFiles) {
  $kunSkillText = [System.IO.File]::ReadAllText((Join-Path $root $kunSkillFile), [System.Text.Encoding]::UTF8)
  foreach ($forbidden in @("backend-api", "appId", "component_id", "block_by_id", "plane_id", "TQ-Authorization")) {
    if ($kunSkillText.Contains($forbidden)) {
      throw "$kunSkillFile exposes forbidden backend detail: $forbidden"
    }
  }
}

Write-Host "Marketplace support OK"
