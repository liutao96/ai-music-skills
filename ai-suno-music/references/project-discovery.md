# Project Discovery

Use this before creation or revision when the current project may define music, content, brand, character, or product rules.

## What To Look For

Check the current workspace for:

```text
AGENTS.md
00_Suno音乐创作知识库/README_调用入口.md
00_Suno音乐创作知识库/外部飞书资料知识库_*/README_知识库入口.md
Suno音乐创作知识库/README_调用入口.md
音乐知识库/README.md
miaoxiang_lark_kb/使用导览.md
角色设定
内容策略
复盘
提示词
歌词
```

Read only the entry file first. Follow links from that entry only when needed.

For `P:\projects-test\7.AI 音乐教程`, read `00_Suno音乐创作知识库/README_调用入口.md` first. If the task involves AI music workflow, publishing, review, advanced Suno prompting, song blueprints, structure tags, or lyric diagnosis, also read `00_Suno音乐创作知识库/外部飞书资料知识库_20260603/README_知识库入口.md` and then only the relevant organized file:

- `02_整理知识库/01_超级音乐小白_项目化知识库.md` for content pipeline, first-workflow, publishing, and review.
- `02_整理知识库/02_suno生成AI音乐进阶提示词_项目化知识库.md` for advanced Suno prompt roles, complete song blueprints, director instructions, and lyric diagnosis.

For `P:\projects-test\AI音乐\0.AI 音乐知识库\妙响`, route Miaoxiang-specific creation, revision, publishing, operation, prompt, lyric, AI singer, music adaptation, Qishui Music, or Douyin Music Studio tasks to `ai-miaoxiang-music`. That skill should read `miaoxiang_lark_kb/使用导览.md` first and use the local mirror as the project source of truth before falling back to generic Suno guidance.

## How To Use Local Context

- If local context defines the project goal, use it as the default goal.
- If local context defines roles or characters, use them without asking the user to repeat them.
- If local context defines excluded sources, do not use those sources by default.
- If local context says music is secondary to video, product, or content, keep the music output subordinate.
- If external Feishu source material exists locally, treat it as a supporting reference, not as a replacement for project AGENTS.md or the main project knowledge entry.
- If no local music rules exist, fall back to the global workflow.

## When To Ask

Ask one key question only when a missing choice would materially change the result, such as:

```text
Do you want a full song or a short-video hook?
```

Do not ask for every field when a minimal useful draft can be made from context.
