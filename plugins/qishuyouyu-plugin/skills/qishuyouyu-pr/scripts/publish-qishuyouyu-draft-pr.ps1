param(
  [string]$Title = "",

  [string]$Body = "",

  [string]$BodyFile = "",

  [string]$BaseRef = "origin/master",

  [switch]$AllowReadme,

  [switch]$AllowAgents
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-QyyLog {
  param(
    [Parameter(Mandatory = $true)][string]$Level,
    [Parameter(Mandatory = $true)][string]$Message
  )

  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Write-Host "[$Level] [$timestamp] [qishuyouyu-pr-publish] $Message"
}

function Invoke-Checked {
  param(
    [Parameter(Mandatory = $true)][string]$Command,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )

  Write-QyyLog "DEBUG" "$Command $($Arguments -join ' ')"
  & $Command @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed: $Command $($Arguments -join ' ')"
  }
}

function Get-RequiredCommand {
  param([Parameter(Mandatory = $true)][string]$Name)

  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Missing required command: $Name"
  }
}

function ConvertFrom-Slug {
  param([Parameter(Mandatory = $true)][string]$Value)

  $words = $Value -replace '-', ' '
  if ([string]::IsNullOrWhiteSpace($words)) {
    return "Update changes"
  }

  return (Get-Culture).TextInfo.ToTitleCase($words)
}

try {
  Get-RequiredCommand "git"
  Get-RequiredCommand "gh"

  Invoke-Checked "git" @("rev-parse", "--is-inside-work-tree")
  Invoke-Checked "git" @("remote", "get-url", "origin")
  Invoke-Checked "gh" @("auth", "status")

  $branchName = git branch --show-current
  if ([string]::IsNullOrWhiteSpace($branchName)) {
    throw "Unable to resolve current branch."
  }
  if ($branchName -eq "master") {
    throw "Do not publish a PR directly from master. Create a feature/fix/chore branch first."
  }
  if ($branchName -notmatch '^(feature|fix|chore)/[a-z0-9][a-z0-9-]*$') {
    throw "Branch name must match 'feature|fix|chore/<english-slug>': $branchName"
  }

  $dirty = @(git status --porcelain=v1)
  if ($dirty.Count -gt 0) {
    throw "Working tree is not clean. Commit or stash changes before publishing the draft PR."
  }

  Invoke-Checked "git" @("fetch", "origin", "master")

  $pushGuard = Join-Path $PSScriptRoot "check-qishuyouyu-push.ps1"
  if (-not (Test-Path -LiteralPath $pushGuard)) {
    throw "Missing push guard script: $pushGuard"
  }

  $guardArgs = @("-BaseRef", $BaseRef)
  if ($AllowReadme) {
    $guardArgs += "-AllowReadme"
  }
  if ($AllowAgents) {
    $guardArgs += "-AllowAgents"
  }

  Write-QyyLog "INFO" "Running Qishu Youyu push guard."
  & $pushGuard @guardArgs
  if ($LASTEXITCODE -ne 0) {
    throw "Qishu Youyu push guard failed."
  }

  $slugPart = ($branchName -replace '^(feature|fix|chore)/', '').Trim()
  if ([string]::IsNullOrWhiteSpace($Title)) {
    $Title = ConvertFrom-Slug $slugPart
  }

  Write-QyyLog "INFO" "Pushing branch '$branchName'."
  Invoke-Checked "git" @("push", "-u", "origin", $branchName)

  $existingPr = gh pr view --head $branchName --json url --jq ".url" 2>$null
  if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($existingPr)) {
    Write-QyyLog "INFO" "Draft PR already exists or PR found: $existingPr"
    exit 0
  }

  $prArgs = @(
    "pr", "create",
    "--draft",
    "--base", "master",
    "--head", $branchName,
    "--title", $Title
  )

  $temporaryBodyFile = ""
  if (-not [string]::IsNullOrWhiteSpace($BodyFile)) {
    $prArgs += @("--body-file", $BodyFile)
  } else {
    if ([string]::IsNullOrWhiteSpace($Body)) {
      $Body = "## Summary`n- $Title"
    }
    if ($Body -notmatch '(?m)^## Summary') {
      $Body = "## Summary`n- $Body"
    }
    $temporaryBodyFile = Join-Path ([System.IO.Path]::GetTempPath()) "qishuyouyu-pr-body-$([System.Guid]::NewGuid()).md"
    Set-Content -LiteralPath $temporaryBodyFile -Value $Body -Encoding UTF8
    $prArgs += @("--body-file", $temporaryBodyFile)
  }

  Write-QyyLog "INFO" "Creating draft PR targeting master."
  Invoke-Checked "gh" $prArgs
  Write-QyyLog "INFO" "Draft PR created successfully."

  if (-not [string]::IsNullOrWhiteSpace($temporaryBodyFile) -and (Test-Path -LiteralPath $temporaryBodyFile)) {
    Remove-Item -LiteralPath $temporaryBodyFile -Force
  }
} catch {
  Write-QyyLog "ERROR" $_.Exception.Message
  if ($_.ScriptStackTrace) {
    Write-QyyLog "ERROR" $_.ScriptStackTrace
  }
  exit 1
}
