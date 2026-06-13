---
name: feishu-miaoxiangwendang
description: Refresh and mirror the official Miaoxiang / Qishui Music Feishu Wiki knowledge base into a local Markdown knowledge base. Use when the user asks to read, update, refresh, compare, or rebuild Miaoxiang official Feishu documents, follow Wiki jump links, check whether the local Miaoxiang knowledge base is current, or prepare source material for ai-miaoxiang-music.
---

# Feishu Miaoxiang W档

Use this skill as the source-refresh layer for Miaoxiang. It reads the official Feishu/Lark Wiki, follows reachable Wiki links and Wiki cite blocks, and writes a local snapshot. It is not the creative assistant; use `ai-miaoxiang-music` for song creation, prompt writing, lyrics, revision, publishing, and operation advice.

## Default Source

Default official entry:

```text
https://bytedance.larkoffice.com/wiki/HRANwGsgpiCGwhkXcwBcDDNdn3e
```

Known alternate entry from the same menu:

```text
https://bytedance.larkoffice.com/wiki/AaL9w540YiK4FjkoNX7cLC2FnJf
```

Default local output for Liu Tao's Miaoxiang project:

```text
P:\projects-test\AI音乐\0.AI 音乐知识库\妙响\miaoxiang_lark_kb
```

## Workflow

1. Confirm the user wants a read-only local refresh, not cloud-document edits.
2. Prefer `--as user` when using `lark-cli`; Wiki and Docx pages are normally user-visible resources.
3. Run a small access test if permissions are uncertain:

```powershell
lark-cli docs +fetch --api-version v2 --doc "https://bytedance.larkoffice.com/wiki/HRANwGsgpiCGwhkXcwBcDDNdn3e" --scope outline --as user --format json
```

4. Run the bundled crawler from the project folder:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\.codex\skills\feishu-miaoxiangwendang\scripts\crawl-feishu-miaoxiangwendang.ps1" `
  -OutRoot "miaoxiang_lark_kb"
```

Use `-RootUrl`, `-AltUrls`, or `-MaxDocs` only when overriding defaults.

5. Review generated files:
   - `raw_docs/`: one Markdown file per fetched Wiki token.
   - `README.md`: generated index and counts.
   - `documents.csv`: token, title, revision, file path, content length.
   - `links.csv`: internal Wiki link graph.
   - `external_links.csv`: non-Wiki URLs found in content; recorded, not crawled.
   - `failures.csv`: broken, deleted, or inaccessible tokens.

6. If the local knowledge base will be used for creation, update or create `使用导览.md` in the output folder. Keep it concise and organize by use case: product workflow, prompt/style library, lyrics, AI singers, music adaptation, publishing, operation, FAQ, and learning material.

## Boundaries

- Do not write to or modify official cloud documents unless the user explicitly asks.
- Do not delete old local mirrors without explicit confirmation.
- Treat images, videos, files, and whiteboards as references unless the user explicitly asks to download media.
- Treat external URLs as references; this crawler only recursively fetches Wiki pages.
- If a token is deleted or inaccessible, record it in `failures.csv` and report it as a source boundary.
- For latest activities, audit, revenue, platform rules, or review policies, refresh this source before answering.

