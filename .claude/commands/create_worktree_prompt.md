---
model: claude-opus-4-6
description: Create a git worktree with isolated configuration for parallel development
argument-hint: [branch-name] [port-offset] [project-type]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
output-style: tts-summary
---

# Purpose

Create a new git worktree in the `../<REPO_NAME>-trees/` directory (at the same level as the project) with completely isolated configuration for parallel execution. Supports both web applications (with server/client architecture and port management) and mobile projects (with simplified environment setup). This enables working on multiple branches simultaneously without conflicts.

## Variables

```
PROJECT_CWD: . (current working directory - the main project root)
REPO_NAME: basename of PROJECT_CWD (e.g., "reellette-ios", "my-project")
BRANCH_NAME: $1 (required) - Can be local branch, remote branch (origin/feature-x), or new branch name
LOCAL_BRANCH_NAME: Derived from BRANCH_NAME (strips remote prefix if present)
IS_REMOTE_BRANCH: true if BRANCH_NAME starts with "origin/" or contains "/"
PORT_OFFSET: $2 (optional, defaults to auto-calculated based on existing worktrees, starts at 1)
PROJECT_TYPE: $3 (optional, defaults to "web", accepts "web" or "mobile")
WORKTREE_BASE_DIR: ../<REPO_NAME>-trees/
WORKTREE_DIR: ../<REPO_NAME>-trees/<LOCAL_BRANCH_NAME>
OPEN_BROWSER_WHEN_COMPLETE: false       # Set to true to auto-open browser after setup

# WEB PROJECT ONLY (when PROJECT_TYPE="web"):
SERVER_BASE_PORT: 4000
CLIENT_BASE_PORT: 5173
SERVER_PORT: 4000 + (PORT_OFFSET * 10)  # First worktree: 4010, Second: 4020, etc.
CLIENT_PORT: 5173 + (PORT_OFFSET * 10)  # First worktree: 5183, Second: 5193, etc.

NOTE: For web projects, main repo uses ports 4000 and 5173 (no offset)
      Worktrees start at offset 1 to avoid conflicts with main repo
      For mobile projects, port configuration is skipped entirely
```

## Instructions

### General (Both Project Types):
- This command creates a fully functional, isolated worktree in `../<REPO_NAME>-trees/` directory (at the same level as the project)
- Supports creating worktrees from:
  - Local branches (e.g., "feature/new-feature")
  - Remote branches (e.g., "origin/feature/new-feature")
  - New branch names (creates from current HEAD)
- If branch doesn't exist locally but exists remotely, creates local tracking branch
- All environment configuration must be worktree-specific
- Dependencies are installed automatically for each worktree
- Validation ensures the worktree is properly configured

### For Web Projects (PROJECT_TYPE="web"):
- Creates server/client architecture with port management
- Each worktree runs on unique ports to prevent conflicts when running in parallel
- Port offsets start at 1 and increment (1→4010/5183, 2→4020/5193, 3→4030/5203...)
- Main repo preserves default ports 4000/5173 for primary development work
- Database files are isolated per worktree (each gets its own events.db)
- Hook scripts will send events to the worktree's specific server instance
- After setup, automatically starts both server and client services
- The start script kills any existing processes on the target ports before starting
- Services run in the BACKGROUND
- Provide access URLs so user can immediately use the running instance

### For Mobile Projects (PROJECT_TYPE="mobile"):
- Simplified setup without port management or server/client architecture
- Copies root environment file for API keys and configuration
- Installs dependencies at project root only
- No service startup (mobile apps run via IDE/simulator)
- Provides instructions for opening project in Xcode/Android Studio

## Workflow

### 1. Parse and Validate Arguments

- Get repository name: `REPO_NAME=$(basename $(pwd))`
- Read BRANCH_NAME from $1, error if missing
- Detect if BRANCH_NAME is a remote branch:
  - Check if it contains "/" (e.g., "origin/feature-x")
  - Set IS_REMOTE_BRANCH=true if it's a remote branch
  - Extract LOCAL_BRANCH_NAME by removing remote prefix (e.g., "origin/feature-x" → "feature-x")
  - Command: `LOCAL_BRANCH_NAME=${BRANCH_NAME#origin/}` or similar parsing
