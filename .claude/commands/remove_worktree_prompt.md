---
model: claude-opus-4-6
description: Remove a git worktree, delete its branch, and stop its running services (web projects)
argument-hint: <branch-name>
allowed-tools: Bash, Read, Glob, Grep
output-style: tts-summary
---

# Purpose

Remove an existing git worktree from the `trees/` directory AND delete the associated git branch. For web projects, this includes stopping any running services on its ports. For mobile iOS projects, this cleanly removes the worktree and branch. This ensures complete cleanup without orphaned processes or files.

## Overview

This command provides safe, complete removal of git worktrees with automatic cleanup of all associated resources.

**Key Features:**
- **Automatic project detection**: Identifies web vs mobile iOS projects
- **Service management**: Stops running server/client processes (web projects only)
- **Complete cleanup**: Removes worktree, branch, and all associated files
- **Force removal support**: Handles uncommitted changes gracefully
- **Comprehensive validation**: Confirms complete removal with detailed checks
- **Clear warnings**: Reports any issues or manual cleanup needed
- **Permanent deletion**: Both worktree AND branch are deleted (cannot be undone)

**When to use this command:**
- You've finished working on a feature branch and want to clean up
- You need to free up ports used by a web worktree
- You want to remove an experimental or abandoned branch completely
- You're cleaning up multiple old worktrees
- You need to ensure no orphaned processes or files remain

**Comparison with manual removal:**
- **This command**: Stops services → Removes worktree → Deletes branch → Validates cleanup
- **Manual removal**: Requires multiple git commands, manual process killing, easy to miss cleanup steps

**Project Type Handling:**
- **Web projects**: Stops server/client services, frees ports, removes all resources
- **Mobile iOS projects**: Simplified cleanup (no services to stop, just worktree and branch removal)

**WARNING:** This operation is PERMANENT. Both the worktree directory and the git branch will be deleted and cannot be recovered. Make sure you've committed and pushed any important changes before running this command.

## Variables

```
PROJECT_CWD: . (current working directory - the main project root)
BRANCH_NAME: $1 (required) - The branch name to remove
WORKTREE_DIR: ../${REPO_NAME}-../${REPO_NAME}-trees/<BRANCH_NAME>
REPO_NAME: basename of PROJECT_CWD
WORKTREE_NAME: For mobile, may include folder prefix (e.g., reellette-ios-PTECH-503-...)
```

## Instructions

This section provides step-by-step instructions for safely removing a git worktree. Each step includes detailed rationale and implementation guidance.

### 1. Parse and Validate Arguments

**Purpose:** Extract and validate the branch name before proceeding with removal operations.

**Steps:**
- **Read BRANCH_NAME from $1:**
  - This is the REQUIRED first argument
  - Should be the exact branch name (e.g., "feature-auth", "hotfix-security")
  - If missing, provide clear error message explaining command usage
  - Example error: "Branch name is required. Usage: /remove_worktree_prompt <branch-name>"

- **Construct WORKTREE_DIR path:**
  - Path pattern: `PROJECT_CWD/../${REPO_NAME}-trees/<BRANCH_NAME>`
  - This is the expected location of the worktree directory
  - Note: For mobile projects, actual directory may have folder prefix (e.g., `trees/reellette-ios-feature-auth`)
  - Will be validated in next step

- **Validate branch name format:**
  - Check for spaces (invalid in git branch names)
  - Check for special characters that might cause issues
  - Ensure not empty or whitespace-only
  - This prevents attempting to remove invalid branch names

**Why this matters:** Proper validation ensures we're targeting the correct worktree and prevents accidental removal of wrong branches or malformed commands.

### 2. Check Worktree Existence and Detect Project Type

**Purpose:** Verify the worktree exists and determine whether it's a web or mobile project for appropriate cleanup.

**Steps:**

**1. List all worktrees:**
- Execute: `git worktree list`
- Parse output to find matching worktree
- Check for exact match on branch name
- Store full worktree path from git output

**2. Check worktree existence:**
- Look for worktree in git worktree list
- For mobile projects: May need to check for worktree with folder prefix
  - Example: Branch `feature/PTECH-503-improve-search` might have worktree `trees/reellette-ios-PTECH-503-improve-search`
  - Use `git worktree list | grep <BRANCH_NAME>` to find it
- If not found in git worktree list:
  - Check if directory exists anyway (orphaned directory)
  - Provide instructions for `git worktree prune`
  - Error with clear message about worktree not found

