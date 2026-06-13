---
name: ai-suno-music
description: Use when the user asks to create, revise, evaluate, troubleshoot, or learn about AI music workflows, Suno, lyrics, style prompts, song structure, BGM, short-video music, generated music iteration, version review, or music production prompts. The skill must adapt to the current project context instead of assuming a fixed persona or fixed project.
---

# AI Music Workflow

Use this skill for AI music work across projects. Do not assume one fixed identity such as pet music assistant. First infer the current project, then choose the smallest useful mode.

## Core Rule

Project context wins over the global skill.

Priority order:

```text
user's current request
-> current conversation context
-> project AGENTS.md
-> project music knowledge entry, if present
-> project character/content/product notes, if present
-> this global skill
-> ask one key question only if still blocked
```

If a project has its own music knowledge base, read its entry file before creating or answering. If no project context exists, use the generic references in this skill.

## Mode Selection

- **Creation mode**: User wants lyrics, Style Prompt, BGM, short-video music, a full song, or a music concept. Read `references/creation-workflow.md`.
- **Revision mode**: User has generated a result and wants changes such as shorter intro, clearer lyrics, stronger hook, different rhythm, better ending, or more consistent voice. Read `references/revision-workflow.md`.
- **Review mode**: User asks which version is better or whether something is publishable. Use the scoring rules in `references/revision-workflow.md`.
- **Learning mode**: User asks how Suno or an AI music concept works. Read `references/learning-assistant.md`.
- **Project discovery**: If project-specific context may matter, read `references/project-discovery.md`.
- **Core Suno reference**: For general prompt, lyrics, structure, and risk boundaries, read `references/suno-core.md`.

## Default Behavior

For creation tasks:

1. Calibrate the real target: full song, short-video hook, BGM, product background music, learning demo, or revision.
2. Use existing project context when possible. Do not force the user to repeat event, role, brand, product, or content rules if they are already in the project.
3. If context is insufficient but safe to proceed, make a reasonable minimal version and state the assumption.
4. Output copy-ready fields: `Style Prompt`, `Lyrics`, and the next generation or editing step.
5. Avoid imitating specific artists, songs, melodies, or protected works.

For learning tasks:

1. Answer in plain Chinese by default.
2. Explain the idea first, then give the practical workflow.
3. If the answer depends on current platform rules, say it must be checked against the latest official page.

For revision tasks:

1. Diagnose what changed: prompt, lyrics, structure, voice, arrangement, or post-processing.
2. Preserve what works. Do not rewrite everything unless the direction is wrong.
3. Return a revised copy-ready version and a short reason for each change.

## Project-Specific Data

Do not copy project-specific knowledge into this global skill. When a project provides a local knowledge base, treat it as the source of truth for that project.

Common local entry filenames:

```text
AGENTS.md
00_Suno音乐创作知识库/README_调用入口.md
00_Suno音乐创作知识库/外部飞书资料知识库_*/README_知识库入口.md
Suno音乐创作知识库/README_调用入口.md
音乐知识库/README.md
```

If local rules exclude a source, such as low-quality transcripts or English bilingual courses, respect that exclusion.

If the current project is `P:\projects-test\7.AI 音乐教程`, treat the local `00_Suno音乐创作知识库` entry as the source of truth. Use its external Feishu knowledge base as supporting material: `超级音乐小白的流量进阶指南` for content pipeline, publishing, and review workflow; `suno生成AI音乐进阶提示词 开源公开` for advanced Suno prompt roles, song blueprints, structure tags, and lyric diagnosis.

## User-Learned Best Practices & Constraints

> **Auto-Generated Section**: This section is maintained by `skill-evolution-manager`. Do not edit manually.

### User Preferences
- When the user asks to save or build a reusable Suno/AI music knowledge base, proactively decide whether the existing ai-suno-music skill should be updated to route to that knowledge base; do not wait for the user to ask if the benefit is clear and low risk.
- For Liu Tao, reusable project knowledge should not remain only as local documents when it is intended for future invocation; connect it to the relevant skill as an entry/routing rule whenever appropriate.
- Whenever a Skill is updated for Liu Tao, do not leave the change only on the local machine. Check whether the Skill folder is a Git repository with a GitHub remote, then commit and push the Skill update when the user has requested or confirmed this behavior.

### Known Fixes & Workarounds
- After creating a project-specific external knowledge base under 00_Suno音乐创作知识库, update ai-suno-music project discovery references or explicitly explain why no skill update is needed.
- Avoid copying large source documents into a skill; store only concise routing instructions in SKILL.md/references and keep the full material in the project knowledge base.
- After modifying ai-suno-music or any other reusable Skill, run validation, inspect git status, commit the relevant Skill files, and push to the configured GitHub remote unless there is no remote or the user explicitly says not to push.

### Custom Instruction Injection

Before closing any Skill update task, ask internally: has this Skill change been validated and uploaded to GitHub? If not, either push it or clearly report the blocker.