- If not a remote branch, LOCAL_BRANCH_NAME = BRANCH_NAME
- Read PORT_OFFSET from $2 if provided
- Read PROJECT_TYPE from $3 if provided, defaults to "web"
- Validate PROJECT_TYPE is either "web" or "mobile"
- Validate branch name format (no spaces, valid git branch name)
- Construct WORKTREE_BASE_DIR as `../${REPO_NAME}-trees`

**For WEB projects only:**
- If PORT_OFFSET not provided, calculate next available offset:
  - List all existing worktrees: `git worktree list`
  - Check ../${REPO_NAME}-trees/ directory for existing worktrees
  - Count existing worktrees and use (count + 1) as offset (1, 2, 3, 4...)
  - IMPORTANT: Offset starts at 1 to preserve main repo ports (4000, 5173)
  - First worktree gets offset 1 → ports 4010, 5183
  - Second worktree gets offset 2 → ports 4020, 5193
- Calculate SERVER_PORT and CLIENT_PORT using offset * 10

**For MOBILE projects:**
- Skip port offset calculation and port assignments entirely

### 2. Pre-Creation Validation

- Check if ../${REPO_NAME}-trees/ directory exists, create if not: `mkdir -p ../${REPO_NAME}-trees`
- Note: No need to add to .gitignore since directory is outside project
- Check if worktree already exists at WORKTREE_DIR
- Fetch latest remote branches: `git fetch origin` (ensures remote branches are up to date)
- Check branch existence:
  - If IS_REMOTE_BRANCH is true:
    - Verify remote branch exists: `git branch -r --list <BRANCH_NAME>`
    - If doesn't exist, error with message "Remote branch not found"
    - Check if local tracking branch already exists: `git branch --list <LOCAL_BRANCH_NAME>`
  - If IS_REMOTE_BRANCH is false:
    - Check if local branch exists: `git branch --list <BRANCH_NAME>`
    - If doesn't exist, will create from HEAD in next step

**For WEB projects only:**
- Check if calculated ports are available:
  - Check SERVER_PORT: `lsof -i :SERVER_PORT` (should return nothing)
  - Check CLIENT_PORT: `lsof -i :CLIENT_PORT` (should return nothing)
  - If ports are in use, error with message to try different offset

**For MOBILE projects:**
- Skip port validation entirely

### 3. Create Git Worktree

**For Remote Branches:**
- If IS_REMOTE_BRANCH is true:
  - Create worktree with tracking branch: `git worktree add ../${REPO_NAME}-trees/<LOCAL_BRANCH_NAME> -b <LOCAL_BRANCH_NAME> --track <BRANCH_NAME>`
  - This creates a new local branch that tracks the remote branch
  - Example: `git worktree add ../reellette-ios-trees/feature-auth -b feature-auth --track origin/feature-auth`
  - The worktree directory uses the local branch name (without "origin/")
  - This creates WORKTREE_DIR at ../${REPO_NAME}-trees/<LOCAL_BRANCH_NAME>

**For Local Branches or New Branches:**
- If IS_REMOTE_BRANCH is false:
  - Create worktree with: `git worktree add ../${REPO_NAME}-trees/<BRANCH_NAME> <BRANCH_NAME>`
  - If branch doesn't exist, this creates it from HEAD
  - If branch exists, this checks it out in the worktree
  - This creates WORKTREE_DIR at ../${REPO_NAME}-trees/<BRANCH_NAME>

**Verification:**
- Verify worktree was created: `git worktree list | grep ${REPO_NAME}-trees/<LOCAL_BRANCH_NAME>`
- All subsequent operations will reference WORKTREE_DIR (which is ../${REPO_NAME}-trees/<LOCAL_BRANCH_NAME>)

### 3b. Setup Remote Tracking for New Branch

