param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("feature", "fix", "chore")]
  [string]$Type,

  [Parameter(Mandatory = $true)]
  [Alias("Feature")]
  [string]$Slug,

  [string]$CommitMessage = "",

  [string]$Title = "",

  [string]$Body = "",

  [string]$BodyFile = "",

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
  Write-Host "[$Level] [$timestamp] [qishuyouyu-pr] $Message"
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

function ConvertFrom-Slug {
  param([Parameter(Mandatory = $true)][string]$Value)

  $words = $Value -replace '-', ' '
  if ([string]::IsNullOrWhiteSpace($words)) {
    return "Update changes"
  }

  return (Get-Culture).TextInfo.ToTitleCase($words)
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
  Get-RequiredCommand "gh"

  Invoke-Checked "git" @("rev-parse", "--is-inside-work-tree")
  Invoke-Checked "git" @("remote", "get-url", "origin")
  Invoke-Checked "gh" @("auth", "status")

  $statusBefore = @(git status --porcelain=v1)
  if ($statusBefore.Count -eq 0) {
    throw "No working tree changes to submit."
  }

  $normalizedSlug = ConvertTo-Slug $Slug
  $branchName = "$Type/$normalizedSlug"

  git rev-parse --verify "refs/heads/$branchName" *> $null
  if ($LASTEXITCODE -eq 0) {
    throw "Branch already exists locally: $branchName"
  }

  git ls-remote --exit-code --heads origin $branchName *> $null
  if ($LASTEXITCODE -eq 0) {
    throw "Branch already exists on origin: $branchName"
  }

  Write-QyyLog "INFO" "Saving current working tree changes before switching to latest master."
  $stashOutput = git stash push --include-untracked -m "qishuyouyu-pr-submit-$branchName"
  if ($LASTEXITCODE -ne 0 -or $stashOutput -match "No local changes") {
    throw "Unable to stash current working tree changes."
  }

  Write-QyyLog "INFO" "Creating branch '$branchName' from latest origin/master."
  Invoke-Checked "git" @("fetch", "origin", "master")
  Invoke-Checked "git" @("checkout", "master")
  Invoke-Checked "git" @("pull", "--ff-only", "origin", "master")
  Invoke-Checked "git" @("checkout", "-b", $branchName)

  Write-QyyLog "INFO" "Restoring saved working tree changes onto '$branchName'."
  git stash pop --index
  if ($LASTEXITCODE -ne 0) {
    $conflicts = Get-ConflictFiles
    if ($conflicts.Count -gt 0) {
      throw "Conflicts while restoring changes: $($conflicts -join ', ')"
    }
    throw "Unable to restore stashed changes onto '$branchName'."
  }

  Invoke-Checked "git" @("add", "-A")

  $changedFiles = @(git diff --name-only --cached)
  if ($LASTEXITCODE -ne 0 -or $changedFiles.Count -eq 0) {
    throw "No staged changes found after restoring working tree changes."
  }

  $pushGuard = Join-Path $PSScriptRoot "check-qishuyouyu-push.ps1"
  if (-not (Test-Path -LiteralPath $pushGuard)) {
    throw "Missing push guard script: $pushGuard"
  }

  $guardArgs = @("-ChangedFiles") + $changedFiles
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

  if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
    $CommitMessage = ConvertFrom-Slug $normalizedSlug
  }
  if ([string]::IsNullOrWhiteSpace($Title)) {
    $Title = $CommitMessage
  }

  Write-QyyLog "INFO" "Creating commit: $CommitMessage"
  Invoke-Checked "git" @("commit", "-m", $CommitMessage)

  Write-QyyLog "INFO" "Pushing branch '$branchName'."
  Invoke-Checked "git" @("push", "-u", "origin", $branchName)

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
