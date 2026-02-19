# Worktree Usage Examples

Real-world examples demonstrating how to handle different worktree management scenarios for both web and mobile iOS projects.

---

## MOBILE iOS EXAMPLES

### Example 1: Create iOS worktree with JIRA ticket

**User says:** "Create a worktree for PTECH-503 where I need to improve search performance"

**Your action:**
1. Detect project type: `ls *.xcodeproj` → finds iOS project
2. Extract: Feature = "Improve search performance", JIRA = "PTECH-503"
3. Use SlashCommand: `/create_mobile_worktree_prompt "Improve search performance" "PTECH-503"`

**Result:**
- Branch: `feature/PTECH-503-improve-search-performance`
- Worktree: `trees/reellette-ios-PTECH-503-improve-search-performance`
- .claude config copied

**Sample response to user:**
> I've created a worktree for improving search performance:
> - Branch: `feature/PTECH-503-improve-search-performance`
> - Location: `trees/reellette-ios-PTECH-503-improve-search-performance`
> - Open in Xcode: `cd trees/reellette-ios-PTECH-503-improve-search-performance && open *.xcworkspace`
> - Claude Code configuration ready ✓

---

### Example 2: Create iOS worktree without JIRA ticket

**User says:** "I need to work on splitting the Discover and Catalog code"

**Your action:**
1. Detect project type: iOS project found
2. Extract: Feature = "Split Discover and Catalog code"
3. Use SlashCommand: `/create_mobile_worktree_prompt "Split Discover and Catalog code"`

**Result:**
- Branch: `feature/split-discover-and-catalog-code`
- Worktree: `trees/reellette-ios-split-discover-and-catalog-code`

**Sample response to user:**
> I've created a worktree for splitting Discover and Catalog:
> - Branch: `feature/split-discover-and-catalog-code`
> - Location: `trees/reellette-ios-split-discover-and-catalog-code`
> - Ready to open in Xcode ✓

---

### Example 3: List iOS worktrees

**User says:** "What mobile worktrees do I have?"

**Your action:**
1. Use SlashCommand: `/list_worktrees_prompt`
2. Filter and highlight mobile iOS worktrees

**Sample response to user:**
> Here are your mobile iOS worktrees:
>
> 1. **feature/PTECH-503-improve-search-performance**
>    - Location: `trees/reellette-ios-PTECH-503-improve-search-performance`
>    - Project: Reellette.xcworkspace
>    - Status: Ready ✓
>
> 2. **feature/split-discover-and-catalog-code**
>    - Location: `trees/reellette-ios-split-discover-and-catalog-code`
>    - Project: Reellette.xcworkspace
>    - Status: Ready ✓
>
> Total: 2 mobile worktrees

---

### Example 4: Remove iOS worktree

**User says:** "Delete the search performance worktree, I've merged it"

**Your action:**
1. Identify branch: `feature/PTECH-503-improve-search-performance`
2. Use SlashCommand: `/remove_worktree_prompt feature/PTECH-503-improve-search-performance`

**Sample response to user:**
> Successfully removed the worktree:
> - Branch: `feature/PTECH-503-improve-search-performance` (deleted)
> - Worktree: `trees/reellette-ios-PTECH-503-improve-search-performance` (removed)
> - Everything cleaned up ✓
>
> ⚠️ The branch has been permanently deleted

---

### Example 5: Multiple iOS worktrees for parallel features

**User says:** "I need three worktrees: dark mode (PE-100), offline support (PE-101), and UI cleanup"

**Your action:**
1. Detect iOS project
2. Create each worktree:
   - `/create_mobile_worktree_prompt "Add dark mode support" "PE-100"`
   - `/create_mobile_worktree_prompt "Add offline support" "PE-101"`
   - `/create_mobile_worktree_prompt "UI cleanup and improvements"`

**Sample response to user:**
> Created three worktrees for parallel iOS development:
>
> 1. **Dark Mode** (PE-100)
>    - Branch: `feature/PE-100-add-dark-mode-support`
>    - Location: `trees/reellette-ios-PE-100-add-dark-mode-support`
>
> 2. **Offline Support** (PE-101)
>    - Branch: `feature/PE-101-add-offline-support`
>    - Location: `trees/reellette-ios-PE-101-add-offline-support`
>
> 3. **UI Cleanup**
>    - Branch: `feature/ui-cleanup-and-improvements`
>    - Location: `trees/reellette-ios-ui-cleanup-and-improvements`
>
> All worktrees ready to open in Xcode! ✓

---

### Example 6: iOS worktree with special characters in title

**User says:** "Create a worktree for PE-999: Fix User Auth Bug (iOS)"

