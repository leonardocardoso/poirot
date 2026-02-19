# Worktree Troubleshooting Guide

Common issues and their solutions when managing worktrees for both mobile iOS and web projects.

---

## MOBILE iOS TROUBLESHOOTING

### Issue 1: "Can't find my mobile worktree"

#### Symptoms
- User can't locate the worktree directory
- `ls trees/` doesn't show expected worktree
- Folder prefix confusion

#### Diagnosis Steps
1. Run `/list_worktrees_prompt` to see all worktrees
2. Check for folder-prefixed naming (e.g., `trees/reellette-ios-PTECH-503-...`)
3. Check actual branch name vs. expected name

#### Solutions
- Mobile worktrees include folder prefix in directory name
- Pattern: `trees/<folder>-<branch-name-without-feature-prefix>`
- Example: Branch `feature/PTECH-503-improve-search` → Directory `trees/reellette-ios-PTECH-503-improve-search`

#### What to tell the user
> Let me check your worktrees...
> [run /list_worktrees_prompt]
> I found your worktree at `trees/reellette-ios-PTECH-503-improve-search`. Mobile worktrees include the project folder name as a prefix to avoid conflicts.

---

### Issue 2: "Worktree won't open in Xcode"

#### Symptoms
- Double-clicking `.xcworkspace` or `.xcodeproj` doesn't open
- Xcode shows error when trying to open
- File not found errors

#### Diagnosis Steps
1. Verify worktree directory exists: `ls trees/<worktree-name>`
2. Check for `.xcworkspace` or `.xcodeproj` files in worktree
3. Verify Xcode is installed

#### Solutions
- Use `open` command from terminal: `cd trees/<worktree-name> && open *.xcworkspace`
- Prefer `.xcworkspace` over `.xcodeproj` if both exist (CocoaPods/SPM dependencies)
- Check file permissions if open fails

#### What to tell the user
> To open your worktree in Xcode, use this command:
> `cd trees/reellette-ios-PTECH-503-improve-search && open *.xcworkspace`
>
> Or navigate to the directory in Finder and double-click the `.xcworkspace` file.

---

### Issue 3: "Branch name doesn't match what I expected"

#### Symptoms
- Generated branch name differs from feature title
- Special characters removed or changed
- Case changed to lowercase

#### Diagnosis Steps
1. Check what feature title user provided
2. Review kebab-case conversion rules
3. Verify JIRA ticket was included correctly

#### Explanation
This is expected behavior - feature titles are converted to kebab-case:
- Lowercase conversion: "Add Dark Mode" → "add-dark-mode"
- Special characters removed: "Fix: Auth Bug!" → "fix-auth-bug"
- Spaces to hyphens: "Improve search performance" → "improve-search-performance"
- Multiple hyphens collapsed: "Fix--Auth---Bug" → "fix-auth-bug"

#### What to tell the user
> The branch name is generated automatically from your feature title using kebab-case format:
> - Feature: "Fix: User Auth Bug (iOS)"
> - Branch: `feature/PE-999-fix-user-auth-bug-ios`
>
> This ensures branch names are valid for git and consistent across the team.

---

### Issue 4: "Can't remove mobile worktree"

#### Symptoms
- `/remove_worktree_prompt` fails with "worktree not found"
- Full branch path doesn't work
- Folder prefix confusion

#### Diagnosis Steps
1. Run `/list_worktrees_prompt` to see actual branch names
2. Try with full branch path: `/remove_worktree_prompt feature/PTECH-503-improve-search`
3. Check `git worktree list` for exact branch name

#### Solutions
- Use full branch name including `feature/` prefix
- The command will find the folder-prefixed directory automatically
- Example: `/remove_worktree_prompt feature/PTECH-503-improve-search`

#### What to tell the user
> Use the full branch name when removing:
> `/remove_worktree_prompt feature/PTECH-503-improve-search`
>
> The command will automatically find the worktree at `trees/reellette-ios-PTECH-503-improve-search`.

---

### Issue 5: "Xcode shows wrong branch"

#### Symptoms
- Xcode Source Control shows different branch than expected
- Commits going to wrong branch
- Confusion about which worktree is open

