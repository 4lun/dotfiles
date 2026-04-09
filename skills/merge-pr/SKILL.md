---
name: merge-pr
description: Merge the open PR for the current branch after a final sanity check, review verification, and CI confirmation. Prefers rebase merge. Flags concerns and asks the user before proceeding.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git *), Bash(gh *), Bash(npm *), Bash(npx *), Bash(./vendor/*), Skill
---

# Merge PR

Perform final checks and merge the open PR for the current branch.

## Instructions

1. **Find the PR**:
   - Run `git branch --show-current` to get the current branch.
   - Run `gh pr list --head <branch> --json number,url,title,state,mergeable,mergeStateStatus` to find the open PR.
   - If no PR exists, tell the user and stop.
   - If the PR is not mergeable (merge conflicts, blocked by branch protection), report why and stop.

2. **CI status**:
   - Run `gh pr checks <number>` to verify all checks pass.
   - If any checks are failing or still running, report this and stop — do not proceed to merge.

3. **Review verification**:
   - Run `gh api repos/{owner}/{repo}/pulls/{number}/reviews --jq '.[] | {user: .user.login, state: .state}'` to get reviews.
   - Run `gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[] | {user: .user.login}'` to get inline comment authors.
   - Run `gh api repos/{owner}/{repo}/issues/{number}/comments --jq '.[] | {user: .user.login}'` to get top-level comment authors.
   - Run `gh api repos/{owner}/{repo}/issues/{number}/reactions --jq '.[] | {user: .user.login, content: .content}'` to check for emoji reactions on the PR body (bots like Codex may 👍 the PR instead of leaving a formal review).
   - The PR counts as **reviewed** if at least one of the following is true:
     - A GitHub user (not the PR author) has left an `APPROVED` review.
     - A GitHub user (not the PR author) has left a `COMMENTED` or `CHANGES_REQUESTED` review.
     - An AI bot reviewer has engaged via reviews, comments, or emoji reactions (look for usernames containing `codex`, `copilot`, `claude`, `coderabbit`, `github-actions`, or `[bot]` suffix).
   - If the PR has **not been reviewed by anyone**, raise this as a concern to the user. Do not proceed without their explicit approval.
   - If the PR has unresolved `CHANGES_REQUESTED` reviews, raise this as a concern.

4. **Final sanity check**:
   - Invoke the `/self-review` skill to do a quick review of the changes.
   - If the self-review surfaces any significant concerns (bugs, security issues, missing edge cases), present them to the user and ask whether to proceed.
   - Minor style nits or suggestions for follow-up work should not block the merge — just mention them.

5. **Merge decision**:
   - If CI is green, the PR has been reviewed, and the self-review raises no significant concerns, proceed with high confidence. Tell the user you're merging and do it.
   - If there are any concerns (no review, unresolved feedback, self-review issues), present them clearly and ask the user whether to proceed.
   - Never merge without the user's knowledge — at minimum, state that you're merging before doing so.

6. **Merge**:
   - Prefer rebase merge: `gh pr merge <number> --rebase --delete-branch`.
   - If rebase merge fails (repo settings may disallow it), try squash: `gh pr merge <number> --squash --delete-branch`.
   - If squash also fails, try standard merge: `gh pr merge <number> --merge --delete-branch`.
   - Report the result and the merge method used.
   - After merge, switch to main and pull: `git checkout main && git pull`.

## Notes

- Never merge without verifying CI and review status.
- The self-review is a safety net, not a gate — use judgement on whether concerns are blocking.
- If the repo requires approvals via branch protection, `gh pr merge` will fail anyway — report the error clearly.
- Do not force-merge or bypass branch protection.
