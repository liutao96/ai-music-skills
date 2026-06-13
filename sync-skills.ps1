param(
  [ValidateSet('status', 'pull-from-codex', 'install-to-codex')]
  [string]$Mode = 'status',

  [string[]]$SkillNames = @(
    'feishu-miaoxiangwendang',
    'ai-miaoxiang-music',
    'ai-miaoxiang-daoshi',
    'ai-suno-music'
  ),

  [string]$CodexSkillsRoot = (Join-Path $env:USERPROFILE '.codex\skills'),

  [string]$ProjectSkillsRoot = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'

function Test-PathInside([string]$Child, [string]$Parent) {
  $childPath = [System.IO.Path]::GetFullPath($Child)
  $parentPath = [System.IO.Path]::GetFullPath($Parent)
  return $childPath.StartsWith($parentPath, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-SkillFiles([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return @() }
  Get-ChildItem -LiteralPath $Path -Recurse -Force -File |
    Where-Object {
      $_.FullName -notmatch '\\.git(\\|$)' -and
      $_.FullName -notmatch '\\__pycache__(\\|$)'
    } |
    Sort-Object FullName
}

function Get-SkillSignature([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return $null }
  $root = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
  $parts = foreach ($file in Get-SkillFiles $Path) {
    $relative = [System.IO.Path]::GetRelativePath($root, $file.FullName)
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
    "$relative=$hash"
  }
  if ($parts.Count -eq 0) { return 'EMPTY' }
  $bytes = [System.Text.Encoding]::UTF8.GetBytes(($parts -join "`n"))
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    return ([BitConverter]::ToString($sha.ComputeHash($bytes)) -replace '-', '')
  }
  finally {
    $sha.Dispose()
  }
}

function Copy-SkillDirectory([string]$Source, [string]$Destination, [string]$BackupRoot) {
  if (-not (Test-Path -LiteralPath $Source)) {
    throw "Source skill does not exist: $Source"
  }

  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
  New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null

  if (Test-Path -LiteralPath $Destination) {
    $backupName = '{0}-{1}' -f (Split-Path -Leaf $Destination), (Get-Date -Format 'yyyyMMdd-HHmmss')
    $backupPath = Join-Path $BackupRoot $backupName
    Move-Item -LiteralPath $Destination -Destination $backupPath
  }

  New-Item -ItemType Directory -Force -Path $Destination | Out-Null
  $sourceRoot = [System.IO.Path]::GetFullPath($Source).TrimEnd('\')

  foreach ($item in Get-ChildItem -LiteralPath $Source -Recurse -Force) {
    if ($item.FullName -match '\\.git(\\|$)' -or $item.FullName -match '\\__pycache__(\\|$)') {
      continue
    }

    $relative = [System.IO.Path]::GetRelativePath($sourceRoot, $item.FullName)
    $target = Join-Path $Destination $relative

    if ($item.PSIsContainer) {
      New-Item -ItemType Directory -Force -Path $target | Out-Null
    }
    else {
      New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
      Copy-Item -LiteralPath $item.FullName -Destination $target -Force
    }
  }
}

$projectRoot = [System.IO.Path]::GetFullPath($ProjectSkillsRoot)
$codexRoot = [System.IO.Path]::GetFullPath($CodexSkillsRoot)
$backupRoot = Join-Path $projectRoot '_backups'

foreach ($skill in $SkillNames) {
  $projectSkill = Join-Path $projectRoot $skill
  $codexSkill = Join-Path $codexRoot $skill
  $projectSig = Get-SkillSignature $projectSkill
  $codexSig = Get-SkillSignature $codexSkill

  if ($Mode -eq 'status') {
    $state = if ($null -eq $projectSig -and $null -eq $codexSig) {
      'missing-both'
    }
    elseif ($null -eq $projectSig) {
      'missing-project'
    }
    elseif ($null -eq $codexSig) {
      'missing-codex'
    }
    elseif ($projectSig -eq $codexSig) {
      'same'
    }
    else {
      'different'
    }

    [pscustomobject]@{
      skill = $skill
      state = $state
      project = $projectSkill
      codex = $codexSkill
    }
    continue
  }

  if ($Mode -eq 'pull-from-codex') {
    if (-not (Test-PathInside $projectSkill $projectRoot)) { throw "Unsafe project target: $projectSkill" }
    Copy-SkillDirectory -Source $codexSkill -Destination $projectSkill -BackupRoot $backupRoot
    Write-Host "copied codex -> project: $skill"
    continue
  }

  if ($Mode -eq 'install-to-codex') {
    if (-not (Test-PathInside $codexSkill $codexRoot)) { throw "Unsafe codex target: $codexSkill" }
    Copy-SkillDirectory -Source $projectSkill -Destination $codexSkill -BackupRoot $backupRoot
    Write-Host "installed project -> codex: $skill"
    continue
  }
}