#### Diagnosis Steps
1. In Xcode: Source Control → Check current branch
2. In terminal: `cd <worktree-dir> && git branch`
3. Verify you're in correct worktree directory

#### Solutions
- Each worktree is checked out to its own branch
- Ensure you opened the correct worktree in Xcode
- Close and reopen if Xcode is confused
- Use `git status` in terminal to verify branch

#### What to tell the user
> Each worktree is on its own branch. To verify:
> 1. In Xcode: Source Control → Branch
> 2. In terminal: `cd trees/<worktree-name> && git status`
>
> If Xcode shows the wrong branch, close the project and reopen the correct worktree.

---

### Issue 6: ".claude configuration not working"

#### Symptoms
- Slash commands not available in worktree
- Skills not showing up
- Settings different than main repo

#### Diagnosis Steps
1. Check if `.claude/` directory exists in worktree
2. Verify files were copied: `ls <worktree>/.claude/`
3. Check if Claude Code is running from correct directory

#### Solutions
- Verify .claude was copied during creation
- If missing, manually copy: `cp -R .claude trees/<worktree>/`
  - **Note:** Copy TO worktree root, not INTO `.claude/` (to avoid `.claude/.claude`)
- Restart Claude Code in worktree directory

#### What to tell the user
> Let me check if the .claude configuration was copied...
> [check directory]
>
> It looks like the .claude folder wasn't copied. I'll copy it now:
> `cp -R .claude trees/<worktree>/`
>
> Then restart Claude Code in the worktree directory.

---

## WEB PROJECT TROUBLESHOOTING

### Issue 7: "Services won't start"

#### Symptoms
- Worktree created but services not running
- Can't access dashboard URL
- Ports appear available but nothing responds

#### Diagnosis Steps
1. Run `/list_worktrees_prompt` to check service status
2. Check for PIDs - are processes running?
3. Try to access ports directly: `curl http://localhost:4010`
4. Check logs if available

#### Solutions
- If services stopped, restart them:
  ```bash
  cd trees/<branch-name>
  SERVER_PORT=<port> CLIENT_PORT=<port> sh scripts/start-system.sh > /dev/null 2>&1 &
  ```
- Check for port conflicts (another service using ports)
- Verify dependencies installed: check `node_modules/` exists

#### What to tell the user
> Your services aren't running. Let me restart them:
> ```bash
> cd trees/feature-auth
> SERVER_PORT=4010 CLIENT_PORT=5183 sh scripts/start-system.sh > /dev/null 2>&1 &
> ```
>
> Give it a few seconds to start, then try accessing http://localhost:5183/dashboard

---

### Issue 8: "Port conflicts"

#### Symptoms
- Error about port already in use
- Services fail to start
- Multiple worktrees on same ports
- Main repo conflicts with worktree

#### Diagnosis Steps
1. List all worktrees to see port allocation: `/list_worktrees_prompt`
2. Check what's using the ports: `lsof -i :4010 && lsof -i :5183`
3. Identify if it's another worktree or different service

#### Solutions
1. Kill processes on conflicting ports:
   ```bash
   lsof -ti :4010 | xargs kill -9
   lsof -ti :5183 | xargs kill -9
   ```
2. Use explicit port offset when creating: `/create_worktree_prompt branch-name 4`
3. Remove unused worktrees to free up ports

#### Port Allocation Reference (all in .env)

| Offset | API (PORT) | Dashboard | Postgres | Redis | Docker Compose |
|--------|------------|-----------|----------|-------|----------------|
| 0 (Main) | 4000 | 3000 | 5432 | 6379 | ignio |
| 1 | 4010 | 3010 | 5442 | 6389 | ignio-{branch} |
| 2 | 4020 | 3020 | 5452 | 6399 | ignio-{branch} |
| 3 | 4030 | 3030 | 5462 | 6409 | ignio-{branch} |

**Formula:** BASE + (offset * 10)

#### What to tell the user
> There's a port conflict. Let me show you which worktrees are using which ports:
> [run /list_worktrees_prompt]
>
> I'll create your new worktree with offset 4 to avoid conflicts:
> `/create_worktree_prompt branch-name 4`

---