**3. Detect project type:**
- Check the worktree directory for project indicators
- **iOS Mobile project indicators:**
  - Presence of `*.xcodeproj` or `*.xcworkspace` files
  - Check in worktree root: `ls <WORKTREE_DIR>/*.xcodeproj <WORKTREE_DIR>/*.xcworkspace 2>/dev/null`
- **Web project indicators:**
  - Presence of `apps/server/` and `apps/client/` directories
  - Check: `test -d <WORKTREE_DIR>/apps/server && test -d <WORKTREE_DIR>/apps/client`
- **Default:** If unclear, assume web project
- Store detected type for conditional logic in later steps

**Why this matters:**
- Ensures we're removing the correct worktree
- Determines cleanup strategy (web needs service shutdown, mobile doesn't)
- Prevents attempting to remove non-existent worktrees
- Handles edge cases like orphaned directories or git metadata

### 3. Identify Configuration (Web Projects Only)

**Purpose:** For web projects, identify the ports being used so services can be stopped before removal.

**For WEB projects:**

**1. Read server port:**
- Check if `<WORKTREE_DIR>/apps/server/.env` exists
- If exists, read SERVER_PORT value from the file
- Command: `grep SERVER_PORT <WORKTREE_DIR>/apps/server/.env | cut -d'=' -f2`
- Store port number for service shutdown

**2. Read client port:**
- Check if `<WORKTREE_DIR>/apps/client/.env` exists
- If exists, read VITE_PORT value from the file
- Command: `grep VITE_PORT <WORKTREE_DIR>/apps/client/.env | cut -d'=' -f2`
- Store port number for service shutdown

**3. Handle missing port configuration:**
- If .env files don't exist, try to infer ports:
  - Count position of this worktree among all worktrees
  - Estimate offset based on position (1st worktree = offset 1, 2nd = offset 2, etc.)
  - Calculate ports: SERVER_PORT = 4000 + (offset * 10), CLIENT_PORT = 5173 + (offset * 10)
  - Note: This is best-effort if .env files are missing
  - Include warning in report that ports were estimated

**For MOBILE iOS projects:**
- Skip port identification entirely
- Mobile projects don't run background services
- Apps run in Xcode/simulators, not as processes we need to kill

**Why this matters:**
- Identifies exact ports to free up
- Ensures all services are stopped before worktree removal
- Prevents orphaned processes consuming resources
- For mobile, skipping this step speeds up removal

### 4. Stop Running Services (Web Projects Only)

**Purpose:** For web projects, gracefully stop all running services to free up ports and prevent orphaned processes.

**For WEB projects:**

**1. Stop server processes:**
- If SERVER_PORT identified:
  - Find processes on port: `lsof -ti :<SERVER_PORT>`
  - Returns PIDs of processes using that port
  - If PIDs found, kill processes: `kill -9 <PIDs>`
  - Use `-9` for force kill (ensures processes terminate)
  - Verify no processes remain: `lsof -ti :<SERVER_PORT>` should return nothing

**2. Stop client processes:**
- If CLIENT_PORT (VITE_PORT) identified:
  - Find processes on port: `lsof -ti :<CLIENT_PORT>`
  - If PIDs found, kill processes: `kill -9 <PIDs>`
  - Verify no processes remain: `lsof -ti :<CLIENT_PORT>` should return nothing

**3. Check for orphaned processes:**
- Search for any processes referencing the worktree directory:
  - Command: `ps aux | grep "../${REPO_NAME}-trees/<BRANCH_NAME>" | grep -v grep`
  - Captures processes that might be running from this worktree
  - Kill any found processes
- This catches edge cases like stuck build processes or file watchers

**4. Wait for process termination:**
- Sleep for 2 seconds: `sleep 2`
- Allows processes to fully terminate
- Ensures file handles are released
- Prevents issues with directory removal

**For MOBILE iOS projects:**
- Skip service shutdown completely
- Mobile apps run in Xcode/simulators/devices
- Not background processes that need killing
- No ports to free up

**Why this matters:**
- Frees up ports for reuse
- Prevents orphaned processes consuming resources
- Ensures clean directory removal (no locked files)
- Avoids port conflicts when creating new worktrees
- For mobile, skipping this speeds up removal significantly

### 5. Remove Git Worktree

**Purpose:** Remove the worktree from git's tracking and delete the directory from the filesystem.

**Steps:**

**1. Attempt normal worktree removal:**
- Execute: `git worktree remove ../${REPO_NAME}-trees/<BRANCH_NAME>`
- **What this does:**
  - Removes worktree from git's internal worktree list
  - Deletes the worktree directory from filesystem
  - Validates worktree has no uncommitted changes
  - Fails if there are uncommitted changes (safety check)

**2. Handle removal failures:**
- If removal fails (common reasons):
  - Uncommitted changes in worktree
  - Modified files that weren't staged
  - Worktree is currently in use
- Try force removal: `git worktree remove ../${REPO_NAME}-trees/<BRANCH_NAME> --force`
- **Force removal:**
  - Bypasses uncommitted changes check
  - Deletes worktree even if changes would be lost
  - Use when you're sure changes aren't needed
  - Note the force removal in the report for user awareness

**3. For mobile projects with folder prefix:**
- If standard removal fails, look for worktree with folder prefix
- Find actual worktree path from `git worktree list | grep <BRANCH_NAME>`
- Extract full directory path
- Remove using full path: `git worktree remove <FULL_PATH>`
- Force if needed: `git worktree remove <FULL_PATH> --force`

**4. Verify worktree removal:**
- Check git worktree list: `git worktree list | grep ../${REPO_NAME}-trees/<BRANCH_NAME>`
- Should return nothing if successfully removed
- If still appears, removal failed - investigate error messages

**Why this matters:**
- Ensures git no longer tracks the worktree
- Frees up disk space by deleting directory
- Prevents confusion from orphaned worktree entries
- Force option ensures removal even with uncommitted changes
- Handles both simple branch names and complex mobile naming patterns

### 6. Clean Up Orphaned Files

**Purpose:** Verify the worktree directory was completely removed and check for any lingering files.

**Steps:**

**1. Verify directory deletion:**
- Check if WORKTREE_DIR still exists: `test -d <WORKTREE_DIR>`
- Should return false (directory doesn't exist)
- If still exists after git worktree remove:
  - This shouldn't happen with successful removal
  - May indicate git issue or permission problem
  - Note in warnings section of report

**2. Check for orphaned files:**
- For web projects:
  - Look for SQLite WAL files: `ls <WORKTREE_DIR>/*.db-wal 2>/dev/null`
  - Check for lock files: `ls <WORKTREE_DIR>/.git/*.lock 2>/dev/null`
  - These can prevent clean removal
- For mobile iOS projects:
  - Check for Xcode derived data references
  - Look for build artifacts that might be locked

**3. Handle orphaned directories:**
- If directory exists after git removal:
  - **Do NOT automatically delete with rm -rf** (security risk)
  - Provide manual cleanup instructions in report
  - User should verify contents before manual deletion
  - For web: Suggest using reset-system.sh script first
  - For mobile: Suggest manual `rm -rf` after verification

**Why this matters:**
- Confirms complete cleanup
- Identifies edge cases that need manual intervention
- Prevents automatic deletion of potentially important files
- Gives user control over final cleanup steps
- Detects lock files or other issues that prevented clean removal

### 7. Delete Git Branch

**Purpose:** Permanently delete the git branch associated with the worktree.

**Steps:**

**1. Attempt safe branch deletion:**
- Execute: `git branch -d <BRANCH_NAME>`
- **What this does:**
  - Deletes branch if it's fully merged to upstream
  - Safety check prevents deleting unmerged work
  - Fails if branch has unmerged commits
- If successful, branch is deleted safely

**2. Handle unmerged branches:**
- If safe delete fails (unmerged changes):
  - Git will provide error message about unmerged commits
  - User needs to decide: merge first or force delete
- Try force delete: `git branch -D <BRANCH_NAME>`
- **Force delete:**
  - Deletes branch even if unmerged
  - Permanently loses any commits not merged elsewhere
  - Use when you're certain work isn't needed
  - Note in report that force delete was used

**3. Verify branch deletion:**
- Check branch list: `git branch --list <BRANCH_NAME>`
- Should return nothing if successfully deleted
- If still appears, deletion failed - investigate error

**4. Important warnings:**
- This operation is PERMANENT
- Once deleted, branch cannot be recovered (unless pushed to remote)
- All commits unique to this branch will be lost
- Make sure important work is committed and pushed before deletion

**Why this matters:**
- Completes the full cleanup (worktree + branch)
- Prevents confusion from orphaned branches
- Frees up branch namespace for reuse
- Force option ensures cleanup even with unmerged work
- Permanence requires clear user communication

### 8. Validation

**Purpose:** Confirm that all removal operations completed successfully and no remnants remain.

**Validation Checks:**

**1. Verify worktree removal:**
- Check git worktree list: `git worktree list`
- Confirm worktree no longer appears in list
- If still present, removal was incomplete

**2. Verify directory removal:**
- Check filesystem: `test -d <WORKTREE_DIR>`
- Should return false (directory doesn't exist)
- If exists, note in warnings for manual cleanup

**3. Verify branch deletion:**
- Check branch list: `git branch --list <BRANCH_NAME>`
- Should return nothing (branch deleted)
- If exists, deletion failed or was skipped

**4. For web projects - verify port availability:**
- Check server port: `lsof -i :<SERVER_PORT>`
- Should return nothing (port is free)
- Check client port: `lsof -i :<CLIENT_PORT>`
- Should return nothing (port is free)
- If ports still in use, include PIDs in warnings

**5. For mobile iOS projects:**
- Skip port checks (not applicable)
- Only verify worktree and branch removal

**6. Collect warnings:**
- If any validation fails, add to warnings list
- Include specific details:
  - What failed (worktree/branch/port)
  - Current state (still exists, still in use)
  - Recommended action (manual cleanup command)

**Why validation matters:**
- Ensures complete removal with no remnants
- Identifies issues that need manual intervention
- Confirms ports are freed for reuse (web projects)
- Provides confidence that cleanup succeeded
- Catches edge cases that might cause future problems

### 9. Generate Summary Report

**Purpose:** Provide clear, comprehensive summary of what was removed, current state, and any issues encountered.

The summary report should include all the information shown in the Report section below. Format it clearly with emojis and sections for easy scanning.

**Report must include:**
- Worktree details (location, branch, type)
- Services stopped (web projects only)
- Cleanup actions performed
- Important notes about permanence
- Verification status
- Warnings or issues if any occurred
- Manual cleanup instructions if needed

### 10. Announce Completion (TTS Summary)

**Purpose:** Provide audio feedback to the user about task completion using the `tts-summary` output style.

**Important:** This command uses `output-style: tts-summary` which requires:

1. **Normal response content** (steps 1-9 above)

2. **Tool calls listing** (if tools were used):
   ```typescript
   Bash({ command: "git worktree list" })
   // List all git worktrees

   Bash({ command: "lsof -ti :<port> | xargs kill -9" })
   // Stop running services

   Bash({ command: "git worktree remove ..." })
   // Remove worktree from git
   ```

3. **Audio Summary for Léo:**
   - Write a separator: `---`
   - Add heading: `## Audio Summary for Léo`
   - Craft message addressing Léo directly about what was accomplished
   - Execute TTS command:
   ```bash
   uv run ~/.claude/hooks/utils/tts/elevenlabs/elevenlabs_tts.py "Léo, I've removed the worktree for ${BRANCH_NAME} and freed up the ports."
   ```

**TTS Message Guidelines:**
- Address user directly: "Léo, I've removed..."
- Focus on outcome: what's been cleaned up
- Be conversational: speak naturally
- Highlight value: emphasize what's freed up or cleaned
- Keep concise: under 20 words
- Examples:
  - "Léo, I've removed the feature-auth worktree and deleted the branch permanently."
  - "Léo, cleaned up the dashboard worktree and freed ports 4020 and 5193."
  - "Léo, removed the mobile worktree for your search improvements."

## Report

After successful worktree removal, provide a detailed report based on project type:

### For WEB Projects:

```
✅ Git Worktree and Branch Removed Successfully!

📁 Worktree Details:
   Location: ../${REPO_NAME}-trees/<BRANCH_NAME>
   Branch: <BRANCH_NAME>
   Type: WEB
   Status: ❌ REMOVED

🛑 Services Stopped:
   ✓ Server on port <SERVER_PORT>
   ✓ Client on port <VITE_PORT>
   ✓ All orphaned processes terminated

🗑️  Cleanup:
   ✓ Git worktree removed
   ✓ Git branch deleted
   ✓ Directory removed from trees/
   ✓ No lingering processes

📝 Important Notes:
   • Both the worktree AND branch '<BRANCH_NAME>' have been deleted
   • This removal is PERMANENT and cannot be undone
   • Ports <SERVER_PORT> and <VITE_PORT> are now free
   • If you need this branch again, create a new one with: /create_worktree_prompt <BRANCH_NAME>
   • The new branch will start from your current HEAD

🔍 Verification:
   ✓ Worktree not in git worktree list
   ✓ Branch not in git branch list
   ✓ Directory ../${REPO_NAME}-trees/<BRANCH_NAME> removed
   ✓ Ports <SERVER_PORT>, <VITE_PORT> are free
```

### For MOBILE iOS Projects:

```
✅ Git Worktree and Branch Removed Successfully!

📁 Worktree Details:
   Location: ../${REPO_NAME}-trees/<WORKTREE_NAME>
   Branch: <BRANCH_NAME>
   Type: MOBILE (iOS)
   Status: ❌ REMOVED

🗑️  Cleanup:
   ✓ Git worktree removed
   ✓ Git branch deleted
   ✓ Directory removed from trees/

📝 Important Notes:
   • Both the worktree AND branch '<BRANCH_NAME>' have been deleted
   • This removal is PERMANENT and cannot be undone
   • No background services were running (mobile projects run in Xcode/simulator)
   • If you need this branch again, create a new one with: /create_mobile_worktree_prompt "<feature-title>" [jira-ticket]
   • The new branch will start from your current HEAD

🔍 Verification:
   ✓ Worktree not in git worktree list
   ✓ Branch not in git branch list
   ✓ Directory ../${REPO_NAME}-trees/<WORKTREE_NAME> removed
```

### If any issues occurred during removal:

```
⚠️  Warnings / Issues:
- Used --force flag to remove worktree (had uncommitted changes)
- Used -D flag to force delete branch (had unmerged changes)
[For Web Projects:]
- Port <PORT> could not be identified (no .env file found - estimated ports used)
- Processes manually killed: <PID1>, <PID2>
[For Mobile Projects:]
- Worktree had folder prefix: <actual-worktree-name>
```

### If worktree was already partially removed or not found:

```
⚠️  Worktree Status:
- Worktree '../${REPO_NAME}-trees/<BRANCH_NAME>' was not found in git worktree list
- Directory may have been manually deleted
- Run 'git worktree prune' to clean up worktree metadata

📝 Cleanup Command:
   git worktree prune
```

### If orphaned directory exists after removal:

```
⚠️  Manual Cleanup Required:
- Directory ../${REPO_NAME}-trees/<BRANCH_NAME> still exists after git worktree remove
- This should not happen normally
- Verify the directory contents before manual deletion

[For Web Projects:]
- To manually remove, run from PROJECT_CWD:
   # First stop services if still running:
   lsof -ti :<SERVER_PORT> | xargs kill -9
   lsof -ti :<CLIENT_PORT> | xargs kill -9

   # Then remove directory:
   rm -rf ../${REPO_NAME}-trees/<BRANCH_NAME>

[For Mobile iOS Projects:]
- To manually remove, run from PROJECT_CWD:
   rm -rf ../${REPO_NAME}-trees/<WORKTREE_NAME>
```

## Error Handling

If any step fails:
1. Provide clear error message with what went wrong
2. Suggest remediation steps
3. For partial removal, provide cleanup instructions
4. Common errors:
   - Missing BRANCH_NAME argument
   - Worktree not found (provide prune command)
   - Uncommitted changes (offer force removal)
   - Unmerged branch (explain force delete option)
   - Orphaned directory (provide manual removal steps)
   - Ports still in use (provide PIDs to kill)

## Examples

### Example 1: Remove web worktree

**Input:**
```bash
/remove_worktree_prompt feature-auth
```

**Process:**
1. Detects web project (has apps/server and apps/client)
2. Reads ports from .env files: 4010 (server), 5183 (client)
3. Kills processes on ports 4010 and 5183
4. Removes worktree: `git worktree remove trees/feature-auth`
5. Deletes branch: `git branch -d feature-auth`
6. Reports successful removal with freed ports

### Example 2: Remove mobile iOS worktree with JIRA

**Input:**
```bash
/remove_worktree_prompt feature/PTECH-503-improve-search
```

**Process:**
1. Detects mobile iOS project (has .xcodeproj file)
2. Finds worktree: `trees/reellette-ios-PTECH-503-improve-search`
3. Skips service shutdown (no services running)
4. Removes worktree with full path
5. Deletes branch: `git branch -d feature/PTECH-503-improve-search`
6. Reports successful removal

### Example 3: Force remove worktree with uncommitted changes

**Input:**
```bash
/remove_worktree_prompt hotfix-security
```

**Process:**
1. Attempts: `git worktree remove trees/hotfix-security`
2. Fails: "worktree has uncommitted changes"
3. Force removes: `git worktree remove trees/hotfix-security --force`
4. Deletes branch: `git branch -D hotfix-security` (force)
5. Reports successful removal with warnings about force flags used

## Notes

- Automatically detects web vs mobile iOS project type
- Web projects: Stops all services before removal
- Mobile iOS projects: No service management needed
- Branch deletion is always permanent for both types
- Validation ensures complete cleanup
- Force options used when necessary
- Clear feedback for all operations
- Handles folder-prefixed mobile worktree names
