param(
  [Parameter(Mandatory = $true)]
  [string]$Feature
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
  Write-Host "[$Level] [$timestamp] [qishuyouyu-pr-start] $Message"
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

  Invoke-Checked "git" @("rev-parse", "--is-inside-work-tree")

  $dirty = git status --short
  if ($dirty) {
    throw "Working tree is not clean. Commit, stash, or discard changes before creating a PR branch."
  }

  $profileName = gh api user --jq ".name"
  if ([string]::IsNullOrWhiteSpace($profileName)) {
    throw "Unable to resolve current GitHub profile name via gh. Set your GitHub profile name before creating the PR branch."
  }

  $profilePart = ConvertTo-BranchPart $profileName
  $featurePart = ConvertTo-BranchPart $Feature
  $branchName = "$profilePart/$featurePart"

  git rev-parse --verify "refs/heads/$branchName" *> $null
  if ($LASTEXITCODE -eq 0) {
    throw "Branch already exists: $branchName"
  }

  Write-QyyLog "INFO" "Creating branch '$branchName' from latest origin/master."
  Invoke-Checked "git" @("fetch", "origin", "master")
  Invoke-Checked "git" @("checkout", "master")
  Invoke-Checked "git" @("pull", "--ff-only", "origin", "master")
  Invoke-Checked "git" @("checkout", "-b", $branchName)

  Write-QyyLog "INFO" "Branch ready: $branchName"
  Write-QyyLog "INFO" "After committing changes, run scripts\\publish-qishuyouyu-draft-pr.ps1."
} catch {
  Write-QyyLog "ERROR" $_.Exception.Message
  if ($_.ScriptStackTrace) {
    Write-QyyLog "ERROR" $_.ScriptStackTrace
  }
  exit 1
}
