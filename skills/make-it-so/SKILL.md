---
name: make-it-so
description: End-to-end pipeline: self-review, commit, push PR, monitor for reviews and CI, then merge — all unattended.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git *), Bash(gh *), Bash(npm *), Bash(npx *), Bash(./vendor/*), Skill
---

# Make It So

Run the full pipeline from current changes to merged PR, unattended. Self-review, commit, push a PR, wait for CI and at least one AI bot review, then merge.

## Phase 1: Self-review

Review the current changes as a fresh PR reviewer:

1. Run `git diff main` (or the appropriate base branch) and `git log main..HEAD --oneline`.
2. Read changed files for context where needed.
3. Assess correctness, quality, edge cases, and security.
4. If you find **significant issues** (bugs, security problems, broken edge cases), fix them before proceeding. Minor nits — note them but carry on.

## Phase 2: Commit

1. Run `git status` and `git diff` to see uncommitted changes.
2. If on `main`/`master`, create a descriptive feature branch and switch to it.
3. Make logically grouped commits. Consider amending existing branch commits where appropriate rather than stacking fixup commits.

## Phase 3: Push & create PR

1. Push the branch to origin with `-u`. If the branch has diverged from origin (amend/rebase), use `--force-with-lease`. Never plain `--force`.
2. Draft a PR title and body:
   - **Title**: short (under 70 chars), Conventional Commits style.
   - **Body**: concise - what the change does and why. Skip headings and test plans unless genuinely needed.
   - Never use em dashes (—) in commit messages, PR titles, or PR bodies. Use regular dashes (-) or reword instead.
3. Check if a PR already exists for this branch (`gh pr list --head <branch>`). If so, update title/body only if the scope has changed; otherwise just push.
4. Create or update the PR **without asking for confirmation** — this is unattended.
5. Report the PR URL.

## Phase 4: Monitor PR (loop)

Loop until the PR is ready to merge. On each iteration check CI, reviews, and feedback.

### CI status

- Run `gh pr checks <number>`.
- Still running → wait and loop again.
- Failed → run `gh run view <run-id> --log-failed` to diagnose.
  - Straightforward fix (lint, test failure, type error from this branch) → fix the code, then **go back to Phase 1** to self-review, commit, push, and re-enter the monitor loop.
  - Unrelated failure (flaky test, infra) → report to the user and **stop**.

### Reviews and feedback

- Fetch reviews, inline comments, top-level comments, and emoji reactions on the PR body (bots like Codex may 👍 instead of formally reviewing). Note: an 👀 (eyes) reaction from a bot means it is still reviewing and has not finished - this does NOT count as engagement.
- For each piece of feedback, evaluate whether it's actionable and correct by reading the relevant code. **Always verify bot/automated reviewer claims against the actual code before acting** — they frequently hallucinate.
- If feedback is actionable and clearly correct → fix the code, then resolve the review thread on GitHub. To resolve a thread: first get the thread node ID from the PR's review threads (`gh api graphql -f query='{ repository(owner:"OWNER", name:"REPO") { pullRequest(number:NUM) { reviewThreads(first:50) { nodes { id isResolved comments(first:1) { nodes { body } } } } } } }'`), then resolve it (`gh api graphql -f query='mutation { resolveReviewThread(input:{threadId:"THREAD_NODE_ID"}) { thread { isResolved } } }'`). Then **go back to Phase 1** (self-review the fix, commit, push, and re-enter the monitor loop). This ensures every change gets the same review-commit-push cycle.
- Questions, incorrect claims, or feedback requiring judgement → report to the user and **stop**.

### Re-request Copilot after pushing new commits

GitHub does **not** auto-re-review on push, so after you push new commits (a CI fix or addressing feedback), re-request Copilot's review - otherwise the merge-readiness check waits forever for a review of the new HEAD that never comes. Only do this if Copilot reviews this PR (it appears in the PR's reviews or requested reviewers).

**Do not use the REST `POST .../requested_reviewers` endpoint to re-trigger Copilot.** For the Copilot bot it returns `201` but is a silent no-op: it creates no new `review_requested` event, so Copilot never re-reviews (this is why the web "re-request review" button otherwise has to be clicked by hand). Use the GraphQL `requestReviews` mutation instead:

1. Get the PR node id and Copilot's bot node id in one query (the bot id is repo-specific, so discover it - never hard-code it). Note the union fragment shape: `requestedReviewer` is a bare union, so `login` must sit inside `... on Bot`, not be selected directly:

   ```
   gh api graphql -f query='{ repository(owner:"OWNER", name:"REPO") { pullRequest(number:NUM) {
     id
     reviews(first:50){ nodes { author { __typename login ... on Bot { id } } } }
     timelineItems(itemTypes:[REVIEW_REQUESTED_EVENT], last:50){ nodes { ... on ReviewRequestedEvent { requestedReviewer { __typename ... on Bot { login id } } } } }
   } } }'
   ```

   `pullRequest.id` is the PR node id. The Copilot bot node id is the `id` of the `Bot` whose login is `copilot-pull-request-reviewer`; it shows up as a review author and/or a requested reviewer and both carry the same id. Querying both sources matters: a repo that auto-requests Copilot on push has it in `requestedReviewer` before any review exists. If the repo has no Copilot review enabled the query returns no such bot - skip the re-request and do not fail the loop.

2. Request the re-review with that bot id (keep the double quotes around the id - it is an opaque string like `BOT_kgDOCnlnWA`):

   ```
   gh api graphql -f query='mutation { requestReviews(input:{pullRequestId:"PR_NODE_ID", botIds:["COPILOT_BOT_ID"], union:true}) { pullRequest { id } } }'
   ```

   GraphQL can return HTTP 200 with a top-level `errors` array, so check the response carried no `errors` rather than trusting the exit code.

3. Confirm it took: re-run the step-1 query and check the newest `REVIEW_REQUESTED_EVENT` is Copilot and Copilot is back in `requested_reviewers`. If Copilot was **already** a requested reviewer (some repos auto-request on push), the `union` add likely makes no state change and won't re-trigger - in that case only, remove it first with `gh api --method DELETE "repos/<owner>/<repo>/pulls/<number>/requested_reviewers" -f 'reviewers[]=Copilot'` (tolerate a non-2xx), then **re-read** `requested_reviewers` and confirm Copilot is absent before re-running the mutation, so the absent->present transition actually fires the review. If the DELETE didn't remove it, surface that rather than assuming the re-add worked.

Only Copilot needs this nudge; Codex and other bots re-review on push on their own.

### Merge readiness check

All of the following must be true to proceed to Phase 5:

- CI is fully green (no pending, no failed checks).
- At least one AI bot has engaged with **the current HEAD commit** of the PR - via review, comment, or 👍 reaction on that commit. If you've pushed new commits since the last bot engagement (e.g. after addressing review feedback), the prior engagement does NOT carry over: wait for the bot to re-review the latest commit, or for an explicit 👍 on it. Old reviews on superseded commits don't count, even if their comments were addressed and resolved. Look for usernames containing `codex`, `copilot`, `claude`, `coderabbit`, `github-actions`, or a `[bot]` suffix. An 👀 (eyes) reaction means the bot is still working and does NOT satisfy this condition - keep waiting.
- No unresolved `CHANGES_REQUESTED` reviews.

If not all met → wait and loop again.

### Loop pacing

Use 60s intervals for wakeup scheduling (the runtime minimum). The user prefers frequent checks over waiting.

## Phase 5: Merge

1. Run a final self-review via the `/self-review` skill. If it raises significant concerns, report to the user and **stop**.
2. Merge with rebase: `gh pr merge <number> --rebase --delete-branch`.
   - If rebase fails, try squash (`--squash`), then standard merge (`--merge`).
3. Switch to main and pull: `git checkout main && git pull`.
4. Report success.

## When to stop and ask the user

This skill operates unattended but must stop and escalate when:

- A CI failure appears unrelated to this branch.
- Review feedback requires judgement or is a discussion point.
- The final self-review raises significant concerns.
- The PR cannot be merged (conflicts, branch protection).
- Something unexpected happens.

Do **not** stop for:

- Routine CI fixes caused by this branch (lint, test, type errors).
- Clearly correct, actionable review feedback.
- Creating or updating the PR.
- Merging when all conditions are met.
