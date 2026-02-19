---
name: show-time
model: claude-opus-4-6
description: Full release pipeline — commit, docs, security review, PR, Notion, CI review, and merge.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, TodoWrite, SlashCommand, mcp__github__get_me, mcp__github__create_pull_request, mcp__github__merge_pull_request, mcp__github__pull_request_read, mcp__github__update_pull_request, mcp__notion__notion-search, mcp__notion__notion-fetch, mcp__notion__notion-update-page, mcp__notion__notion-get-users, mcp__notion__notion-create-pages
---

# Show Time Skill

Orchestrate the full release pipeline: commit, update docs, security review, create PR, assign PR, link Notion ticket, wait for CI, fix failures, wait for code review, fix critical issues, and merge.

## When to Use

Use this skill when:
- User says "show time", "ship it", "release", "let's go", "launch"
- User wants to commit, create PR, and merge in one flow
- User asks for the full release pipeline
- User wants to go from code to merged PR

## Prerequisites

Before running this skill, ensure:
- All code changes are complete and working
- Lint and typecheck pass locally
- The user has a Notion ticket for this feature (will be asked if not provided)

## Core Principle: Self-Healing Pipeline

**Never stop and ask the user to fix failures. Diagnose, fix, and retry automatically.**

- Every step that can fail has a diagnose → fix → retry loop
- CI failures: read error logs → fix locally → commit → push → wait for new run
- Code review critical issues: read findings → fix code → commit → push → wait for new CI + review
- Max **3 retry cycles** per step before escalating to the user
- Only escalate when truly stuck (needs credentials, access, or a decision only a human can make)

## Pipeline Steps

### Step 1: Commit by Context

Stage and commit files grouped by their context, each with its own conventional commit message. Do NOT lump everything into one commit.

**Process:**
1. Run `git status` to see all changes (never use `-uall`)
2. Run `git diff` and `git diff --cached` to understand all changes
3. Run `git log --oneline -5` to see recent commit style
4. **Group files by context** — analyze the changes and cluster related files together. Common groupings:
   - Backend API changes (routes, services, types)
   - Frontend page/component changes
   - i18n / translation changes
   - Analytics event changes
   - Database migrations
   - Configuration / infrastructure changes
   - Documentation changes
5. For each group, stage only its files and commit with a descriptive message
6. Never stage `.env`, credentials, or large binaries

```bash
# Example: group 1 — backend
git add apps/api/src/services/foo.service.ts apps/api/src/routes/foo.routes.ts
git commit -m "$(cat <<'EOF'
feat(api): add foo service and routes
EOF
)"

# Example: group 2 — frontend
git add apps/dashboard/src/components/foo/ apps/dashboard/src/app/foo/
git commit -m "$(cat <<'EOF'
feat(dashboard): add foo page and components
EOF
)"

# Example: group 3 — i18n
git add apps/dashboard/src/lib/i18n/translations.ts
git commit -m "$(cat <<'EOF'
feat(dashboard): add foo translations
EOF
)"
```

**Commit message format:**
- `feat(<scope>): <description>` for new features
- `fix(<scope>): <description>` for bug fixes
- `refactor(<scope>): <description>` for refactoring
- `docs(<scope>): <description>` for documentation
- `chore(<scope>): <description>` for maintenance

**Grouping guidelines:**
- Prefer smaller, focused commits over large ones
- Each commit should be self-contained and make sense on its own
- If two files are tightly coupled (e.g., a service and its types), they belong in the same commit
- Migrations get their own commit
- i18n changes can be grouped with the feature they support or stand alone if they span multiple features

**If commit fails** (pre-commit hooks): read the hook output, fix the issues, re-stage, and create a NEW commit (never amend).

### Step 2: Update Documentation

Invoke the docs-update skill to update all relevant documentation.

```
/docs-update-skill
```

This handles: OpenAPI specs, ERD diagrams, FEATURES.md, i18n translations, FAQ, sidebar, and any other documentation affected by the changes.

If the docs-update skill produces changes, commit them separately:
```bash
git add <doc-files>
git commit -m "$(cat <<'EOF'
docs: update documentation for <feature>
EOF
)"
```

### Step 3: Security Review

Perform a security review of all changes before creating the PR.

**Process:**
1. Review all changed files for security vulnerabilities:
   ```bash
   git diff main --name-only
   ```

2. **Check for OWASP Top 10 issues:**
   - **Injection** — SQL injection, NoSQL injection, command injection in any user input handling
   - **Broken Authentication** — JWT misuse, session handling, credential exposure
   - **Sensitive Data Exposure** — Hardcoded secrets, API keys, tokens in code or logs
   - **XSS** — Unsanitized user input rendered in HTML/React components
   - **Broken Access Control** — Missing authorization checks, IDOR vulnerabilities
   - **Security Misconfiguration** — Permissive CORS, debug mode, default credentials
   - **CSRF** — Missing CSRF tokens on state-changing endpoints

