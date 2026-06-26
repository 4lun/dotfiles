---
name: epub-it
description: Generate .epub file(s) on topic(s) relating to the current repo, ready to copy onto an e-reader. Defaults to content derived from the actual repo, with a broader explainer mode available per-invocation. If flash cards are requested, produces a flip-style flashcard epub instead of prose.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(pandoc *), Bash(mkdir *), Bash(ls *), Bash(git *), Bash(date*), Bash(basename *), Bash(open *)
---

# Epub It

Turn one or more topics relating to the current repo into `.epub` file(s), written to `~/Desktop/ePUBs/`, that the user can manually copy onto their X3 e-reader. Built with `pandoc` (required - it's the conversion engine).

## Interpreting the request

Work out four things from how the skill was invoked:

1. **Topic(s)** - what the book(s) should cover. If the user lists several distinct topics, or asks for "files" / "epubs" (plural), generate **one epub per topic** rather than cramming them together.
2. **Content mode** - defaults to **repo-derived**: read the actual repo and write the book from what's really there. Switch to **explainer** mode (general knowledge about the topic, using the repo only as light context) when the user signals it, e.g. "in general", "broadly", "an explainer on", or when the topic clearly isn't something this repo contains. When unsure which mode fits, ask one short question.
3. **Format** - defaults to **prose** (chapters and sections). Switch to **flash cards** when the user mentions "cards", "flash cards", or "flashcards".
4. **Depth** - a quick reference vs. a thorough guide. Infer from phrasing ("quick", "deep dive", "cheat sheet") and topic size.

## 1. Confirm scope

Draft a brief outline and show it to the user before writing the full content:

- **Prose**: the proposed title and a chapter/section list.
- **Flash cards**: the proposed title and roughly how many cards, plus the headings/themes they'll cover.

Get a quick thumbs-up (or skip this step if the user said "just do it" / the book is small). This avoids generating a whole book that misses the mark. For repo-derived books, do enough exploration first (README, docs, key source files via Read/Grep/Glob) that the outline reflects the real code, not a guess.

## 2. Gather content

- **Repo-derived**: ground every claim in the actual repo. Read the relevant files, summarise behaviour, quote real identifiers and paths. Don't fabricate APIs or invent structure the code doesn't have - if something's uncertain, hedge per the usual house rules.
- **Explainer**: write from general knowledge, weaving in repo specifics only where they genuinely apply.

## 3. Build the markdown source

Write the source markdown to the scratchpad directory (not the repo). Start with a YAML metadata block so pandoc builds a proper title page:

```yaml
---
title: "<Topic Title>"
author: "<repo or org name>"   # default to `basename "$(git rev-parse --show-toplevel)"`; never a tooling-provenance label
lang: en-GB
date: "<output of `date +%F`>"
---
```

### Prose layout

Use `#` for chapters and `##`/`###` for sections. Lead with a short intro, keep paragraphs tight, use lists and fenced code blocks where they help. E-ink screens are small - favour short sections.

### Flash-card layout

Each card is a question page followed by its answer page, so the user reads the question, swipes, and sees the answer. Use pandoc fenced divs - they become `<div class="...">` that the stylesheet page-breaks on:

```markdown
::: {.question}
**Q1.** First question text.
:::

::: {.answer}
**A1.** First answer text.
:::

::: {.question}
**Q2.** Second question text.
:::

::: {.answer}
**A2.** Second answer text.
:::
```

Number the cards. Keep each side to what fits a single e-ink page.

## 4. Convert to epub

Ensure the output dir exists: `mkdir -p ~/Desktop/ePUBs`.

Pick a kebab-case filename from the title (e.g. `auth-module-guide.epub`). If a file of that name already exists with different content, append the date: `<slug>-$(date +%F).epub`.

Write a small CSS file to the scratchpad and pass it with `--css`.

**Prose** - `prose.css`:

```css
body { margin: 0 1em; line-height: 1.45; }
h1, h2, h3 { line-height: 1.2; }
code, pre { font-size: 0.9em; }
pre { white-space: pre-wrap; word-wrap: break-word; }
```

```bash
pandoc <source>.md -o ~/Desktop/ePUBs/<slug>.epub \
  --toc --toc-depth=2 --epub-chapter-level=1 \
  --css prose.css
# -> ~/Desktop/ePUBs/<slug>.epub
```

**Flash cards** - `flashcard.css` (the page breaks are what create the flip):

```css
body { margin: 0 1em; line-height: 1.45; }
.question { page-break-before: always; break-before: page; font-weight: bold; font-size: 1.15em; }
.answer   { page-break-before: always; break-before: page; }
```

```bash
pandoc <cards>.md -o ~/Desktop/ePUBs/<slug>.epub --css flashcard.css
```

Default to EPUB3 (pandoc's default). If the user reports the X3 won't open a file, regenerate with `-t epub2` as a fallback.

## 5. Report

Confirm what was generated and print the **absolute path(s)** so the user can copy them to the e-reader, e.g. `/Users/clu/Desktop/ePUBs/auth-module-guide.epub`. For multiple topics, list every file. Don't attempt to transfer to the device - the user copies them across manually.

## Notes

- `pandoc` is required. If it's missing, stop and tell the user to `brew install pandoc`.
- Keep generated books honest: repo-derived content must reflect the real code, with uncertainty hedged rather than papered over.
- Source markdown and CSS are throwaway - keep them in the scratchpad, never commit them to the repo.
