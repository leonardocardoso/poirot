---
model: claude-opus-4-6
description: List all git worktrees with their configuration and status
allowed-tools: Bash, Read, Glob, Grep
output-style: tts-summary
---

# Purpose

Display a comprehensive overview of all git worktrees with their configuration, status, and quick action commands. Provides real-time information about running services (web projects) and dependency status (mobile projects).

## Overview

This command is the **central dashboard** for managing parallel development environments. It shows you everything you need to know about your worktrees at a glance.

**Key Features:**
- **Automatic project type detection**: Identifies web vs mobile projects
- **Real-time status checking**: Shows which services are running (web) or dependencies installed (mobile)
- **Port conflict detection**: Identifies port conflicts and issues (web)
- **Quick action commands**: Copy-paste commands for common operations
- **Comprehensive summary**: Total worktrees, next available port offset, warnings

**When to use this command:**
- You want to see all active worktrees
- You need to check which services are running
- You're looking for the next available port offset (web)
- You want to verify worktree configuration
- You need quick commands to start/stop/remove worktrees
- You want to troubleshoot worktree issues

**What you get:**
- **Main repository status**: Current branch, type, running status
- **Per-worktree information**:
  - Web: Branch, ports, service status (PIDs), access URLs, dependencies
  - Mobile: Branch, dependency status (node_modules, Pods), platform info
- **Summary statistics**: Total count, web vs mobile breakdown, port availability
- **Quick commands**: Pre-formatted commands for common operations
- **Warning system**: Alerts for configuration issues or conflicts

**Comparison with manual checking:**
- **Manual**: `git worktree list` → minimal info, no status, no configuration
- **This command**: Complete dashboard with configuration, status, and actionable commands

## Variables

```
PROJECT_CWD: . (current working directory - the main project root)
REPO_NAME: basename of PROJECT_CWD (e.g., "reellette-ios", "my-project")
WORKTREE_BASE_DIR: ../${REPO_NAME}-trees/
```

## Instructions

This section provides step-by-step instructions for gathering and displaying worktree information. The command reads configuration, checks status, and formats a comprehensive dashboard.

**High-level workflow:**
1. List all git worktrees
2. Detect project type for each worktree (web vs mobile)
3. Gather configuration details per project type
4. Check service/dependency status
5. Calculate summary statistics
6. Format and display comprehensive report

## Workflow

### 1. List Git Worktrees

**Purpose:** Discover all worktrees in the repository and extract basic information.

**Steps:**

1. **Execute git worktree list:**
   - Run: `git worktree list`
   - This command lists ALL worktrees registered with git
   - Output format: `<path> <commit-hash> [<branch-name>]`
   - Example output:
     ```
     /Users/user/project         abc123d [main]
     /Users/user/project/../${REPO_NAME}-trees/feat-auth  def456e [feature/auth]
     ```

2. **Parse git output:**
   - Extract three key pieces of information for each line:
     - **Worktree path**: Full filesystem path to worktree
     - **Commit hash**: Current HEAD commit (7-character short hash)
     - **Branch name**: Current branch (if available)
   - Use whitespace as delimiter
   - Handle edge cases (detached HEAD, missing branch names)

3. **Filter for worktrees directory:**
   - Only process worktrees located in `../${REPO_NAME}-trees/` directory
   - Ignore the main repository worktree (not in worktrees directory)
   - Filter logic: `path.contains('/${REPO_NAME}-trees/')`
   - This focuses the dashboard on parallel development worktrees

4. **Extract worktree metadata:**
   - **Worktree path**: Full path from git output (e.g., `/Users/user/project/../${REPO_NAME}-trees/reellette-ios-feat-auth`)
   - **Branch name**: Git branch (e.g., `feature/auth`, `feature/PTECH-503-create-agents`)
   - **Commit hash**: Short hash (e.g., `abc123d`)
   - **Directory name**: Basename of worktree path for display

5. **Check directory existence:**
   - **For each worktree**, verify the directory actually exists
   - Use the FULL PATH from git worktree list output
   - Command: `test -d "<full-worktree-path>"`
   - **If exists**: Worktree is valid, proceed with configuration gathering
   - **If missing**: Worktree is orphaned (git entry exists but directory deleted)
   - **Orphaned worktrees**: Should be noted in warnings and suggest cleanup with `git worktree prune`