3. **Check for common vulnerabilities:**
   - No hardcoded secrets, API keys, or credentials in code
   - No `.env` files, `credentials.json`, or sensitive files staged
   - Proper input validation on all user-facing endpoints (Zod schemas, etc.)
   - Authentication/authorization enforced on all protected routes
   - No `eval()`, `dangerouslySetInnerHTML`, or unsafe dynamic execution
   - Parameterized queries for all database operations (Prisma handles this)
   - Rate limiting on authentication endpoints
   - Proper error handling that doesn't leak stack traces or internal details

4. **Frontend-specific checks:**
   - No sensitive data stored in localStorage/sessionStorage
   - CSP headers configured for embedded content
   - External URLs validated before navigation
   - Form inputs properly sanitized

5. **Report and auto-fix:**
   - **PASS** — No security issues found, proceed to PR creation
   - **WARN** — Minor issues found, fix them and proceed
   - **FAIL** — Critical security issues found, fix them immediately

**Always fix any findings** before proceeding:
```bash
git add <fixed-files>
git commit -m "$(cat <<'EOF'
fix(security): address security review findings
EOF
)"
```

### Step 4: Create PR

Invoke the create-pr skill to run quality checks and create the pull request.

```
/create-pr-skill
```

This handles: lint, typecheck, unit tests, integration tests, migration validation, test coverage for new code, plan file management, and PR creation.

**Capture the PR number and URL** from the output — they're needed for subsequent steps.

### Step 5: Assign PR to User

After the PR is created, assign it to the authenticated GitHub user.

**Process:**
1. Get the authenticated user via `mcp__github__get_me`
2. Assign the PR using `gh`:

```bash
gh pr edit <PR_NUMBER> --add-assignee <username>
```

### Step 6: Link Notion Ticket

Connect the PR to the Notion ticket for traceability.

**Process:**

1. **Find the Notion ticket.** Ask the user for the Notion ticket URL/ID if not already known. If the user provides a URL, extract the page ID. Otherwise, search:
   ```
   mcp__notion__notion-search with the feature name
   ```

2. **Fetch the Notion page** to understand its database schema and current properties:
   ```
   mcp__notion__notion-fetch with the page URL/ID
   ```

3. **Attach the PR URL** to the Notion ticket. Look for a property that holds PR links (e.g., "PR", "Pull Request", "GitHub PR", or a URL-type property). Update it:
   ```
   mcp__notion__notion-update-page with:
     - page_id: <notion_page_id>
     - command: "update_properties"
     - properties: { "<PR property name>": "<PR URL>" }
   ```
   If no PR property exists, add the PR link to the page content instead.

4. **Assign the Notion ticket to the user.** Find the user in the workspace:
   ```
   mcp__notion__notion-get-users with user_id: "self" or query the user's name
   ```
   Then update the assignee/owner property:
   ```
   mcp__notion__notion-update-page with:
     - page_id: <notion_page_id>
     - command: "update_properties"
     - properties: { "<Assignee property>": "<user_id>" }
   ```

5. **Move the Notion ticket to Done.** Update the status property:
   ```
   mcp__notion__notion-update-page with:
     - page_id: <notion_page_id>
     - command: "update_properties"
     - properties: { "<Status property>": "Done" }
   ```

**Important:** Always fetch the page first to discover the exact property names in the database schema. Property names vary between databases (e.g., "Status" vs "State", "Assignee" vs "Owner", "PR" vs "Pull Request").

### Step 7: CI Green Loop

Wait for all CI checks to pass. If any fail, diagnose, fix, and retry.

The CI pipeline (`.github/workflows/ci.yml`) runs these jobs in order:
1. **Lint** — ESLint
2. **Typecheck** — TypeScript
3. **Build** — Turborepo
4. **Unit Tests** — Vitest with coverage
5. **Integration Tests** — Fastify + Postgres + Redis
6. **Claude Code Review** — AI-powered code review (PRs only, runs after integration tests)

**Loop (max 3 cycles):**

```
┌─ 1. Watch CI checks
│     gh pr checks <PR_NUMBER> --watch
│     (or poll every 60s: gh pr checks <PR_NUMBER>)
│
├─ 2. ALL checks pass? ──→ YES ──→ Proceed to Step 8
│
├─ 3. ANY check failed? ──→ Diagnose the failure
│     a. Identify which check failed from gh pr checks output
│     b. Get the run ID from the failed check URL
│     c. Read failure logs:
│        gh run view <RUN_ID> --log-failed 2>/dev/null | tail -100
│        (or: gh api repos/{owner}/{repo}/actions/runs/{run_id}/jobs --jq '.jobs[] | select(.conclusion == "failure") | .name + ": " + .steps[-1].name')
│
├─ 4. Fix the failure locally
│     - Lint errors → read error output, fix code style issues
│     - Typecheck errors → read type errors with file:line, fix types
│     - Build errors → read build output, fix compilation issues
│     - Unit test failures → read test output, fix failing tests
│     - Integration test failures → read migration/test errors, fix DB or test issues
│     - Claude Code Review failure → handled in Step 8 (not here)
│
├─ 5. Commit and push the fix
│     git add <fixed-files>
│     git commit -m "fix(<scope>): <description of CI fix>"
│     git push
│
└─ 6. Go back to step 1 (new CI run triggers automatically)
```

