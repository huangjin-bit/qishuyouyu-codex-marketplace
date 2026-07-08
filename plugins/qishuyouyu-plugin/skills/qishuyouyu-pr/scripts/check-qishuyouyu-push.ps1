param(
  [string]$BaseRef = "origin/master",

  [string[]]$ChangedFiles = @(),

  [switch]$AllowReadme,

  [switch]$AllowAgents
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-QyyLog {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Level,

    [Parameter(Mandatory = $true)]
    [string]$Message
  )

  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Write-Host "[$Level] [$timestamp] [qishuyouyu-push] $Message"
}

function Get-ChangedFiles {
  if ($ChangedFiles.Count -gt 0) {
    return $ChangedFiles
  }

  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Missing required command: git"
  }

  git rev-parse --is-inside-work-tree | Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw "Current directory is not inside a Git repository."
  }

  $files = git diff --name-only "$BaseRef...HEAD"
  if ($LASTEXITCODE -ne 0) {
    throw "Unable to calculate changed files against $BaseRef."
  }

  return $files
}

function Test-BlockedPath {
  param([Parameter(Mandatory = $true)][string]$Path)

  $normalized = ($Path -replace '\\', '/').Trim()
  if ([string]::IsNullOrWhiteSpace($normalized)) {
    return $null
  }

  if ($normalized -match '^(test|tests)/') {
    return "TDD/local test files must not be pushed. Qishu Youyu uses E2E tests for remote PR verification."
  }

  if (-not $AllowReadme -and $normalized -match '(^|/)readme(\.[^/]*)?$') {
    return "README files must not be changed unless the user explicitly requests a README update."
  }

  if (-not $AllowAgents -and $normalized -match '(^|/)agents\.md$') {
    return "AGENTS.md must not be changed unless the user explicitly requests an agent instruction update."
  }

  return $null
}

try {
  $blocked = @()
  foreach ($file in Get-ChangedFiles) {
    $reason = Test-BlockedPath $file
    if ($reason) {
      $blocked += [PSCustomObject]@{
        Path = $file
        Reason = $reason
      }
    }
  }

  if ($blocked.Count -gt 0) {
    Write-QyyLog "ERROR" "Push blocked by Qishu Youyu rules:"
    foreach ($item in $blocked) {
      Write-QyyLog "ERROR" "$($item.Path) - $($item.Reason)"
    }
    exit 1
  }

  Write-QyyLog "INFO" "Push check passed."
} catch {
  Write-QyyLog "ERROR" $_.Exception.Message
  if ($_.ScriptStackTrace) {
    Write-QyyLog "ERROR" $_.ScriptStackTrace
  }
  exit 1
}
