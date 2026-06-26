---
name: check-pr
description: Check the open PR for the current branch — review new feedback comments and CI status. Address actionable feedback and fix CI failures where possible, asking the user before making changes.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git *), Bash(gh *), Bash(npm *), Bash(npx *), Bash(./vendor/*)
---

# Check PR

Review the open PR for the current branch: check for new feedback and CI status, then address issues.

## Instructions

1. **Find the PR**:
   - Run `git branch --show-current` to get the current branch.
   - Run `gh pr list --head <branch> --json number,url,title,state` to find the open PR.
   - If no PR exists, tell the user and stop.

2. **Check PR feedback**:
   - Run `gh api repos/{owner}/{repo}/pulls/{number}/reviews` to get reviews.
   - Run `gh api repos/{owner}/{repo}/pulls/{number}/comments` to get inline comments.
   - Run `gh api repos/{owner}/{repo}/issues/{number}/comments` to get top-level comments.
   - Run `gh api repos/{owner}/{repo}/issues/{number}/reactions` to check for emoji reactions on the PR body (bots like Codex may 👍 the PR instead of leaving a formal review). Note: an 👀 (eyes) reaction means the bot is still reviewing - it has not finished yet. Only a 👍 (thumbsup) reaction or actual review comments count as engagement.
   - Filter to comments/reviews that arrived **after the last push**. **Do not compare ISO 8601 timestamps as strings** — GitHub returns UTC (`...Z`) but `git log %cI` returns the local-tz offset (e.g. `+01:00`), and lexical sort gives the wrong answer when the offsets differ. Convert to epoch seconds first, e.g. `HEAD_EPOCH=$(git log -1 --format=%ct HEAD)` then `gh api ... --jq "[.[] | select((.created_at // .submitted_at) | fromdateiso8601 > $HEAD_EPOCH)]"`. If unsure, show all unresolved comments.
   - Summarise any new feedback to the user.

3. **Evaluate feedback**:
   - For each piece of feedback, assess whether it's:
     - **Actionable and correct** — a valid code change is needed.
     - **A question or discussion point** — needs the user's input before acting.
     - **Incorrect or not applicable** — explain why to the user and ask how they'd like to respond.
     - **Bot/automated feedback** — evaluate the claim independently before acting on it. Bot reviewers (e.g. Codex, CodeRabbit, etc.) can hallucinate issues. Verify the claim against the actual code before suggesting changes.
   - Present your assessment and ask the user before making any changes.

4. **Check CI status**:
   - Run `gh pr checks <number>` to see CI run statuses.
   - If all checks pass, report this and move on.
   - If any checks are still running, report which ones and their current state.
   - If any checks have failed:
     - Run `gh run view <run-id> --log-failed` to get the failure output.
     - Diagnose the root cause.
     - If the fix is straightforward (lint error, test failure from this branch's changes, type error), propose the fix to the user.
     - If the failure looks unrelated to this branch (flaky test, infra issue), flag it as such.
     - Ask the user before making changes.

5. **Apply fixes** (only after user approval):
   - Make the agreed changes.
   - Run relevant tests/lints locally to verify the fix.
   - Commit with a clear message describing what was fixed and why.
   - Push to the branch.
   - If Copilot reviews this PR, re-request it so it re-reviews the new commits (GitHub doesn't auto-re-review on push). **Do not** use the REST `POST .../requested_reviewers` endpoint for this: for the Copilot bot it returns `201` but is a silent no-op (no new `review_requested` event, so no re-review). Use the GraphQL `requestReviews` mutation instead - first discover the PR node id and Copilot's bot node id, reading from reviews **and** requested reviewers so it works even when Copilot was auto-requested on push but hasn't reviewed yet (`gh api graphql -f query='{ repository(owner:"OWNER",name:"REPO"){ pullRequest(number:NUM){ id reviews(first:50){ nodes{ author{ __typename login ... on Bot{ id } } } } timelineItems(itemTypes:[REVIEW_REQUESTED_EVENT],last:50){ nodes{ ... on ReviewRequestedEvent{ requestedReviewer{ __typename ... on Bot{ login id } } } } } } } }'`; the bot id is the `id` of the `Bot` whose login is `copilot-pull-request-reviewer`, found as a review author and/or requested reviewer). Then request it, keeping the quotes around the opaque bot id (`gh api graphql -f query='mutation { requestReviews(input:{pullRequestId:"PR_NODE_ID", botIds:["COPILOT_BOT_ID"], union:true}) { pullRequest { id } } }'`). If Copilot is already a requested reviewer, DELETE it first (`gh api --method DELETE "repos/{owner}/{repo}/pulls/{number}/requested_reviewers" -f 'reviewers[]=Copilot'`; tolerate a non-2xx), confirm it's gone, then re-run the mutation so the re-add is a real state transition. Confirm a fresh `review_requested` event for Copilot appeared.
   - Resolve the addressed review threads on GitHub using the GraphQL API (`gh api graphql -f query='mutation { resolveReviewThread(input:{threadId:"THREAD_NODE_ID"}) { thread { isResolved } } }'`). Get thread IDs by querying the PR's review threads first.
   - Report the updated state.

## Notes

- Never make changes without asking the user first.
- Always verify bot/automated reviewer claims against the actual code — they frequently hallucinate.
- If there's no new feedback and CI is green, just say so — don't invent work.
- If the PR has been approved with no outstanding comments, report that clearly.
