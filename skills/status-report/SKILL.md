---
name: status-report
description: Analyse the current branch against main and generate a status report summarising what's been done, the likely plan, and whether it looks complete.
allowed-tools: Read, Grep, Glob, Bash(git *)
---

# Status Report

Generate a status report for the current branch by comparing it against the main branch.

## Instructions

1. **Identify the base branch**: Use `main` as the base unless the user specifies otherwise.

2. **Gather context**:
   - Run `git diff main...HEAD --stat` to see all changed files
   - Run `git log main..HEAD --oneline` to see all commits on this branch
   - Run `git diff main...HEAD` to read the actual changes (use `--no-color`)
   - Run `git status` to see uncommitted/staged changes
   - Read key changed files to understand the nature of the work

3. **Analyse and report** on the following:

   ### What's been done
   - Summarise the changes made so far, grouped logically (not file-by-file)
   - Note the scope: is this a feature, refactor, bugfix, etc.?

   ### What the plan appears to be
   - Infer the overall goal from the changes, branch name, and commit messages
   - Describe the intended end-state

   ### Completeness assessment
   - Does the work look complete or in-progress?
   - Look for signs of incomplete work:
     - TODOs or placeholder code
     - Commented-out code that looks transitional
     - Tests that are skipped or incomplete
     - Missing test coverage for new functionality
     - Inconsistencies between related changes (e.g. backend done but frontend missing)
     - Files that were changed but seem half-done
   - If incomplete, list what remaining work might be needed

4. **Format** the report clearly with the three sections above. Keep it concise but thorough. Use bullet points.
