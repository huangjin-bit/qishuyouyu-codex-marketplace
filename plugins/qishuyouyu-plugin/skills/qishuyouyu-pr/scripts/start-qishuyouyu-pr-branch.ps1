param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("feature", "fix", "chore")]
  [string]$Type,

  [Parameter(Mandatory = $true)]
  [Alias("Feature")]
  [string]$Slug
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-QyyLog {
  param(
    [Parameter(Mandatory = $true)][string]$Level,
    [Parameter(Mandatory = $true)][string]$Message
  )

  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Write-Host "[$Level] [$timestamp] [qishuyouyu-pr-start] $Message"
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

function ConvertTo-Slug {
  param([Parameter(Mandatory = $true)][string]$Value)

  $slugValue = $Value.Trim().ToLowerInvariant()
  $slugValue = $slugValue -replace '[^a-z0-9]+', '-'
  $slugValue = $slugValue -replace '-{2,}', '-'
  $slugValue = $slugValue.Trim('-')

  if ([string]::IsNullOrWhiteSpace($slugValue)) {
    throw "Branch slug is empty after normalization: $Value"
  }

  return $slugValue
}

function Get-ConflictFiles {
  $files = git diff --name-only --diff-filter=U
  if ($LASTEXITCODE -ne 0) {
    return @()
  }
  return @($files)
}

try {
  Get-RequiredCommand "git"
  Invoke-Checked "git" @("rev-parse", "--is-inside-work-tree")
  Invoke-Checked "git" @("remote", "get-url", "origin")

  $branchName = "$Type/$(ConvertTo-Slug $Slug)"
  git rev-parse --verify "refs/heads/$branchName" *> $null
  if ($LASTEXITCODE -eq 0) {
    throw "Branch already exists locally: $branchName"
  }

  git ls-remote --exit-code --heads origin $branchName *> $null
  if ($LASTEXITCODE -eq 0) {
    throw "Branch already exists on origin: $branchName"
  }

  $statusBefore = @(git status --porcelain=v1)
  $stashCreated = $false
  if ($statusBefore.Count -gt 0) {
    Write-QyyLog "INFO" "Saving current working tree changes before switching to latest master."
    $stashOutput = git stash push --include-untracked -m "qishuyouyu-pr-transfer-$branchName"
    if ($LASTEXITCODE -ne 0) {
      throw "Unable to stash current working tree changes."
    }
    $stashCreated = ($stashOutput -notmatch "No local changes")
  }

  Write-QyyLog "INFO" "Creating branch '$branchName' from latest origin/master."
  Invoke-Checked "git" @("fetch", "origin", "master")
  Invoke-Checked "git" @("checkout", "master")
  Invoke-Checked "git" @("pull", "--ff-only", "origin", "master")
  Invoke-Checked "git" @("checkout", "-b", $branchName)

  if ($stashCreated) {
    Write-QyyLog "INFO" "Restoring saved working tree changes onto '$branchName'."
    git stash pop --index
    if ($LASTEXITCODE -ne 0) {
      $conflicts = Get-ConflictFiles
      if ($conflicts.Count -gt 0) {
        throw "Conflicts while restoring changes: $($conflicts -join ', ')"
      }
      throw "Unable to restore stashed changes onto '$branchName'."
    }
  }

  Write-QyyLog "INFO" "Branch ready: $branchName"
  Write-QyyLog "INFO" "After committing changes, run scripts\publish-qishuyouyu-draft-pr.ps1."
} catch {
  Write-QyyLog "ERROR" $_.Exception.Message
  if ($_.ScriptStackTrace) {
    Write-QyyLog "ERROR" $_.ScriptStackTrace
  }
  exit 1
}