**Purpose:** Ensure the new branch has its own remote tracking branch instead of tracking the original branch.

**Steps:**

1. **Change to worktree directory:**
   - Execute: `cd ${WORKTREE_DIR}`
   - All git commands in this step run from the worktree context

2. **Remove any existing upstream tracking:**
   - Execute: `git branch --unset-upstream ${LOCAL_BRANCH_NAME} 2>/dev/null || true`
   - This removes tracking to the original remote branch (if any)
   - The `|| true` ensures the command doesn't fail if there was no upstream
   - **Why:** We want the new branch to have its own identity, not track another branch

3. **Push the new branch to origin and set up tracking:**
   - Execute: `git push -u origin ${LOCAL_BRANCH_NAME}`
   - This creates `origin/${LOCAL_BRANCH_NAME}` on the remote
   - The `-u` flag sets up tracking so `git pull` and `git push` work correctly
   - **Result:** The branch now tracks `origin/${LOCAL_BRANCH_NAME}` instead of the original branch

4. **Return to original directory:**
   - Execute: `cd ${PROJECT_CWD}`

**Why this matters:**
- When creating from a remote branch (e.g., `origin/main`), the local branch would track that remote
- This means `git pull` would pull from `main`, not from the feature branch
- By pushing immediately with `-u`, we create proper tracking for the feature branch
- Future `git push` and `git pull` operations work as expected

### 4. Setup Root Environment Files

- Check if root .env exists in main project at PROJECT_CWD/.env
- If PROJECT_CWD/.env exists:
  - Copy it to worktree root: `cp <PROJECT_CWD>/.env <WORKTREE_DIR>/.env`
  - Note: This preserves API keys (OPENAI_API_KEY, GOOGLE_CLOUD_CREDENTIALS, etc.)
- If PROJECT_CWD/.env doesn't exist:
  - Copy .env.sample if available: `cp <PROJECT_CWD>/.env.sample <WORKTREE_DIR>/.env`
  - Add warning to report that user needs to configure API keys

- Check if google-credentials.json exists in main project at PROJECT_CWD/google-credentials.json
- If PROJECT_CWD/google-credentials.json exists:
  - Copy it to worktree root: `cp <PROJECT_CWD>/google-credentials.json <WORKTREE_DIR>/google-credentials.json`
  - Note: This preserves Google Cloud service account credentials for OCR/Vision API

## 5. Copy Steps

### 5.a. Check for source configuration
- Verify `.claude/` directory exists at PROJECT_CWD
- If missing, skip this step (optional feature)

### 5.b. Remove any existing .claude in worktree
- Execute: `rm -rf ${WORKTREE_DIR}/.claude`
- This MUST succeed before copying to avoid nesting issues
- Verify removal: `test ! -d ${WORKTREE_DIR}/.claude`

### 5.c. Copy entire .claude directory
- Execute EXACTLY: `cp -R ${PROJECT_CWD}/.claude ${WORKTREE_DIR}/.claude`
- This explicitly names the destination as `.claude` (no trailing slash on source)
- **CRITICAL:** The destination MUST be `${WORKTREE_DIR}/.claude` (explicit target name)
- **DO NOT USE:** `cp -R .claude ${WORKTREE_DIR}/` - can cause issues if .claude exists
- **DO NOT USE:** `cp -R .claude/ ${WORKTREE_DIR}/.claude/` - trailing slashes cause nesting
- **What gets copied:**
  - commands/ - All slash commands
  - skills/ - All skills
  - tasks/ - Task templates
  - settings.json - Claude Code settings
  - Any custom utilities or scripts

### 5.d. Verify NO nesting occurred
- Check: `test ! -d ${WORKTREE_DIR}/.claude/.claude`
- If nested .claude exists, REMOVE IT: `rm -rf ${WORKTREE_DIR}/.claude/.claude`
- This is a critical safeguard against accidental nesting

### 5.e. Verify successful copy
- Check that key files exist: `test -d ${WORKTREE_DIR}/.claude/commands`
- If copy failed, log warning but continue

