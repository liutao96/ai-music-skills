param(
  [ValidateSet('menu', 'status', 'pull-from-codex', 'install-to-codex', 'commit', 'push', 'pull-github', 'setup-github', 'install-gh', 'backup-and-push', 'pull-and-install')]
  [string]$Mode = 'menu',

  [string]$RepoFullName = 'liutao96/ai-music-skills',

  [string]$Branch = 'master'
)

$ErrorActionPreference = 'Stop'

$RepoRoot = $PSScriptRoot
$SyncScript = Join-Path $RepoRoot 'sync-skills.ps1'

function Pause-IfInteractive {
  if ($Mode -eq 'menu') {
    Write-Host ''
    Read-Host '按回车键退出'
  }
}

function Invoke-InRepo([scriptblock]$Block) {
  Push-Location $RepoRoot
  try { & $Block }
  finally { Pop-Location }
}

function Test-CommandExists([string]$Name) {
  $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-Status {
  Write-Host '== Codex 运行目录 vs 项目随身目录 =='
  & pwsh -NoProfile -ExecutionPolicy Bypass -File $SyncScript -Mode status | Format-Table -AutoSize
  Write-Host ''
  Write-Host '== 项目 skills Git 状态 =='
  Invoke-InRepo { git status --short --branch; git remote -v }
}

function Invoke-PullFromCodex {
  & pwsh -NoProfile -ExecutionPolicy Bypass -File $SyncScript -Mode pull-from-codex
  Invoke-InRepo {
    git add .
    $changes = git status --short
    if ($changes) {
      git commit -m "Sync skills from Codex runtime"
    }
    else {
      Write-Host '没有需要提交的变化。'
    }
  }
}

function Invoke-BackupAndPush {
  Invoke-PullFromCodex
  Invoke-Push
}

function Invoke-InstallToCodex {
  & pwsh -NoProfile -ExecutionPolicy Bypass -File $SyncScript -Mode install-to-codex
}

function Invoke-Commit {
  Invoke-InRepo {
    git add .
    $changes = git status --short
    if (-not $changes) {
      Write-Host '没有需要提交的变化。'
      return
    }
    git commit -m "Update portable skills mirror"
  }
}

function Invoke-Push {
  Invoke-InRepo {
    git remote get-url origin | Out-Null
    git push -u origin $Branch
  }
}

function Invoke-PullGithub {
  Invoke-InRepo {
    git pull --ff-only origin $Branch
  }
}

function Invoke-PullAndInstall {
  Invoke-PullGithub
  Invoke-InstallToCodex
}

function Invoke-InstallGh {
  if (Test-CommandExists gh) {
    gh --version
    return
  }
  if (-not (Test-CommandExists winget)) {
    throw '未找到 winget，无法自动安装 GitHub CLI。请手动安装 gh。'
  }
  winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements
}

function Invoke-SetupGithub {
  if (-not (Test-CommandExists gh)) {
    Write-Host '未检测到 GitHub CLI，先尝试安装。'
    Invoke-InstallGh
  }

  if (-not (Test-CommandExists gh)) {
    throw 'GitHub CLI 仍不可用。请重新打开 PowerShell 或重启 Codex 后再试。'
  }

  gh auth status
  if ($LASTEXITCODE -ne 0) {
    Write-Host '需要登录 GitHub。浏览器授权完成后再继续。'
    gh auth login -h github.com -p https -w
  }

  Invoke-InRepo {
    $remoteUrl = "https://github.com/$RepoFullName.git"
    $existingRemote = git remote
    if ($existingRemote -contains 'origin') {
      git remote set-url origin $remoteUrl
    }
    else {
      git remote add origin $remoteUrl
    }

    gh repo view $RepoFullName | Out-Null
    if ($LASTEXITCODE -ne 0) {
      gh repo create $RepoFullName --private --source . --remote origin --push
    }
    else {
      git push -u origin $Branch
    }
  }
}

function Show-Menu {
  while ($true) {
    Clear-Host
    Write-Host 'Skill 同步管理'
    Write-Host '================'
    Write-Host '1. 检查同步状态'
    Write-Host '2. 从 Codex 运行目录备份到项目，并自动提交'
    Write-Host '3. 从项目安装到 Codex 运行目录'
    Write-Host '4. 提交项目 skills 变化'
    Write-Host '5. 推送到 GitHub'
    Write-Host '6. 从 GitHub 拉取'
    Write-Host '7. 首次设置/创建 GitHub 仓库'
    Write-Host '8. 安装 GitHub CLI'
    Write-Host '9. 一键备份到项目并推送 GitHub'
    Write-Host '10. 一键从 GitHub 更新并安装到 Codex'
    Write-Host '0. 退出'
    Write-Host ''
    $choice = Read-Host '请选择'

    try {
      switch ($choice) {
        '1' { Invoke-Status }
        '2' { Invoke-PullFromCodex }
        '3' { Invoke-InstallToCodex }
        '4' { Invoke-Commit }
        '5' { Invoke-Push }
        '6' { Invoke-PullGithub }
        '7' { Invoke-SetupGithub }
        '8' { Invoke-InstallGh }
        '9' { Invoke-BackupAndPush }
        '10' { Invoke-PullAndInstall }
        '0' { return }
        default { Write-Host '无效选择。' }
      }
    }
    catch {
      Write-Host ''
      Write-Host "操作失败：$($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ''
    Read-Host '按回车键继续'
  }
}

try {
  switch ($Mode) {
    'menu' { Show-Menu }
    'status' { Invoke-Status }
    'pull-from-codex' { Invoke-PullFromCodex }
    'install-to-codex' { Invoke-InstallToCodex }
    'commit' { Invoke-Commit }
    'push' { Invoke-Push }
    'pull-github' { Invoke-PullGithub }
    'setup-github' { Invoke-SetupGithub }
    'install-gh' { Invoke-InstallGh }
    'backup-and-push' { Invoke-BackupAndPush }
    'pull-and-install' { Invoke-PullAndInstall }
  }
}
finally {
  Pause-IfInteractive
}