**Why this matters:** This gives us the foundation - knowing which worktrees exist and their basic git state. Proper directory existence checking prevents false "orphaned" reports.

### 2. Detect Project Type for Each Worktree

**Purpose:** Determine whether each worktree is a web or mobile project to know what information to gather.

For each worktree found in trees/, execute this detection logic:

**Detection Algorithm:**

1. **Check for web project indicators:**
   - Test if `<worktree>/apps/server` directory exists
   - Test if `<worktree>/apps/client` directory exists
   - **If BOTH exist** → **WEB PROJECT**
   - This indicates server/client architecture

2. **Check for mobile project indicators:**
   - Test if `<worktree>/*.xcodeproj` files exist (iOS project)
   - Test if `<worktree>/*.xcworkspace` files exist (iOS workspace)
   - **If ANY exist** → **MOBILE PROJECT**
   - iOS-only projects check for Xcode files

3. **Default fallback:**
   - If neither web nor mobile indicators found
   - **Default to WEB** for safety
   - Log warning about unclear project type

**Detection Commands:**
```bash
# Web detection
test -d "<worktree>/apps/server" && test -d "<worktree>/apps/client"

# Mobile detection (iOS)
ls <worktree>/*.xcodeproj 2>/dev/null || ls <worktree>/*.xcworkspace 2>/dev/null
```

**Why this matters:** Project type determines what configuration to read and what status to check. Web projects need port/service info, mobile projects need dependency info.

### 3. Gather Configuration for Each Worktree

**Purpose:** Extract configuration details specific to each project type for comprehensive status reporting.

**Common Information (Both Types):**
- **Worktree directory**: Basename of trees/ path (e.g., `reellette-ios-PTECH-503-agents`)
- **Branch name**: From git worktree list (e.g., `feature/PTECH-503-create-agents`)
- **Working directory path**: Full filesystem path
- **Commit hash**: Short hash from git worktree list

#### For WEB Projects:

**1. Read Server Configuration:**

- **Check for .env file**: `test -f <worktree>/apps/server/.env`
- **If exists, extract variables:**
  ```bash
  # Read SERVER_PORT
  grep "^SERVER_PORT=" <worktree>/apps/server/.env | cut -d= -f2

  # Read DB_PATH
  grep "^DB_PATH=" <worktree>/apps/server/.env | cut -d= -f2
  ```
- **Variables to extract:**
  - `SERVER_PORT`: Port number for server (e.g., 4010, 4020)
  - `DB_PATH`: Database file path (e.g., events.db)
- **If doesn't exist**: Mark as "⚠️ Not configured" in report
- **Why:** Need port numbers for service status checking

**2. Read Client Configuration:**

- **Check for .env file**: `test -f <worktree>/apps/client/.env`
- **If exists, extract variables:**
  ```bash
  # Read VITE_PORT
  grep "^VITE_PORT=" <worktree>/apps/client/.env | cut -d= -f2

  # Read VITE_API_URL
  grep "^VITE_API_URL=" <worktree>/apps/client/.env | cut -d= -f2

  # Read VITE_WS_URL
  grep "^VITE_WS_URL=" <worktree>/apps/client/.env | cut -d= -f2
  ```
