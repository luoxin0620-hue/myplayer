param(
  [string]$Path = "",
  [string]$Base = "",
  [switch]$Unstaged,
  [switch]$Staged,
  [int]$Context = 3
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-Git {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  $output = & git @Arguments 2>&1
  if ($LASTEXITCODE -ne 0) {
    throw "git $($Arguments -join ' ') failed.`n$($output -join [Environment]::NewLine)"
  }
  return $output
}

$insideWorkTree = (Invoke-Git @("rev-parse", "--is-inside-work-tree")).Trim()
if ($insideWorkTree -ne "true") {
  throw "Current directory is not inside a Git work tree."
}

if ($Base -ne "") {
  $mergeBase = (Invoke-Git @("merge-base", $Base, "HEAD")).Trim()
  $baseArgs = @("diff", "--unified=$Context", "$mergeBase..HEAD")
  if ($Path -ne "") {
    $baseArgs += @("--", $Path)
  }
  Invoke-Git $baseArgs
  exit 0
}

$includeUnstaged = $Unstaged.IsPresent
$includeStaged = $Staged.IsPresent
if (-not $includeUnstaged -and -not $includeStaged) {
  $includeUnstaged = $true
  $includeStaged = $true
}

$diffChunks = @()

if ($includeUnstaged) {
  $unstagedArgs = @("diff", "--unified=$Context")
  if ($Path -ne "") {
    $unstagedArgs += @("--", $Path)
  }
  $unstagedDiff = Invoke-Git $unstagedArgs
  if ($unstagedDiff) {
    $diffChunks += ,($unstagedDiff -join [Environment]::NewLine)
  }
}

if ($includeStaged) {
  $stagedArgs = @("diff", "--cached", "--unified=$Context")
  if ($Path -ne "") {
    $stagedArgs += @("--", $Path)
  }
  $stagedDiff = Invoke-Git $stagedArgs
  if ($stagedDiff) {
    $diffChunks += ,($stagedDiff -join [Environment]::NewLine)
  }
}

if ($diffChunks.Count -gt 0) {
  $diffChunks -join [Environment]::NewLine | Write-Output
}
