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