**Your action:**
1. Extract: Feature = "Fix User Auth Bug (iOS)", JIRA = "PE-999"
2. Use SlashCommand: `/create_mobile_worktree_prompt "Fix User Auth Bug (iOS)" "PE-999"`

**Result:**
- Special characters removed in kebab-case conversion
- Branch: `feature/PE-999-fix-user-auth-bug-ios`

**Sample response to user:**
> Created worktree for auth bug fix:
> - Branch: `feature/PE-999-fix-user-auth-bug-ios`
> - Location: `trees/reellette-ios-PE-999-fix-user-auth-bug-ios`
> - Special characters cleaned up automatically ✓

---

## WEB PROJECT EXAMPLES

### Example 7: Create a web worktree

**User says:** "Create a worktree for the feature-authentication branch"

**Your action:**
1. Detect web project (has `apps/server` and `apps/client`)
2. Use SlashCommand: `/create_worktree_prompt feature-authentication`

**Result:** New worktree created at `trees/feature-authentication` with services running

**Sample response to user:**
> I've created a worktree for `feature-authentication`:
> - Location: `trees/feature-authentication`
> - **API**: http://localhost:4010 (PORT=4010)
> - **Dashboard**: http://localhost:3010 (DASHBOARD_PORT=3010)
> - **PostgreSQL**: localhost:5442 (POSTGRES_PORT=5442)
> - **Redis**: localhost:6389 (REDIS_PORT=6389)
> - Docker Compose: `ignio-feature-authentication`
> - Services running in background ✓

---

### Example 8: Create web worktree with specific port offset

**User says:** "Set up a parallel environment on branch hotfix-security with port offset 3"

**Your action:**
1. Detect web project
2. Use SlashCommand: `/create_worktree_prompt hotfix-security 3 web`

**Result:** Worktree created with custom ports

**Sample response to user:**
> Created worktree for `hotfix-security` with port offset 3:
> - Location: `trees/hotfix-security`
> - **API**: http://localhost:4030 (PORT=4030)
> - **Dashboard**: http://localhost:3030 (DASHBOARD_PORT=3030)
> - **PostgreSQL**: localhost:5462 (POSTGRES_PORT=5462)
> - **Redis**: localhost:6409 (REDIS_PORT=6409)
> - Docker Compose: `ignio-hotfix-security`
> - Services running ✓

---

### Example 9: List all worktrees (web)

**User says:** "What worktrees do I have?"

**Your action:**
1. Use SlashCommand: `/list_worktrees_prompt`
2. Share the comprehensive overview

**Sample response to user:**
> Here are your web worktrees:
>
> 1. **feature-authentication** (Offset 1)
>    - Server: http://localhost:4010 (Running, PID: 12345)
>    - Client: http://localhost:5183 (Running, PID: 12346)
>    - Dashboard: http://localhost:5183/dashboard
>
> 2. **hotfix-security** (Offset 3)
>    - Server: http://localhost:4030 (Stopped)
>    - Client: http://localhost:5203 (Stopped)
>
> Total: 2 worktrees | Next offset: 2

---

### Example 10: Check web worktree status

**User says:** "Show me the status of my worktrees"

**Your action:**
1. Use SlashCommand: `/list_worktrees_prompt`
2. Highlight key information: running services, ports in use, access URLs

**What to highlight:**
- Which services are running vs stopped
- Port conflicts if any
- Quick access URLs
- PIDs of running processes

**Sample response to user:**
> Here's the status of your worktrees:
>
> **Running:**
> - feature-authentication (4010/5183) - Both services active
>   - Access: http://localhost:5183/dashboard
>
> **Stopped:**
> - hotfix-security (4030/5203) - Services not running
>   - To restart: `cd trees/hotfix-security && sh scripts/start-system.sh`

---

### Example 11: Remove a web worktree

**User says:** "Delete the feature-auth worktree"

**Your action:**
1. Use SlashCommand: `/remove_worktree_prompt feature-auth`
2. Confirm removal completed

**Result:** Worktree removed, services stopped, directory cleaned up

**Sample response to user:**
> Successfully removed the `feature-auth` worktree:
> - Stopped server on port 4010 ✓
> - Stopped client on port 5183 ✓
> - Branch `feature-auth` deleted (permanent) ✓
> - Directory cleaned up ✓
> - Ports 4010 and 5183 are now free

---

### Example 12: Remove with different wording

**User says:** "Clean up the old-branch worktree, I don't need it anymore"

**Your action:**
1. Use SlashCommand: `/remove_worktree_prompt old-branch`
2. Share confirmation

**Result:** Worktree removed successfully

**Note:** Recognize variations: "clean up", "don't need", "remove", "delete" all indicate removal.

---

## MIXED PROJECT EXAMPLES

### Example 13: List all worktrees (mixed web + mobile)