### 5.f. Handle missing configuration
- If .claude doesn't exist in main repo:
  - Log informational message
  - "No .claude configuration found to copy"
  - This is OK - worktree will work without it

**Benefits:**
- Immediate access to all custom commands in new worktree
- No need to reconfigure Claude Code for each worktree
- Consistent workflow across all branches
- Skills and automations work identically everywhere

### 6. Setup Project-Specific Environment

**For WEB projects:**

#### 6a. Setup Server Environment
- Create the file `WORKTREE_DIR/apps/server/.env` containing the following:
  ```
  SERVER_PORT=<calculated SERVER_PORT>
  DB_PATH=events.db
  ```
  - `SERVER_PORT` should be set to the unique port for this worktree (calculated from the main port plus the port offset).
  - `DB_PATH` is set to a relative filename (`events.db`), ensuring that each worktree’s server will use its own isolated database file inside the worktree's server directory.

#### 6b. Setup Client Environment
- Create the file `WORKTREE_DIR/apps/client/.env` containing configuration for the client:
  ```
  VITE_PORT=<calculated CLIENT_PORT>
  VITE_API_URL=http://localhost:<calculated SERVER_PORT>
  VITE_WS_URL=ws://localhost:<calculated SERVER_PORT>/stream
  VITE_MAX_EVENTS_TO_DISPLAY=100
  OBSERVABILITY_SERVER_URL=http://localhost:<calculated SERVER_PORT>/events
  ```
  - `VITE_PORT` must match the client port for this worktree (based on port offset).
  - `VITE_API_URL` and `VITE_WS_URL` should target the server port for this worktree, ensuring requests and websockets reach the right backend.
  - `OBSERVABILITY_SERVER_URL` must always point to `/events` on the corresponding server port, so observability data is recorded for this specific worktree.
  - `VITE_MAX_EVENTS_TO_DISPLAY` can typically remain at 100 unless the user specifies otherwise.

> These environment setups guarantee that worktrees do not conflict with each other—the client and server are always isolated via their env files and port assignments.

**For MOBILE projects:**
- Skip server and client environment setup (mobile projects only use root .env)

### 7. Install Dependencies

**For WEB projects:**
- Install server dependencies:
  - `cd <WORKTREE_DIR>/apps/server && bun install`
  - Verify WORKTREE_DIR/apps/server/node_modules directory was created
- Install client dependencies:
  - `cd <WORKTREE_DIR>/apps/client && bun install`
  - Verify WORKTREE_DIR/apps/client/node_modules directory was created
- Return to worktree root: `cd <WORKTREE_DIR>`

**For MOBILE projects:**
- Install dependencies at project root:
  - Detect package manager (check for package.json, Podfile, build.gradle)
  - If package.json exists: `cd <WORKTREE_DIR> && npm install` (or yarn/pnpm)
  - If Podfile exists: `cd <WORKTREE_DIR>/ios && pod install`
  - Verify node_modules directory was created at root
- Return to worktree root: `cd <WORKTREE_DIR>`

### 8. Validation

**For WEB projects:**
- Verify directory structure:
  - Confirm WORKTREE_DIR exists
  - Confirm WORKTREE_DIR/.env exists at root
  - Confirm WORKTREE_DIR/apps/server/.env exists
  - Confirm WORKTREE_DIR/apps/client/.env exists
  - Confirm WORKTREE_DIR/apps/server/node_modules exists
  - Confirm WORKTREE_DIR/apps/client/node_modules exists
- List worktrees to confirm: `git worktree list`
- Read back the created env files to confirm values are correct

**For MOBILE projects:**
- Verify directory structure:
  - Confirm WORKTREE_DIR exists
  - Confirm WORKTREE_DIR/.env exists at root
  - Confirm node_modules directory exists (or Pods directory for iOS)
- List worktrees to confirm: `git worktree list`
- Read back the root .env file to confirm values are correct

