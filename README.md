# Skills Portable Mirror

这个目录是刘涛的项目内 Skill 随身镜像，不是 Codex 的运行目录。

运行目录仍然是：

```text
C:\Users\刘涛\.codex\skills
```

本目录用于移动硬盘 / 公司电脑 / 家里电脑之间同步，避免只更新 `.codex\skills` 后另一台机器丢失更新。

## 当前镜像的 Skills

- `feishu-miaoxiangwendang`: 刷新妙响官方飞书知识库到本地 Markdown。
- `ai-miaoxiang-music`: 妙响实战出歌创作助理。
- `ai-suno-music`: 通用 AI / Suno 音乐工作流，并路由妙响任务到 `ai-miaoxiang-music`。

## 推荐用法

### 不想输命令时

直接双击：

- `同步Skill.cmd`：打开菜单，检查、备份、安装、提交、推送、首次设置都在里面。
- `一键备份到项目并提交.cmd`：把 `.codex\skills` 当前运行版本同步到项目，并自动 Git commit。
- `一键安装到Codex.cmd`：到另一台电脑后，把项目里的 skill 安装回 `.codex\skills`。
- `首次设置GitHub仓库.cmd`：安装 / 登录 GitHub CLI，并创建或推送 `liutao96/miaoxiang-skills` 仓库。
- `打开GitHub建仓库页面.cmd`：不用 GitHub CLI，直接打开网页创建 `miaoxiang-skills` 仓库。
- `一键推送到GitHub.cmd`：远端仓库创建好后，直接推送。

建议日常只记两个按钮：

1. 在常用电脑改完 skill 后，双击 `一键备份到项目并提交.cmd`。
2. 到另一台电脑后，双击 `一键安装到Codex.cmd`。

GitHub 只需要首次设置一次，之后用菜单或 `一键推送到GitHub.cmd`。

如果 `首次设置GitHub仓库.cmd` 因为 GitHub CLI 没装好失败，就双击 `打开GitHub建仓库页面.cmd`，在网页上创建仓库，然后双击 `一键推送到GitHub.cmd`。

### 命令行备用

查看两边是否一致：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\skills\sync-skills.ps1 -Mode status
```

把当前电脑 `.codex\skills` 的运行版本备份到项目：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\skills\sync-skills.ps1 -Mode pull-from-codex
```

到另一台电脑后，把项目里的版本安装回 `.codex\skills`：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\skills\sync-skills.ps1 -Mode install-to-codex
```

`install-to-codex` 会先把目标 skill 备份到 `skills\_backups`，再覆盖安装。

## 同步策略

建议把 GitHub 当主版本库，把本项目 `skills` 目录当移动硬盘随身副本，把 `.codex\skills` 当运行安装目录。

日常流程：

1. 在 Codex 里改 skill。
2. 运行 `pull-from-codex` 同步到项目目录。
3. 提交 / 推送 GitHub。
4. 到另一台电脑后拉取 GitHub 或拷贝移动硬盘。
5. 运行 `install-to-codex` 安装到那台电脑的 Codex。

## GitHub 远端设置

推荐使用一个集中仓库保存这些 Skill，例如：

```text
https://github.com/liutao96/ai-music-skills
```

如果 GitHub 仓库已经创建好，在本目录运行：

```powershell
git remote set-url origin https://github.com/liutao96/ai-music-skills.git
git push -u origin master
```

如果安装了 GitHub CLI，可以一次完成创建和推送：

```powershell
gh repo create liutao96/ai-music-skills --private --source . --remote origin --push
```

如果不用 GitHub CLI，就先在 GitHub 网页创建 `ai-music-skills` 仓库，再运行上面的 `git push`。

当前目录已经是 Git 仓库；如果移动到另一台电脑，只要 GitHub 远端存在，就可以 `git pull` / `git push`。

如果本机没有 `gh`，双击 `首次设置GitHub仓库.cmd`。如果安装 GitHub CLI 时报 `1618`，说明 Windows 正在执行另一个 MSI 安装，等几分钟或重启后再运行一次。
