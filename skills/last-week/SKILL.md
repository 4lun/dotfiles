---
name: last-week
description: Review the last week of commits on this repo using `gh` and `git log`, cross-reference with PRs, and produce a weekly changelog summary formatted for Slack.
allowed-tools: Bash(git *), Bash(gh *)
---

# Last Week

Review the last week of commits on this repo using `gh` and `git log`, cross-reference with PRs, and produce a weekly changelog summary formatted for Slack. Output as markdown so I can copy the rendered result. Format rules:

- Title: `⚔️ **Last Week In {repo name} ({date range})**` followed by a blank line, where {repo name} is determined from `gh repo view --json name -q .name`
- Group related commits/PRs under **bold** section headings by feature area
- Bullet points under each section with concise but informative descriptions
- If a commit has an associated PR, append the full GitHub PR URL in parentheses as a markdown link, e.g. `([https://...](https://...))`. If no PR, just omit the link - don't mention its absence.
- Don't use `#` headings, only **bold** for sections
- Use `-` for bullets, no sub-bullets
- Keep descriptions technical but readable - written for a team audience, not a changelog parser
- Avoid fancy dashes and apostrophes (e.g. no em-dashes like —, no curly quotes) - audience does not like to see AI hints
