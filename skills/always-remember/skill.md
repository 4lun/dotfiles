---
name: always-remember
description: Add a new rule to the global AGENTS.md so it applies across all projects and future conversations.
allowed-tools: Read, Edit, Write
user-invocable: true
---

# Always Remember

The user wants to add a new global rule or preference to their dotfiles AGENTS.md.

## Instructions

1. Ask the user what principle they'd like you to always remember, if they haven't already stated it.
2. Before adding, verify:
   - The principle is **global** (applies across all projects, not specific to one codebase). If it's project-specific, tell the user it belongs in that project's `CLAUDE.md` or `AGENTS.md` instead.
   - The rule contains **nothing sensitive** (no credentials, internal URLs, names, etc.) — this repo is publicly visible on GitHub.
3. Add the new principle as a concise bullet point under the `# Always Remember` section in `AGENTS.md` at the root of this repository.
   - Keep it short and actionable — one or two sentences max.
   - Don't duplicate existing principles. If a similar one exists, update it instead.
4. Show the user what you added and confirm.