### 9. Start Services (WEB PROJECTS ONLY)

**For WEB projects:**
- Change to worktree directory: `cd <WORKTREE_DIR>`
- Start the system using the one-shot script in the BACKGROUND:
  - Command: `cd <WORKTREE_DIR> && SERVER_PORT=<calculated SERVER_PORT> CLIENT_PORT=<calculated CLIENT_PORT> sh scripts/start-system.sh > /dev/null 2>&1 &`
  - This runs WORKTREE_DIR/scripts/start-system.sh in background, redirecting output to suppress it
- The script will automatically:
  - Kill any existing processes on those ports
  - Start the server from WORKTREE_DIR/apps/server on the calculated port
  - Start the client from WORKTREE_DIR/apps/client on the calculated port
  - Wait for both services to be ready (health check)
- Give services 3-5 seconds to start before reporting
- Wait with: `sleep 5`
- Verify services are running:
  - Check server: `curl -s http://localhost:<SERVER_PORT>/events/filter-options >/dev/null 2>&1`
  - Check client: `curl -s http://localhost:<CLIENT_PORT> >/dev/null 2>&1`
- If health checks pass, services are confirmed running

**For MOBILE projects:**
- Skip service startup entirely (mobile apps are run via Xcode/Android Studio)

### 10. Open Dashboard in Chrome (WEB PROJECTS ONLY)

**For WEB projects:**
- ONLY if OPEN_BROWSER_WHEN_COMPLETE is true:
  - After services are confirmed running, open the dashboard in Chrome:
    - Command: `open -a "Google Chrome" http://localhost:<CLIENT_PORT>`
    - This automatically opens the worktree's dashboard in a new Chrome tab
    - If Chrome is not available, fall back to default browser: `open http://localhost:<CLIENT_PORT>`
  - Note: This happens in the background and doesn't block the report
- If OPEN_BROWSER_WHEN_COMPLETE is false, skip this step entirely

**For MOBILE projects:**
- Skip browser opening entirely

### 11. Report

Follow the Report section format below to provide comprehensive setup information.

## Report

After successful worktree creation and validation, provide a detailed report based on project type:

### For WEB Projects:

