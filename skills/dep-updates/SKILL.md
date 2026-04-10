---
name: dep-updates
description: Loop over project dependencies and perform version updates. Accepts a level argument (max, urgent, safe, standard) to control update scope and risk tolerance.
argument-hint: <max|urgent|safe|standard>
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git *), Bash(gh *), Bash(npm *), Bash(npx *), Bash(composer *), Bash(./vendor/*), Bash(php *), WebFetch, WebSearch, Agent
---

# Dependency Updates

Update project dependencies at the level specified by `$ARGUMENTS`.

Valid levels: `max`, `urgent`, `safe`, `standard`. If no level is provided, or the value is unrecognised, ask the user which level to use before proceeding.

---

## Level definitions

### `safe`
Update all dependencies to the latest **patch and minor** versions only. This level is designed to run unattended with minimal risk.

- Skip any update that would cross a major version boundary.
- After applying updates, run the full verification suite (see §Verification below).
- Commit the result without asking — no approval step needed.

### `standard`
Everything in `safe`, **plus**:

- Identify major version bumps that look low-effort (e.g. the changelog lists no breaking changes relevant to the project, or the breaking changes are trivial to address).
- For each candidate major bump, read the changelog or release notes (see §Changelogs). If the changes look safe, apply the update, adapt code if necessary, and include it.
- For major bumps that look risky or require significant code changes, **do not apply them** — instead list them at the end as suggested follow-up steps with a brief summary of what would be involved.
- Seek approval before committing if any major version updates were applied.

### `urgent`
Update **only** dependencies that have known security vulnerabilities.

- Use `npm audit` / `composer audit` (or equivalent) to identify vulnerable packages.
- Apply the minimum version bump that resolves each vulnerability.
- If a fix requires a major version bump, read the changelog (see §Changelogs) and flag it for approval before applying.
- After applying updates, run the full verification suite.

### `max`
Update **everything** as far as possible — patch, minor, and major.

- For every major version bump, read the changelog (see §Changelogs).
- Make required code changes to accommodate breaking changes, but **seek approval** for any change that is non-trivial (more than a simple rename, import path change, or config key update).
- After applying updates, run the full verification suite.

---

## Changelogs

For **any major version update**, reading the changelog is mandatory before applying the update.

1. Look for a `CHANGELOG.md`, `CHANGES.md`, `HISTORY.md`, or `RELEASES.md` in the package source / repository.
2. If no changelog file exists, check the GitHub releases page for the package.
3. If neither is available, search the web for breaking changes documentation (e.g. migration guides, blog posts).
4. If no information can be found at all, flag this clearly to the user and ask how to proceed.

Always summarise the relevant breaking changes when presenting a major update for approval.

---

## Verification

After applying updates, **all** of the following must pass before the work is considered done:

1. **Tests** — run the project's full test suite (e.g. `composer test`, `npm run test`).
2. **Linting** — run the project's linters (e.g. `composer lint`, `npm run lint`).
3. **Type generation / checking** — run typegen or type-check steps if the project has them (e.g. `composer typegen`).
4. **Build** — run the production build (e.g. `npm run build`).
5. **Self-review** — run `/self-review` to review all changes as a fresh PR reviewer. Address any issues it raises before proceeding.

If any step fails, diagnose and fix the issue. Fixes must not:

- Disable or skip tests.
- Change application behaviour to make tests pass.
- Remove packages that were previously in use.

…unless the user explicitly approves. If you cannot resolve a failure, stop and ask the user for guidance.

---

## Workflow

1. **Detect ecosystem** — determine which package managers are in use (`package.json` → npm/yarn/pnpm, `composer.json` → Composer, etc.).
2. **Create a working branch** — branch from the current branch (e.g. `deps/<level>-YYYY-MM-DD`).
3. **Audit** — run audit commands to understand the current state (outdated packages, vulnerabilities).
4. **Plan** — based on the level, build a list of updates to apply. Present a summary to the user before starting work (except for `safe`, which can proceed directly).
5. **Apply** — update dependencies according to the level rules. For npm, prefer updating `package.json` version specifiers and running `npm install` rather than using `npm update` so lockfile and specifiers stay in sync.
6. **Adapt code** — if breaking changes require code modifications, make them.
7. **Verify** — run the full verification suite (§Verification).
8. **Commit** — make logically grouped commits (e.g. one for safe batch updates, separate commits for each major bump that required code changes). Use conventional commit messages.
9. **Report** — summarise what was updated, what was skipped, and any recommended follow-up.

---

## Rules

- Never force-remove or downgrade a dependency to resolve an issue.
- Never modify test expectations or application logic to work around a dependency change without approval.
- Keep commits atomic: batch safe updates together, but separate major bumps that required code changes into individual commits.
- If a dependency update introduces a deprecation warning but no breakage, note it in the summary but do not block on it.
- If the project uses a lockfile, always regenerate it as part of the update.