- **Variables to extract:**
  - `VITE_PORT`: Client dev server port (e.g., 5183, 5193)
  - `VITE_API_URL`: API endpoint URL (e.g., http://localhost:4010)
  - `VITE_WS_URL`: WebSocket URL (e.g., ws://localhost:4010/stream)
  - `VITE_MAX_EVENTS_TO_DISPLAY`: Optional display limit
- **If doesn't exist**: Mark as "⚠️ Not configured"
- **Why:** Need ports for status checking and URLs for reporting

**3. Check Dependencies:**

- **Server dependencies**: `test -d <worktree>/apps/server/node_modules`
  - ✓ Installed: Directory exists with packages
  - ❌ Missing: Directory doesn't exist or empty
- **Client dependencies**: `test -d <worktree>/apps/client/node_modules`
  - ✓ Installed: Directory exists with packages
  - ❌ Missing: Directory doesn't exist or empty
- **Why:** Indicates if worktree is ready to run or needs `bun install`

#### For MOBILE Projects:

**1. Check .claude Configuration:**

- **Check for .claude directory**: `test -d <worktree>/.claude`
- **Display**: "✓ .claude folder copied" or "❌ Not copied"
- **Why:** Confirms Claude Code configuration was copied for consistent development experience
- **Note:** Mobile worktrees created with `/create_mobile_worktree_prompt` only copy .claude config
- **No dependency installation**: Mobile worktrees don't pre-install dependencies or copy .env files

**2. Check Platform Info:**

- **iOS project**: Check for .xcodeproj or .xcworkspace files
  - Command: `ls <worktree>/*.xcodeproj <worktree>/*.xcworkspace 2>/dev/null`
  - Extract project name from filename
  - ✓ Present: Display project name (e.g., "Reellette.xcworkspace")
  - ❌ Missing: Note absence (unusual, indicates issue)

**Why this matters:** Shows if the worktree has the Claude Code configuration copied and identifies the Xcode project to open.

### 4. Check Service Status (WEB Projects Only)

**Purpose:** Determine which services are actively running for web worktrees to show real-time status.

For each web worktree with port configuration:

**1. Check Server Status:**

- **Port availability check**: `lsof -i :<SERVER_PORT>`
- **Parse lsof output:**
  ```bash
  # Example output if running:
  # COMMAND   PID   USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
  # node     12345  user   21u  IPv4  0x...  0t0     TCP *:4010 (LISTEN)
  ```
- **Extract information:**
  - **Process name**: Command column (e.g., "node", "bun")
  - **PID**: Process ID for killing if needed
  - **Port**: Confirm it matches SERVER_PORT
- **Determine status:**
  - **Running**: lsof returns results → 🟢 RUNNING (PID: 12345)
  - **Stopped**: lsof returns nothing → 🔴 STOPPED
- **Why:** Shows if server is accessible and which process to kill if needed

**2. Check Client Status:**

- **Port availability check**: `lsof -i :<VITE_PORT>`
- **Parse lsof output** (same format as server)
- **Extract information:**
  - **Process name**: Usually "node" or "vite"
  - **PID**: For process management
  - **Port**: Confirm matches VITE_PORT
- **Determine status:**
  - **Running**: lsof returns results → 🟢 RUNNING (PID: 67890)
  - **Stopped**: lsof returns nothing → 🔴 STOPPED
- **Why:** Shows if dev server is running and dashboard is accessible

**3. Generate Access URLs (if running):**

- **Dashboard URL**: `http://localhost:<VITE_PORT>`
  - Only show if client is running
  - This is the main UI entry point
- **API URL**: `http://localhost:<SERVER_PORT>`
  - Only show if server is running
  - Direct API access
- **WebSocket URL**: `ws://localhost:<SERVER_PORT>/stream`
  - Only show if server is running
  - Real-time event streaming

**Status Indicators:**
- 🟢 RUNNING (PID: xxxxx): Service is active and accessible
- 🔴 STOPPED: Service is not running
- ⚠️ NOT CONFIGURED: .env files missing, can't determine ports

### 5. Calculate Statistics

**Purpose:** Provide summary metrics for quick overview of all worktrees.

**Statistics to Calculate:**

1. **Total Worktree Count:**
   - Count all worktrees in trees/ directory
   - Example: "Total Worktrees: 3"

2. **Project Type Breakdown:**
   - **Web Projects**: Count worktrees with apps/server and apps/client
   - **Mobile Projects**: Count worktrees with iOS/Android indicators
   - Example: "Web Projects: 2 | Mobile Projects: 1"

3. **Web Service Status (Web Only):**
   - **Running**: Count worktrees with BOTH server AND client running
   - **Stopped**: Count worktrees with BOTH stopped
   - **Partial**: Count worktrees with only one service running
   - Example: "Running: 1 | Stopped: 1"

4. **Ports In Use (Web Only):**
   - List all SERVER_PORTs currently running
   - List all VITE_PORTs currently running
   - Example: "Ports in use: 4010, 4020, 5183, 5193"

5. **Next Available Port Offset (Web Only):**
   - Find highest port offset currently in use
   - Suggest next offset = highest + 1
   - **Algorithm:**
     ```bash
     # Extract all SERVER_PORTs from .env files
     # Calculate offsets: (PORT - 4000) / 10
     # Find maximum offset
     # Suggest: max_offset + 1
     ```
   - Example: "Next Available Port Offset: 3"
     - This would give ports 4030 (server) and 5203 (client)

**Why this matters:** Summary statistics provide quick health check - how many worktrees exist, how many are running, what ports are available for new worktrees.

### 6. Report

Follow the Report section format below.

## Report

After gathering all information, provide a comprehensive report in the following format:

```
📊 Git Worktrees Overview

═══════════════════════════════════════════════════════════════

📈 Summary:
   Total Worktrees: <count>
   Web Projects: <count> (Running: <count> | Stopped: <count>)
   Mobile Projects: <count>
   Next Available Port Offset (Web): <offset>

═══════════════════════════════════════════════════════════════

🌳 Main Repository (Default)
   📁 Location: <project-root>
   🌿 Branch: <current-branch>
   📱 Type: <WEB|MOBILE>

   [For Web Projects:]
   🔌 Ports: 4000 (server), 5173 (client)
   🎯 Status: <RUNNING|STOPPED>

   Actions:
   └─ Start: ./scripts/start-system.sh
   └─ Stop: ./scripts/reset-system.sh

   [For Mobile Projects:]
   📦 Dependencies: <✓ Installed | ❌ Missing>

   Actions:
   └─ Open iOS: open ios/<project>.xcworkspace
   └─ Run iOS: npx react-native run-ios

───────────────────────────────────────────────────────────────

[For WEB Worktrees:]

🌳 Worktree: <branch-name> (WEB)
   📁 Location: ../${REPO_NAME}-trees/<branch-name>
   🌿 Branch: <branch-name>
   📝 Commit: <commit-hash-short>

   ⚙️  Configuration:
   ├─ Server Port: <SERVER_PORT>
   ├─ Client Port: <VITE_PORT>
   ├─ Database: <DB_PATH>
   ├─ API URL: <VITE_API_URL>
   └─ WebSocket: <VITE_WS_URL>

   📦 Dependencies:
   ├─ Server: <✓ Installed | ❌ Missing>
   └─ Client: <✓ Installed | ❌ Missing>

   🎯 Service Status:
   ├─ Server: <🟢 RUNNING (PID: xxxx) | 🔴 STOPPED>
   └─ Client: <🟢 RUNNING (PID: xxxx) | 🔴 STOPPED>

   🌐 Access URLs (if running):
   ├─ Dashboard: http://localhost:<VITE_PORT>
   ├─ Server API: http://localhost:<SERVER_PORT>
   └─ WebSocket: ws://localhost:<SERVER_PORT>/stream

   Actions:
   ├─ Start: cd ../${REPO_NAME}-trees/<branch-name> && SERVER_PORT=<port> CLIENT_PORT=<port> sh scripts/start-system.sh
   ├─ Stop: SERVER_PORT=<port> CLIENT_PORT=<port> ./scripts/reset-system.sh
   └─ Remove: /remove_worktree_prompt <branch-name>

───────────────────────────────────────────────────────────────

[For MOBILE Worktrees:]

🌳 Worktree: <branch-name> (MOBILE - iOS)
   📁 Location: ../${REPO_NAME}-trees/<branch-name>
   🌿 Branch: <branch-name>
   📝 Commit: <commit-hash-short>

   ⚙️  Configuration:
   └─ Claude Code: <✓ .claude folder copied | ❌ Not copied>

   📱 Project:
   └─ iOS: <project-name>.xcodeproj (or .xcworkspace)

   🎯 Status: 🟢 READY

   Actions:
   ├─ Open in Xcode: cd ../${REPO_NAME}-trees/<branch-name> && open *.xcworkspace
   │                  (or open *.xcodeproj if no workspace)
   └─ Remove: /remove_worktree_prompt <branch-name>

───────────────────────────────────────────────────────────────

[Repeat for each worktree]

═══════════════════════════════════════════════════════════════

💡 Quick Commands:

Create new worktree (web):
└─ /create_worktree_prompt <branch-name> [port-offset] web

Create new worktree (mobile - from branch name):
└─ /create_worktree_prompt <branch-name> 0 mobile

Create new worktree (mobile - from feature title):
└─ /create_mobile_worktree_prompt "<feature-title>" [jira-ticket]

Remove worktree:
└─ /remove_worktree_prompt <branch-name>

[For Web Projects:]
Start a stopped worktree:
└─ cd ../${REPO_NAME}-trees/<branch-name> && SERVER_PORT=<port> CLIENT_PORT=<port> sh scripts/start-system.sh &

Stop a running worktree:
└─ lsof -ti :<SERVER_PORT> | xargs kill -9 && lsof -ti :<CLIENT_PORT> | xargs kill -9

[For Mobile Projects:]
Install dependencies:
└─ cd ../${REPO_NAME}-trees/<branch-name> && npm install && cd ios && pod install

View this list again:
└─ /list_worktrees_prompt

═══════════════════════════════════════════════════════════════
```

If no worktrees exist in trees/:

```
📊 Git Worktrees Overview

═══════════════════════════════════════════════════════════════

🌳 Main Repository (Default)
   📁 Location: <project-root>
   🌿 Branch: <current-branch>
   📱 Type: <WEB|MOBILE>
   🎯 Status: <RUNNING|STOPPED|READY>

═══════════════════════════════════════════════════════════════

ℹ️  No worktrees found in ../${REPO_NAME}-trees/ directory

💡 Create your first worktree:

   Web project:
   /create_worktree_prompt <branch-name>

   Mobile project (from branch name):
   /create_worktree_prompt <branch-name> 0 mobile

   Mobile project (from feature title):
   /create_mobile_worktree_prompt "<feature-title>" [jira-ticket]

   This will:
   • Create isolated git worktree
   • Configure unique ports (web only)
   • Install dependencies
   • Start services automatically (web only)

═══════════════════════════════════════════════════════════════
```

If worktrees have configuration issues:

```
⚠️  Configuration Warnings:

[For Web Projects:]
• ../${REPO_NAME}-trees/<branch-name> (WEB): Missing .env files
  └─ Fix: Recreate with /create_worktree_prompt <branch-name> web

• ../${REPO_NAME}-trees/<branch-name> (WEB): Dependencies not installed
  └─ Fix: cd ../${REPO_NAME}-trees/<branch-name>/apps/server && bun install
  └─ Fix: cd ../${REPO_NAME}-trees/<branch-name>/apps/client && bun install

• ../${REPO_NAME}-trees/<branch-name> (WEB): Services running but ports mismatch
  └─ Fix: Stop services and update .env files

[For Mobile Projects:]
• ../${REPO_NAME}-trees/<branch-name> (MOBILE): Missing .env file
  └─ Fix: Copy from main: cp .env ../${REPO_NAME}-trees/<branch-name>/.env
```

## Notes

- Main repository is always shown first
- Worktrees are grouped by type (web vs mobile) and sorted alphabetically
- Service status is checked in real-time for web projects
- Port conflicts are detected and highlighted for web projects
- Mobile projects show platform info (iOS) instead of service status
- Orphaned worktrees (in git but not in trees/) are noted
- PIDs are shown for running processes for easy termination (web only)
- All commands are copy-paste ready

## TTS Summary Requirements

**Important:** This command uses `output-style: tts-summary` which requires:

1. **Normal response content** (all worktree information above)

2. **Tool calls listing** (if tools were used):
   ```typescript
   Bash({ command: "git worktree list" })
   // List all worktrees

   Bash({ command: "lsof -i :4010" })
   // Check service status on ports

   Read({ file_path: "apps/server/.env" })
   // Read worktree configuration
   ```

3. **Audio Summary for Léo:**
   - Write a separator: `---`
   - Add heading: `## Audio Summary for Léo`
   - Craft message addressing Léo directly about the worktree status
   - Execute TTS command:
   ```bash
   uv run ~/.claude/hooks/utils/tts/elevenlabs/elevenlabs_tts.py "Léo, you have X worktrees active with Y running services."
   ```

**TTS Message Guidelines:**
- Address user directly: "Léo, you have..."
- Focus on key metrics: number of worktrees, running services, available ports
- Be conversational: speak naturally
- Highlight actionable info: what's running, what's available
- Keep concise: under 20 words
- Examples:
  - "Léo, you have 3 worktrees with 2 services running and port offset 4 available."
  - "Léo, all your worktrees are stopped, ready to start when you need them."
  - "Léo, you have 1 mobile worktree for PTECH-503 and 2 web worktrees running."