**User says:** "Show me all my worktrees"

**Your action:**
1. Use SlashCommand: `/list_worktrees_prompt`
2. Present both web and mobile worktrees organized by type

**Sample response to user:**
> Here are all your worktrees:
>
> **Web Worktrees (2):**
> 1. feature-auth (4010/5183) - Running ✓
> 2. hotfix-bug (4020/5193) - Stopped
>
> **Mobile iOS Worktrees (3):**
> 1. feature/PE-100-dark-mode (reellette-ios-PE-100-dark-mode) - Ready ✓
> 2. feature/PE-101-offline (reellette-ios-PE-101-offline) - Ready ✓
> 3. feature/ui-cleanup (reellette-ios-ui-cleanup) - Ready ✓
>
> **Total: 5 worktrees** (2 web, 3 mobile)

---

### Example 14: Multiple operations workflow

**User says:** "Show me my worktrees, then create a new one for refactor-api"

**Your action:**
1. Detect web project
2. Use SlashCommand: `/list_worktrees_prompt`
3. Share current worktrees
4. Use SlashCommand: `/create_worktree_prompt refactor-api`
5. Share new worktree details

**Result:** User sees existing worktrees, then gets a new one created

**Sample response to user:**
> Here are your current worktrees:
> [list output]
>
> Now creating a new worktree for `refactor-api`...
>
> ✓ Created worktree:
> - Location: `trees/refactor-api`
> - Dashboard: http://localhost:5193/dashboard
> - Ports: 4020 (server), 5193 (client)
> - Services running ✓

---

### Example 15: Managing parallel web environments

**User says:** "I need three worktrees for branches: feature-a, feature-b, and feature-c"

**Your action:**
1. Detect web project
2. Create each:
   - `/create_worktree_prompt feature-a`
   - `/create_worktree_prompt feature-b`
   - `/create_worktree_prompt feature-c`
3. Use `/list_worktrees_prompt` to show all three

**Result:** Three parallel worktrees created with unique ports

**Sample response to user:**
> Created three worktrees for parallel development:
>
> 1. **feature-a**
>    - Server: http://localhost:4010
>    - Client: http://localhost:5183
>    - Dashboard: http://localhost:5183/dashboard
>
> 2. **feature-b**
>    - Server: http://localhost:4020
>    - Client: http://localhost:5193
>    - Dashboard: http://localhost:5193/dashboard
>
> 3. **feature-c**
>    - Server: http://localhost:4030
>    - Client: http://localhost:5203
>    - Dashboard: http://localhost:5203/dashboard
>
> All services are running and ready for development! ✓

---

### Example 16: Cleanup workflow for multiple worktrees

**User says:** "Clean up all my old worktrees"

**Your action:**
1. Use `/list_worktrees_prompt` to see all worktrees
2. Ask which ones to remove
3. Remove each one user specifies

**Sample response to user:**
> Here are your worktrees:
> [list of worktrees]
>
> Which ones should I remove? (Or I can remove all of them)

*[User responds: "Remove feature-a and old-mobile worktree"]*

> Removing worktrees:
>
> 1. **feature-a** (Web)
>    - Stopped services on ports 4010/5183 ✓
>    - Branch deleted ✓
>
> 2. **feature/old-mobile** (iOS)
>    - Worktree removed ✓
>    - Branch deleted ✓
>
> Both worktrees cleaned up successfully!

---

## Pattern Recognition

### Create Keywords

**Mobile iOS:**
- "create worktree for [JIRA-TICKET]"
- "I need to work on [feature description]"
- "set up a worktree for [feature]"
- Feature descriptions in natural language

**Web:**
- "create worktree for [branch-name]"
- "set up parallel environment on [branch]"
- "make a worktree for [branch]"
- Explicit branch names

### List Keywords
- "list", "show", "display", "what", "which", "status", "check", "view"
- "What worktrees do I have?"
- "Show me my environments..."
- "Check worktree status"

### Remove Keywords
- "remove", "delete", "cleanup", "destroy", "stop", "kill", "terminate"
- "Clean up the...", "I don't need..."
- "Get rid of...", "Delete the..."
- "Remove worktree for..."

---

## Response Patterns

### For Mobile iOS Creation:
Always include:
- Generated branch name
- Worktree location with folder prefix
- Xcode open command
- .claude config status

### For Web Creation:
Always include:
- Dashboard URL (ready to click)
- Server and client ports
- Service status
- Location for manual access

### For Listing:
Always include:
- Project type breakdown (web vs mobile)
- Status for each worktree
- Quick action commands
- Total count

### For Removal:
Always include:
- What was removed
- Services stopped (web only)
- Branch deletion warning (PERMANENT)
- Ports freed (web only)
