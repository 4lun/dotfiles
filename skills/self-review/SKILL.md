---
name: self-review
description: Review the current changes as a fresh PR reviewer with no prior context.
allowed-tools: Read, Grep, Glob, Bash(git *)
---

# Self Review

Review the current changes as though you were reviewing the work in isolation on a pull request, with no other context, what is your feedback?

## Instructions

1. Run `git diff main` (or the appropriate base branch) to see all changes.
2. Run `git log main..HEAD --oneline` to see the commit history.
3. Read any changed files in full where needed for context.
4. Provide your review as if you were an external reviewer seeing this PR for the first time, covering:
   - Correctness and potential bugs
   - Code quality and consistency with surrounding code
   - Missing edge cases or error handling
   - Security concerns
   - Any suggestions for improvement