### Issue 9: "Dashboard shows old data"

#### Symptoms
- Dashboard doesn't reflect current worktree
- Data from different worktree showing
- Events not appearing

#### Diagnosis Steps
1. Verify you're accessing correct port
2. Check OBSERVABILITY_SERVER_URL in client .env
3. Verify server is running on expected port

#### Solutions
- Ensure accessing correct dashboard URL for this worktree
- Each worktree has unique dashboard: http://localhost:<CLIENT_PORT>/dashboard
- Check client .env has correct OBSERVABILITY_SERVER_URL

#### What to tell the user
> Make sure you're accessing the correct dashboard for this worktree:
> - feature-auth: http://localhost:5183/dashboard
> - hotfix-bug: http://localhost:5193/dashboard
>
> Each worktree has its own isolated database and dashboard.

---

### Issue 10: "Can't create worktree - branch exists"

#### Symptoms
- Creation command fails
- Error about existing worktree
- Branch already checked out elsewhere

#### Common Causes
1. **Branch already has a worktree** - Each branch can only be checked out once
2. **Branch name conflict** - Different worktree using same branch

#### Solutions
1. Check existing worktrees: `/list_worktrees_prompt`
2. If old worktree exists, remove it first: `/remove_worktree_prompt <branch>`
3. Use different branch name if conflict
4. Verify branch isn't checked out in main repo: `git status` in main

#### What to tell the user
> The branch `feature-auth` is already checked out in another worktree.
> [show list of worktrees]
>
> Options:
> 1. Remove the existing worktree first: `/remove_worktree_prompt feature-auth`
> 2. Use a different branch name: `/create_worktree_prompt feature-auth-v2`

---

### Issue 11: "Dependencies not installing"

#### Symptoms
- Services fail to start
- Missing modules errors
- Build failures
- node_modules directory missing or incomplete

#### Diagnosis Steps
1. Check creation output for install errors
2. Verify node_modules exists: `ls trees/<branch>/apps/server/node_modules`
3. Check package manager is available: `which bun` or `which npm`

#### Solutions
1. Manually install dependencies:
   ```bash
   cd trees/<branch>/apps/server && bun install
   cd trees/<branch>/apps/client && bun install
   ```
2. Check package.json exists in both directories
3. Verify internet connection for downloading packages

#### What to tell the user
> Dependencies didn't install correctly. Let me reinstall them:
> ```bash
> cd trees/feature-auth/apps/server && bun install
> cd trees/feature-auth/apps/client && bun install
> ```
>
> Then restart the services.

---

### Issue 12: "Database issues in worktree"

#### Symptoms
- Database errors
- Data conflicts between main and worktree
- Migrations not running
- Old data appearing

#### Note
Each worktree should have isolated database configuration.

#### Check:
1. .env file in worktree has unique DB settings
2. DB_PATH points to worktree-specific file: `events.db` (relative path in server directory)
3. Database file exists: `ls trees/<branch>/apps/server/events.db`

#### Solutions
- Each worktree gets its own `events.db` file
- Verify server .env has `DB_PATH=events.db` (relative path)
- If database corrupt, delete and restart: `rm trees/<branch>/apps/server/events.db`

#### What to tell the user
> Each worktree has its own isolated database at `trees/<branch>/apps/server/events.db`.
> If you're seeing data conflicts, verify the DB_PATH in the server .env file.

---

### Issue 13: "Worktree directory exists but not listed"

#### Symptoms
- Directory in `trees/` folder
- Not showing in `/list_worktrees_prompt`
- Git doesn't recognize it

#### Likely Cause
Incomplete removal or manual deletion of worktree without removing from git.

#### Solutions
1. Check git's view: `git worktree list`
2. If orphaned directory, remove it: `rm -rf trees/<branch-name>`
3. If orphaned git entry, prune it: `git worktree prune`

#### What to tell the user
> This is an orphaned worktree. Let me clean it up:
> ```bash
> # First, prune git's worktree list
> git worktree prune
>
> # If directory still exists, remove it
> rm -rf trees/<branch-name>
> ```

---

## UNIVERSAL TROUBLESHOOTING

### Issue 14: "I don't know which worktrees I have"

