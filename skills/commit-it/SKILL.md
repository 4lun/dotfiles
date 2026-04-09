---
name: commit-it
description: Take the current uncommitted changes and make logically grouped commits. Considers amending existing branch commits where appropriate.
allowed-tools: Read, Grep, Glob, Bash(git *)
---

# Commit It

Please take the current uncommitted changes, and make logically grouped commits.
Consider if it makes sense to amend or fixup existing commits in this branch, rather than stacking additional ones for each change.

If we're on the main branch, please stop and ask for confirmation that we really want to commit directly to main, rather than creating a new branch and making a pull request.

BTW don't offer to push to remote or generate PRs, focus on just making the commits locally.
