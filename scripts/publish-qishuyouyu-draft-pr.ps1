param(
  [string]$Reviewer = $env:QISHUYOUYU_YICONG_GITHUB,

  [string]$Title = "",

  [string]$BodyFile = "",

  [string]$BaseRef = "origin/master",

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
  Write-Host "[$Level] [$timestamp] [qishuyouyu-pr-publish] $Message"
}

function Invoke-Checked {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Command,

    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
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

function ConvertTo-BranchPart {
  param([Parameter(Mandatory = $true)][string]$Value)

  $part = $Value.Trim()
  $part = $part -replace '[~^:?*\[\]\\]+', '-'
  $part = $part -replace '\s+', '-'
  $part = $part -replace '-{2,}', '-'
  $part = $part.Trim('-', '/')

  if ([string]::IsNullOrWhiteSpace($part)) {
    throw "Branch name part is empty after normalization: $Value"
  }

  return $part
}

try {
  Get-RequiredCommand "git"
  Get-RequiredCommand "gh"

  if ([string]::IsNullOrWhiteSpace($Reviewer)) {
    throw "Reviewer is required. Pass -Reviewer '<yicong-github-username>' or set QISHUYOUYU_YICONG_GITHUB."
  }

  Invoke-Checked "git" @("rev-parse", "--is-inside-work-tree")

  $branchName = git branch --show-current
  if ([string]::IsNullOrWhiteSpace($branchName)) {
    throw "Unable to resolve current branch."
  }
  if ($branchName -eq "master") {
    throw "Do not publish a PR directly from master. Create a feature branch first."
  }
  if ($branchName -notmatch '^[^/]+/.+') {
    throw "Branch name must match '<profile-name>/<feature-slug>': $branchName"
  }

  $profileName = gh api user --jq ".name"
  if ([string]::IsNullOrWhiteSpace($profileName)) {
    throw "Unable to resolve current GitHub profile name via gh."
  }

  $expectedPrefix = ConvertTo-BranchPart $profileName
  if (-not $branchName.StartsWith("$expectedPrefix/")) {
    throw "Branch '$branchName' must start with current profile-name '$expectedPrefix/'."
  }

  $dirty = git status --short
  if ($dirty) {
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

  if ([string]::IsNullOrWhiteSpace($Title)) {
    $Title = ($branchName -replace '^[^/]+/', '').Trim()
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
    "--reviewer", $Reviewer,
    "--title", $Title
  )

  if (-not [string]::IsNullOrWhiteSpace($BodyFile)) {
    $prArgs += @("--body-file", $BodyFile)
  }

  Write-QyyLog "INFO" "Creating draft PR targeting master and requesting review from '$Reviewer'."
  Invoke-Checked "gh" $prArgs
  Write-QyyLog "INFO" "Draft PR created successfully."
} catch {
  Write-QyyLog "ERROR" $_.Exception.Message
  if ($_.ScriptStackTrace) {
    Write-QyyLog "ERROR" $_.ScriptStackTrace
  }
  exit 1
}
