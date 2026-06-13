# Miaoxiang Creation Workflow

## Mode Decision

- **Create from scratch**: produce a practical song plan, style prompt, lyrics/structure, generation path, and revision loop.
- **Revise a generated song**: diagnose whether the issue is prompt, lyrics, pronunciation, singer, arrangement, mix, or publishing packaging.
- **Miaoxiang operation**: answer from official local docs first, especially new-user flow, music adaptation, AI singers, export, and publishing.
- **Prompt/style work**: use local style prompt, genre reference, structured prompt, and song-structure documents.
- **Lyrics work**: use local lyric guide, emotional quote songs, golden-line writing, Rap guide, and structure-tag material.
- **Publishing/operation**: use local Qishui/Douyin account operation, cold-start, song promotion, and traffic documents.
- **Latest policy/activity/revenue/audit**: refresh with `feishu-miaoxiangwendang` before treating the answer as current.

## Default Assumption

The user's genre is not fixed yet. Do not force a permanent genre. For each task, infer the best current direction from:

1. target platform or use case,
2. audience/listening scene,
3. emotional hook,
4. desired vocal identity,
5. publishing goal,
6. available素材 or reference.

If this is still ambiguous, choose a minimal practical direction and state the assumption.

## Practical Creation Template

### 创作目标校准

State the intended song type in one or two lines: style, emotion, audience, and publishing scene.

### 妙响操作路径

Choose one:

- Natural language / inspiration generation.
- Professional mode with lyrics plus style prompt.
- Beat-based creation.
- Music adaptation when the user has an existing melody, vocal, or authorized clip.
- AI singer replacement when the melody works but voice identity is wrong.

### Style Prompt

Make it copy-ready. Include only useful controls:

- genre/style,
- emotion and scene,
- vocal type,
- instruments and arrangement,
- BPM or tempo range when helpful,
- mix texture,
- structure hints when needed.

Avoid protected artist imitation. Use descriptive style language instead.

### Lyrics

Prefer singable, concise, and repeatable lyrics. For Chinese short-video or Qishui publishing, prioritize:

- hook early,
- memorable line,
- clear emotional position,
- natural pronunciation,
- no over-dense metaphors unless the style needs it.

For Rap, add flow, rhyme density, breath points, and section tags when useful.

### Generate And Select

Tell the user how to judge versions:

- hook memorability,
- vocal clarity,
- lyric pronunciation,
- arrangement fit,
- first 15 seconds,
- chorus lift,
- replay value,
- publishing match.

### Edit And Optimize

Use Miaoxiang-specific options when relevant:

- edit/fade out,
- speed and pitch,
- AI singer,
- vocal enhancement,
- smart mix/master,
- music adaptation for re-singing or style reconstruction,
- export/publish to Qishui.

### Publish And Review

When publishing matters, include a lightweight loop:

- title/cover/intro angle,
- Qishui or Douyin placement,
- first data to observe,
- what to change in next version.

## Refresh Rule

If the user asks "官方现在怎么说", "最新", "活动", "审核", "收益", "规则", "入口变了吗", or asks about a feature not found in local docs, refresh the local Miaoxiang knowledge base with `feishu-miaoxiangwendang` before giving a final answer.