**Diagnosing CI failures — quick reference:**

| Check | Common Failures | How to Fix |
|-------|----------------|------------|
| Lint | ESLint errors | Run `pnpm lint` locally, fix errors, or `pnpm lint --fix` |
| Typecheck | TS errors | Run `pnpm typecheck` locally, fix type mismatches |
| Build | Compilation | Run `pnpm build` locally, fix import/export issues |
| Unit Tests | Test assertions | Run `pnpm test:unit` locally, update tests or fix logic |
| Integration Tests | DB migration, test assertions | Check migration files, run `pnpm test:integration` locally |

**If 3 cycles exhausted:** Report the persistent failure to the user with full error details and ask for guidance.

### Step 8: Claude Code Review Loop

Wait for the Claude Code Review, fix any critical issues, and repeat until clean.

The Claude Code Review workflow (`.github/workflows/claude-code-review.yml`) posts a structured review as a PR comment and **fails the CI check if critical issues (🔴) are found**.

**Loop (max 3 cycles):**

```
┌─ 1. Check if Claude Code Review completed
│     gh pr checks <PR_NUMBER>
│     Look for "Claude Code Review" status
│
├─ 2. Review PASSED (no critical issues)? ──→ Proceed to Step 9
│
├─ 3. Review FAILED (critical issues found)?
│     a. Read the review comment:
│        gh pr view <PR_NUMBER> --comments
│     b. Find the review comment with "🔴 Critical Issues"
│     c. Parse each critical issue: file, line, description, recommendation
│
├─ 4. Fix each critical issue
│     For each 🔴 issue:
│     a. Read the referenced file and line
│     b. Understand the issue (race condition, unsafe cast, fragile pattern, etc.)
│     c. Apply the fix following the recommendation
│     d. Verify the fix makes sense in context
│
├─ 5. Commit and push all fixes
│     git add <fixed-files>
│     git commit -m "fix(<scope>): address code review critical issues"
│     git push
│
├─ 6. Wait for CI to go green again (Step 7 loop)
│
└─ 7. Wait for new Claude Code Review → go back to step 1
```

**What counts as 🔴 Critical (must fix):**
- Race conditions and concurrency bugs
- Security vulnerabilities (injection, auth bypass, credential exposure)
- Unsafe type casts that cause runtime errors
- Data loss or corruption risks
- Fragile patterns that will break in production (e.g., reading env vars on every call)

**What does NOT block merge (🟡/🟢):**
- Performance suggestions (N+1 queries, missing caching)
- Style/formatting preferences
- Missing HTTP cache headers
- Magic numbers
- Console.log in non-critical paths

**If 3 review cycles exhausted:** Report the remaining critical issues to the user with full context and ask for guidance.

### Step 9: Merge

After all CI checks pass AND the Claude Code Review has no critical issues:

1. Merge the PR (squash and branch deletion are handled automatically by GitHub repo settings):
   ```bash
   gh pr merge <PR_NUMBER>
   ```

2. Confirm the merge was successful:
   ```bash
   gh pr view <PR_NUMBER> --json state --jq '.state'
   ```
   Should return `MERGED`.

3. If merge fails:
   - **Merge conflicts:** Pull latest main, resolve conflicts, push, wait for CI again
   - **Branch protection:** Check if required reviews are missing, report to user
   - **Failed checks:** Go back to Step 7

## Example Workflow

**User:** "Show time!"

**Assistant:**
1. Groups changes by context and creates focused commits:
   - `feat(api): add payment method CRUD service and routes`
   - `feat(dashboard): add payment methods page with list, panel, and tile components`
   - `feat(dashboard): add payment method edit form with SearchableSelect dropdowns`
   - `feat(dashboard): add payment method translations and analytics events`
   - `feat(database): add crypto emoji migration`
2. Runs docs-update skill → commits doc changes
3. Runs security review → PASS (no issues found)
4. Runs create-pr skill → quality checks pass → PR #142 created
5. Assigns PR #142 to the user
6. Links PR to Notion ticket, assigns ticket to user, moves ticket to Done
7. Waits for CI... lint fails → reads error → fixes typecheck issue → commits → pushes
8. CI passes on retry → Claude Code Review runs → finds 1 critical race condition
9. Reads review → fixes the race condition → commits → pushes
10. CI passes → new review → no critical issues → APPROVED
11. Merges PR #142
12. Reports: "PR #142 merged successfully! Notion ticket updated."

## Checklist

- [ ] Code changes committed (grouped by context, multiple commits)
- [ ] Documentation updated and committed
- [ ] Security review passed (all findings fixed)
- [ ] Quality checks pass (lint, typecheck, tests)
- [ ] PR created with proper title and description
- [ ] PR assigned to user
- [ ] Notion ticket linked with PR URL
- [ ] Notion ticket assigned to user
- [ ] Notion ticket moved to Done
- [ ] CI checks all green (auto-fixed if needed)
- [ ] Claude Code Review completed with no 🔴 critical issues (auto-fixed if needed)
- [ ] PR merged
