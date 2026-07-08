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

Assert-Contains "README.md" @("Codex marketplace", "GitHub Copilot", "Kun agent", "qishuyouyu-kun-work-item")
Assert-Contains "docs/install-codex.md" @("codex plugin marketplace add", "qishuyouyu-plugin")
Assert-Contains "docs/install-copilot.md" @("gh skill install", "qishuyouyu-kun-work-item")
Assert-Contains "docs/maintenance.md" @("plugins/qishuyouyu-plugin/skills", ".github/skills", "GitHub Copilot", "VERSION")
Assert-Contains "CHANGELOG.md" @($version, "Codex marketplace", "GitHub Copilot")

Write-Host "Marketplace support OK"