```
✅ Git Worktree Created and Started Successfully!

📁 Worktree Details:
   Location: ../<REPO_NAME>-trees/<BRANCH_NAME>
   Branch: <BRANCH_NAME>
   Remote: origin/<BRANCH_NAME> (tracking configured)
   Project Type: Web Application
   Status: 🟢 RUNNING

🔌 Port Configuration:
   Server Port: <SERVER_PORT>
   Client Port: <CLIENT_PORT>
   Port Offset: <PORT_OFFSET> (multiply by 10)

🌐 Access URLs (LIVE NOW):
   🖥️  Dashboard: http://localhost:<CLIENT_PORT>
   🔌 Server API: http://localhost:<SERVER_PORT>
   📡 WebSocket: ws://localhost:<SERVER_PORT>/stream

📦 Dependencies:
   ✓ Server dependencies installed (WORKTREE_DIR/apps/server/node_modules)
   ✓ Client dependencies installed (WORKTREE_DIR/apps/client/node_modules)

🗄️  Database:
   Path: WORKTREE_DIR/apps/server/events.db (isolated per worktree)

⚙️  Environment Files:
   ✓ Root .env (WORKTREE_DIR/.env with API keys)
   ✓ google-credentials.json (if exists - Google Cloud service account)
   ✓ Server .env (WORKTREE_DIR/apps/server/.env with SERVER_PORT, DB_PATH)
   ✓ Client .env (WORKTREE_DIR/apps/client/.env with VITE_PORT, API URLs)

🎯 Services Running:
   ✓ Server started on port <SERVER_PORT> (background)
   ✓ Client started on port <CLIENT_PORT> (background)
   ✓ WebSocket streaming active
   ✓ Ready to receive hook events

📝 Important Notes:
   • The services are running in the BACKGROUND
   • Services auto-started and will continue running until manually stopped
   • Open http://localhost:<CLIENT_PORT> in your browser NOW to view the dashboard
   • This worktree is completely isolated from the main codebase
   • You can run multiple worktrees simultaneously with different ports
   • Check running processes: lsof -i :<SERVER_PORT> and lsof -i :<CLIENT_PORT>

🔄 To Restart This Worktree Later:

   cd ../<REPO_NAME>-trees/<BRANCH_NAME>

   # Kill existing processes first
   lsof -ti :<SERVER_PORT> | xargs kill -9
   lsof -ti :<CLIENT_PORT> | xargs kill -9

   # Or use the one-shot script (it kills automatically)
   SERVER_PORT=<SERVER_PORT> CLIENT_PORT=<CLIENT_PORT> sh scripts/start-system.sh > /dev/null 2>&1 &

🧹 To Stop This Worktree:

   # Option 1: Manual kill
   lsof -ti :<SERVER_PORT> | xargs kill -9
   lsof -ti :<CLIENT_PORT> | xargs kill -9

   # Option 2: Use reset script (with environment variables)
   cd ../<REPO_NAME>-trees/<BRANCH_NAME>
   SERVER_PORT=<SERVER_PORT> CLIENT_PORT=<CLIENT_PORT> ./scripts/reset-system.sh

🗑️  To Remove This Worktree:

   # Stop services first (see above)

   # Then remove the worktree:
   git worktree remove ../<REPO_NAME>-trees/<BRANCH_NAME>

   # Or force remove if needed:
   git worktree remove ../<REPO_NAME>-trees/<BRANCH_NAME> --force

🎉 Next Steps:
   1. Open http://localhost:<CLIENT_PORT> in your browser NOW
   2. Open Claude Code in this worktree directory
   3. Run commands - events will stream to this isolated instance
   4. Compare side-by-side with other worktrees or main codebase
   5. Each instance maintains its own database and event history
```

### For MOBILE Projects:

```
✅ Git Worktree Created Successfully!

📁 Worktree Details:
   Location: ../<REPO_NAME>-trees/<BRANCH_NAME>
   Branch: <BRANCH_NAME>
   Remote: origin/<BRANCH_NAME> (tracking configured)
   Project Type: Mobile Application
   Status: 🟢 READY

📦 Dependencies:
   ✓ Node modules installed (if applicable)
   ✓ iOS Pods installed (if applicable)
   ✓ Ready for development

⚙️  Environment Files:
   ✓ Root .env (WORKTREE_DIR/.env with API keys and configuration)
   ✓ google-credentials.json (if exists - Google Cloud service account)

📝 Important Notes:
   • This worktree is completely isolated from the main codebase
   • You can work on multiple branches simultaneously
   • Each worktree maintains its own configuration and dependencies
   • No port conflicts as mobile projects run in simulators/devices

🚀 To Run This Worktree:

   # Navigate to the worktree
   cd ../<REPO_NAME>-trees/<BRANCH_NAME>

   # For iOS projects:
   open ios/<PROJECT_NAME>.xcworkspace
   # Then run from Xcode

   # For Android projects:
   open -a "Android Studio" android/
   # Then run from Android Studio

   # For React Native:
   npx react-native run-ios
   # or
   npx react-native run-android

🗑️  To Remove This Worktree:

   # Remove the worktree:
   git worktree remove ../<REPO_NAME>-trees/<BRANCH_NAME>

   # Or force remove if needed:
   git worktree remove ../<REPO_NAME>-trees/<BRANCH_NAME> --force

🎉 Next Steps:
   1. Navigate to ../<REPO_NAME>-trees/<BRANCH_NAME>
   2. Open the project in Xcode or Android Studio
   3. Run the app on your preferred simulator/device
   4. Make changes and test independently from main branch
   5. Each worktree maintains its own build artifacts and cache
```

### Common Section (Both Project Types):

If any validation steps failed or warnings occurred, include an additional section:

```
⚠️  Warnings / Action Required:
- <List any warnings or actions the user needs to take>
```