#### Solution
Always start with: `/list_worktrees_prompt`

This shows:
- All worktrees (web and mobile)
- Their current status
- How to access them
- Quick action commands

#### What to tell the user
> Let me show you all your worktrees:
> [run /list_worktrees_prompt]
>
> Here's what you have:
> [summarize output with status and access info]

---

### Issue 15: "Worktree taking up too much space"

#### Symptoms
- trees/ directory is large
- Multiple old worktrees accumulating
- Disk space warnings

#### Solutions
1. Audit worktrees: `/list_worktrees_prompt`
2. Remove unused worktrees: `/remove_worktree_prompt <branch>`
3. Clean up orphaned directories
4. Regular maintenance recommended

#### What to tell the user
> Let me show you all your worktrees and we can clean up the ones you don't need:
> [run /list_worktrees_prompt]
>
> Which ones should I remove?

---

## General Debugging Approach

When user reports any issue:

### 1. Gather Information
- Run `/list_worktrees_prompt` first
- Ask which specific worktree (get exact name)
- Ask what they were trying to do
- Identify project type (mobile iOS or web)

### 2. Diagnose

**For Mobile iOS:**
- Check folder-prefixed directory name
- Verify branch name format
- Check .claude configuration
- Verify Xcode can see project files

**For Web:**
- Check service status (running/stopped)
- Verify port configuration
- Look for port conflicts
- Check .env files exist

### 3. Resolve
- Use appropriate command for project type
- Verify fix worked with `/list_worktrees_prompt`
- Explain what happened

### 4. Prevent
- Suggest best practices
- Recommend regular cleanup
- Note any configuration issues

---

## Quick Diagnostic Checklist

### For Mobile iOS:
- ✓ Does worktree directory exist with folder prefix? (`ls trees/`)
- ✓ Is git aware of it? (`git worktree list`)
- ✓ Does .claude/ directory exist in worktree?
- ✓ Can Xcode see .xcworkspace or .xcodeproj files?
- ✓ Is correct branch checked out? (`git status` in worktree)

### For Web:
- ✓ Does worktree directory exist? (`ls trees/`)
- ✓ Is git aware of it? (`git worktree list`)
- ✓ Are services running? (`/list_worktrees_prompt`)
- ✓ Are ports available? (check PORT, DASHBOARD_PORT, POSTGRES_PORT, REDIS_PORT)
- ✓ Is configuration correct? (check .env has all ports and COMPOSE_PROJECT_NAME)
- ✓ Did dependencies install? (check node_modules)

---

## Common Error Messages

### "fatal: '<branch>' is already checked out at '<path>'"
**Cause:** Branch is already used in another worktree
**Solution:** Remove existing worktree first or use different branch name

### "Port <number> already in use"
**Cause:** Another service (worktree or other) using the port
**Solution:** Kill process on port or use different port offset
**Ports to check:** PORT (API), DASHBOARD_PORT, POSTGRES_PORT, REDIS_PORT

### "Cannot find module '<package>'"
**Cause:** Dependencies not installed properly
**Solution:** Reinstall dependencies in worktree

### "No such file or directory: trees/<name>"
**Cause:** Looking for wrong worktree name (mobile: missing folder prefix)
**Solution:** Use `/list_worktrees_prompt` to see actual names

---

## When to Ask for Help

If after troubleshooting:
- Issue persists after following solutions
- Unclear what caused the problem
- Multiple worktrees affected
- Git metadata seems corrupted

Recommend:
1. Backup any important changes
2. Remove problematic worktree
3. Recreate from scratch
4. If issues persist, may need to check git repository health

---

## Prevention Tips

### For Both Project Types:
- Regular audits: Run `/list_worktrees_prompt` weekly
- Clean up merged worktrees promptly
- Don't manually edit git worktrees
- Always use slash commands for operations
- Ensure important work is pushed before removal

### For Mobile iOS:
- Remember folder-prefixed directory names
- Use descriptive feature titles
- Include JIRA tickets for organization
- Keep .claude config synced

### For Web:
- Let port offsets auto-calculate
- Remove worktrees to free ports
- Monitor service status
- Keep dependencies updated
