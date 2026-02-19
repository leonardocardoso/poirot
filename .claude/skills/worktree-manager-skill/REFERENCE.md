# Worktree Quick Reference

Technical details, command syntax, and configuration reference for both web and mobile iOS projects.

---

## Command Syntax

### Mobile iOS Commands

#### Create Mobile Worktree
```bash
/create_mobile_worktree_prompt "<feature-title>" [jira-ticket]
```

**Parameters:**
- `feature-title` (required) - Human-readable feature description
  - Will be converted to kebab-case for branch name
  - Examples: "Improve search performance", "Add dark mode"
- `jira-ticket` (optional) - JIRA ticket number (UPPERCASE-NUMBERS)
  - Examples: "PTECH-503", "PE-12345", "PROJ-999"

**Example:**
```bash
/create_mobile_worktree_prompt "Improve search performance" "PE-12345"
/create_mobile_worktree_prompt "Add dark mode support"
```

**Result:**
- Branch: `feature/[JIRA]-kebab-case-title` or `feature/kebab-case-title`
- Worktree: `trees/<folder-prefix>-[JIRA]-kebab-case-title`
- .claude config copied

---

### Web Commands

#### Create Web Worktree
```bash
/create_worktree_prompt <branch-name> [port-offset] [project-type]
```

**Parameters:**
- `branch-name` (required) - Name of the git branch
- `port-offset` (optional) - Port offset number (default: auto-calculated)
- `project-type` (optional) - "web" or "mobile" (default: "web")

**Example:**
```bash
/create_worktree_prompt feature-auth
/create_worktree_prompt hotfix-bug 3 web
```

**Result:**
- Worktree: `trees/<branch-name>`
- Ports: SERVER_PORT = 4000 + (offset * 10), CLIENT_PORT = 5173 + (offset * 10)
- Services auto-started

---

### Universal Commands

#### List Worktrees
```bash
/list_worktrees_prompt
```

**Parameters:** None

**Output includes:**
- **For Web:** Worktree paths, port configurations, service status with PIDs, access URLs
- **For Mobile iOS:** Worktree paths (with folder prefix), branch names, .claude config status, iOS project info
- **Summary:** Total count, web vs mobile breakdown, next available port offset (web)

---

#### Remove Worktree
```bash
/remove_worktree_prompt <branch-name>
```

**Parameters:**
- `branch-name` (required) - Name of the worktree to remove
  - For mobile: May include full path like `feature/PTECH-503-improve-search`
  - For web: Simple branch name like `feature-auth`

**Example:**
```bash
/remove_worktree_prompt feature/PE-12345-improve-search-performance
/remove_worktree_prompt feature-authentication
```

**Result:**
- Git worktree removed
- Git branch deleted (PERMANENT)
- Services stopped (web only)
- Directories cleaned up

---

## Branch Naming

### Mobile iOS Branch Naming

**Pattern:** `feature/[JIRA]-<kebab-case-title>` or `feature/<kebab-case-title>`

**Kebab-Case Conversion:**
1. Convert to lowercase
2. Replace spaces with hyphens
3. Remove special characters (keep only letters, numbers, hyphens)
4. Remove leading/trailing hyphens
5. Collapse multiple consecutive hyphens

**Examples:**

| Feature Title | JIRA | Generated Branch |
|--------------|------|------------------|
| "Improve search performance" | PE-12345 | `feature/PE-12345-improve-search-performance` |
| "Add Dark Mode Support" | - | `feature/add-dark-mode-support` |
| "Fix: Auth Bug!" | PROJ-999 | `feature/PROJ-999-fix-auth-bug` |
| "Split Discover/Catalog code" | PTECH-100 | `feature/PTECH-100-split-discover-catalog-code` |

### Web Branch Naming

**Pattern:** User-specified explicit branch names

**Examples:**
- `feature-authentication`
- `hotfix-security-patch`
- `refactor-api-layer`

---

## Worktree Directory Naming

### Mobile iOS Worktree Directories

**Pattern:** `trees/<current-folder>-<branch-name-without-prefix>`

**Examples:**

| Current Folder | Branch Name | Worktree Directory |
|---------------|-------------|-------------------|
| reellette-ios | `feature/PTECH-503-improve-search` | `trees/reellette-ios-PTECH-503-improve-search` |
| reellette-ios | `feature/add-dark-mode` | `trees/reellette-ios-add-dark-mode` |
| my-ios-app | `feature/PE-100-offline-mode` | `trees/my-ios-app-PE-100-offline-mode` |

### Web Worktree Directories

**Pattern:** `trees/<branch-name>`

**Examples:**
- `trees/feature-auth`
- `trees/hotfix-security`
- `trees/refactor-api`

---

## Port Allocation (Web Projects Only)

### Port Calculation Formula

All ports are configured in the root `.env` file:

```
PORT = 4000 + (offset * 10)              # API server
DASHBOARD_PORT = 3000 + (offset * 10)    # Dashboard (Next.js)
POSTGRES_PORT = 5432 + (offset * 10)     # PostgreSQL database
REDIS_PORT = 6379 + (offset * 10)        # Redis cache/queue
```

### Complete Port Map

| Environment | Offset | API (PORT) | Dashboard | Postgres | Redis | Docker Compose Name |
|-------------|--------|------------|-----------|----------|-------|---------------------|
| Main Repo   | 0      | 4000       | 3000      | 5432     | 6379  | ignio               |
| Worktree 1  | 1      | 4010       | 3010      | 5442     | 6389  | ignio-{branch}      |
| Worktree 2  | 2      | 4020       | 3020      | 5452     | 6399  | ignio-{branch}      |
| Worktree 3  | 3      | 4030       | 3030      | 5462     | 6409  | ignio-{branch}      |
| Worktree 4  | 4      | 4040       | 3040      | 5472     | 6419  | ignio-{branch}      |
| Worktree 5  | 5      | 4050       | 3050      | 5482     | 6429  | ignio-{branch}      |

### .env Variables for Worktrees

Each worktree's `.env` file must include:

```env
# Port Configuration
PORT=4010                    # API server port
DASHBOARD_PORT=3010          # Dashboard port
POSTGRES_PORT=5442           # PostgreSQL port
REDIS_PORT=6389              # Redis port

# Docker Compose Isolation
COMPOSE_PROJECT_NAME=ignio-feature-name

# Database URLs (use POSTGRES_PORT)
DATABASE_URL=postgresql://ignio:ignio@localhost:5442/ignio
DIRECT_DATABASE_URL=postgresql://ignio:ignio@localhost:5442/ignio

# Redis URL (use REDIS_PORT)
REDIS_URL=redis://localhost:6389

# Dashboard API connection (use PORT)
NEXT_PUBLIC_API_URL=http://localhost:4010
```

### Auto-calculated Offsets
When no port offset is specified:
1. Lists existing worktrees
2. Finds highest used offset
3. Increments by 1
4. Uses that as the new offset

**Note:** Offset starts at 1 (not 0) to preserve main repo ports.

### Mobile iOS Port Allocation

**N/A** - Mobile iOS projects don't use port management. Apps run in Xcode/simulators/devices, not as background services.

---

## Directory Structure

### Mobile iOS Project Structure

#### Main Repository
```
reellette-ios/
├── .claude/
│   ├── settings.json
│   ├── commands/
│   └── skills/
├── Reellette.xcworkspace
├── Reellette.xcodeproj
├── Reellette/
├── ReelletteTests/
└── trees/           # Worktrees created here
```

#### Mobile Worktree Structure
```
reellette-ios/
└── trees/
    └── reellette-ios-PTECH-503-improve-search/
        ├── .claude/
        │   ├── settings.json (copied from main)
        │   ├── commands/ (copied from main)
        │   └── skills/ (copied from main)
        ├── Reellette.xcworkspace
        ├── Reellette.xcodeproj
        ├── Reellette/
        └── ReelletteTests/
```

**Key Points:**
- Complete copy of codebase on different branch
- .claude folder copied for consistent Claude Code experience
- No dependency installation (npm/pods not pre-installed)
- No .env copying (mobile apps get config from main)
- Ready to open in Xcode immediately

---

### Web Project Structure

#### Main Repository
```
project/
├── .claude/
│   ├── settings.json
│   └── commands/
├── .env (root-level API keys)
├── apps/
│   ├── server/
│   │   ├── .env (SERVER_PORT, DB_PATH)
│   │   ├── package.json
│   │   └── src/
│   └── client/
│       ├── .env (VITE_PORT, VITE_API_URL, etc.)
│       ├── package.json
│       └── src/
└── trees/           # Worktrees created here
```

#### Web Worktree Structure
```
project/
└── trees/
    └── feature-auth/
        ├── .claude/
        │   └── settings.json (isolated config)
        ├── .env (copied from main with API keys)
        ├── apps/
        │   ├── server/
        │   │   ├── .env (unique SERVER_PORT, DB_PATH)
        │   │   ├── node_modules/ (installed)
        │   │   └── src/
        │   └── client/
        │       ├── .env (unique VITE_PORT, API URLs)
        │       ├── node_modules/ (installed)
        │       └── src/
```

**Key Points:**
- Complete isolation of configuration
- Dependencies installed per worktree
- Unique ports prevent conflicts
- Services auto-started

---

### Monorepo Project Structure (Turborepo/pnpm)

#### Main Repository
```
ignio/
├── .claude/
│   ├── settings.json
│   ├── commands/
│   └── skills/
├── .env (root - all environment variables)
├── turbo.json
├── pnpm-workspace.yaml
├── apps/
│   ├── api/            # Fastify API server
│   ├── worker/         # BullMQ job processors
│   ├── dashboard/      # Next.js dashboard
│   └── website/        # Marketing website (Jekyll)
├── packages/
│   ├── database/       # Prisma schema
│   ├── config/         # Environment config
│   ├── shared/         # Shared utilities
│   └── i18n/           # Internationalization
├── docker-compose.yml
└── partner-framework/  # Optional orchestration tools
```

#### Monorepo Worktree Structure
```
ignio-trees/
└── feature-auth/
    ├── .claude/
    │   └── settings.json (copied from main)
    ├── .env (copied + ports updated)
    ├── apps/
    │   ├── api/
    │   ├── worker/
    │   ├── dashboard/
    │   │   └── .env.local -> ../../.env (symlink)
    │   └── website/
    │       └── .env.local -> ../../.env (symlink)
    ├── packages/
    │   └── database/
    │       └── dev.db (isolated database)
    ├── docker-compose.yml
    └── partner-framework/ (installed from zip)
```

**Key Points:**
- Root `.env` contains all configuration (ports, keys, URLs)
- `.env.local` symlinks in each app point to root `.env`
- `COMPOSE_PROJECT_NAME` isolates Docker containers per worktree
- Partner Framework copied and installed if available
- No auto-start services (use `pnpm dev` or `turbo dev`)
- Database isolated via unique `POSTGRES_PORT`

**Monorepo-specific .env variables:**
```env
# Docker Compose isolation
COMPOSE_PROJECT_NAME=ignio-feature-auth

# Isolated ports (offset 1)
PORT=4010
DASHBOARD_PORT=3010
POSTGRES_PORT=5442
REDIS_PORT=6389

# Database URLs using worktree-specific port
DATABASE_URL=postgresql://ignio:ignio@localhost:5442/ignio
DIRECT_DATABASE_URL=postgresql://ignio:ignio@localhost:5442/ignio
REDIS_URL=redis://localhost:6389

# Dashboard API connection
NEXT_PUBLIC_API_URL=http://localhost:4010
```

---

## Configuration Files

### Mobile iOS Configuration

#### .claude/ Directory (Copied to Worktree)
```
.claude/
├── settings.json
├── commands/
│   ├── create_mobile_worktree_prompt.md
│   ├── list_worktrees_prompt.md
│   └── remove_worktree_prompt.md
└── skills/
    └── create-worktree-skill/
```

**What gets copied:**
- All slash commands
- All skills
- settings.json configuration
- Task templates
- Any custom utilities

**Why this matters:**
- Consistent Claude Code experience across worktrees
- Same commands available everywhere
- Same skills and automations
- No reconfiguration needed

---

### Web Configuration

#### Root .env (Copied to Worktree)
```env
ANTHROPIC_API_KEY=sk-...
OPENAI_API_KEY=sk-...
# Other API keys and root-level config
```

#### apps/server/.env (Worktree-specific)
```env
SERVER_PORT=4010
DB_PATH=events.db
```

#### apps/client/.env (Worktree-specific)
```env
VITE_PORT=5183
VITE_API_URL=http://localhost:4010
VITE_WS_URL=ws://localhost:4010/stream
VITE_MAX_EVENTS_TO_DISPLAY=100
OBSERVABILITY_SERVER_URL=http://localhost:4010/events
```

#### .claude/settings.json (Worktree-specific)
```json
{
  "hooks": {
    "userPromptSubmit": {
      "script": "...",
      "env": {
        "AGENT_SERVER_URL": "http://localhost:4010"
      }
    }
  }
}
```

---

## Service Management (Web Only)

### What Runs in a Web Worktree
1. **Server** - Backend API (Express/Node/Bun)
   - Runs on SERVER_PORT
   - Isolated database (events.db in worktree)
2. **Client** - Frontend dev server (Vite)
   - Runs on CLIENT_PORT
   - Connects to worktree's server

### Background Process Management
- Services run in detached background processes
- PIDs tracked for process management
- Automatic cleanup on removal
- Force-kill on stuck processes

### Service States
- **Running** - Process active with valid PID
- **Stopped** - No process running
- **Zombie** - PID exists but process unresponsive

### Mobile iOS Service Management

**N/A** - Mobile iOS projects don't run background services. Apps are run through:
- Xcode (⌘+R to run)
- iOS Simulator
- Physical iOS devices
- No process management needed

---

## Git Worktree Fundamentals

### What is a Git Worktree?
A git worktree is an additional working directory attached to the same repository. Multiple worktrees can exist simultaneously, each checked out to different branches.

### Benefits
- Work on multiple branches simultaneously
- No need to stash/switch branches
- Isolated development environments
- Test multiple features in parallel
- Compare implementations side-by-side

### Limitations
- Each branch can only be checked out in one worktree at a time
- Worktrees share git history/objects (same .git database)
- Disk space required for each copy of working directory

---

## Isolation Features

### Mobile iOS Worktrees

| Feature | Isolation Level | Notes |
|---------|----------------|-------|
| **File System** | Complete | Separate working directory |
| **Branch** | Complete | Different branch checked out |
| **Configuration** | Complete | Own .claude folder copied |
| **Build Artifacts** | Complete | Separate DerivedData per worktree |
| **Git History** | Shared | Same repository |
| **Git Config** | Shared | Same git settings |
| **Xcode Project** | Complete | Can be opened simultaneously in Xcode |
| **Ports** | N/A | No server/client processes |
| **Dependencies** | N/A | Not pre-installed |

### Web Worktrees

| Feature | Isolation Level | Notes |
|---------|----------------|-------|
| **File System** | Complete | Separate working directory |
| **Ports** | Complete | Unique port allocation |
| **Configuration** | Complete | Own .env and settings.json |
| **Database** | Complete | Separate events.db |
| **Dependencies** | Complete | Own node_modules |
| **Git History** | Shared | Same repository |
| **Git Config** | Shared | Same git settings |

---

## Project Type Detection

### Detection Command
```bash
# Check for iOS/mobile project
ls *.xcodeproj *.xcworkspace 2>/dev/null || ls -d ios/*.xcodeproj ios/*.xcworkspace 2>/dev/null
```

### Mobile iOS Indicators
- `*.xcodeproj` files in root or ios/ directory
- `*.xcworkspace` files in root or ios/ directory
- Xcode project structure

### Web Indicators
- `apps/server/` directory exists
- `apps/client/` directory exists
- Server/client architecture
- package.json in multiple locations

### Default Behavior
If project type is unclear, defaults to **WEB** project type.

---

## Related Capabilities

### Main Repository
- **Web:** Default environment, uses ports 4000 and 5173, can run alongside worktrees
- **Mobile iOS:** Default development environment, can have code open in Xcode while worktrees also open

### Parallel Development

**Web:**
- Run main + multiple worktrees simultaneously
- Each on unique ports
- No conflicts between environments
- Test features against different bases

**Mobile iOS:**
- Open multiple worktrees in Xcode simultaneously
- Run different branches in simulators
- Compare implementations side-by-side
- Test features independently

### Branch Preservation
- **Both:** Removing a worktree doesn't delete the branch (but our commands do delete it - PERMANENT)
- Branch exists in git after removal (if not using our commands)
- Can recreate worktree anytime from existing branch
- Safe to cleanup unused worktrees if branch is preserved elsewhere (e.g., pushed to remote)

### Service Lifecycle

**Web:**
- Services start automatically on creation
- Run in background until removal
- Can be restarted manually if needed
- Stopped automatically on removal

**Mobile iOS:**
- No services to manage
- Run app via Xcode when needed
- Simulator/device lifecycle managed by Xcode
- No cleanup needed on worktree removal

---

## Best Practices

### When to Create Worktrees

**Mobile iOS:**
✓ Working on multiple features simultaneously
✓ Comparing different implementation approaches
✓ Testing features independently
✓ Keeping JIRA tickets organized by worktree
✓ Reviewing PRs while working on features

**Web:**
✓ Testing multiple features simultaneously
✓ Reviewing PRs while working on features
✓ Hot-fixing production while developing
✓ Running integration tests in isolation
✓ Comparing performance across branches

### When NOT to Create Worktrees

**Both:**
✗ Simple branch switching (use `git checkout`)
✗ Temporary file viewing (use `git show`)
✗ Quick edits (stash and switch)
✗ One-time experiments (use stash or temp branch)

### Cleanup Recommendations

**Both:**
- Remove worktrees when feature is merged
- Don't let unused worktrees accumulate
- Regular audit with `/list_worktrees_prompt`
- Our commands delete branches permanently - ensure work is pushed first

**Web Specific:**
- Free up ports for active development
- Remove worktrees with stopped services

### Naming Conventions

**Mobile iOS:**
- Use descriptive feature titles
- Include JIRA tickets when available
- Natural language descriptions (will be converted to kebab-case)
- Examples: "Improve search", "Add dark mode", "Fix auth bug"

**Web:**
- Use descriptive branch names
- Avoid special characters
- Keep names concise
- Match team branch naming scheme
- Examples: "feature-auth", "hotfix-security", "refactor-api"

---

## Technical Implementation

### Mobile iOS Creation Process
1. Parse feature title and optional JIRA ticket
2. Convert feature title to kebab-case
3. Generate branch name: `feature/[JIRA]-kebab-case-title`
4. Create git worktree with folder-prefixed directory name
5. Copy .claude configuration folder
6. Verify .claude copy successful
7. Report worktree details (branch, location, Xcode command)

### Web Creation Process
1. Validate branch exists or can be created
2. Calculate/verify port offset
3. Create git worktree
4. Copy configuration templates
5. Update ports in configs
6. Install dependencies (bun/npm install)
7. Start services in background
8. Verify startup successful
9. Report access info (URLs, ports)

### Removal Process (Both)
1. Find worktree (may need to search for folder prefix on mobile)
2. **Web only:** Find processes on worktree ports, kill server/client processes
3. Remove git worktree
4. Delete git branch (PERMANENT)
5. Clean up directories
6. Validate removal
7. Report results

### Status Checking
1. List git worktrees
2. Detect project type for each
3. **Web:** Read configuration for each, check if processes running, verify port accessibility
4. **Mobile:** Check .claude config status, verify iOS project files
5. Generate comprehensive report

---

## Command Reference Summary

| Operation | Mobile iOS | Web |
|-----------|-----------|-----|
| **Create** | `/create_mobile_worktree_prompt "<title>" [jira]` | `/create_worktree_prompt <branch> [offset] web` |
| **List** | `/list_worktrees_prompt` | `/list_worktrees_prompt` |
| **Remove** | `/remove_worktree_prompt <branch>` | `/remove_worktree_prompt <branch>` |
| **Input** | Feature description + JIRA | Branch name + port offset |
| **Output** | Branch + folder-prefixed directory | Branch + simple directory |
| **Services** | None (Xcode) | Auto-started (server + client) |
| **Config** | .claude copied | .claude + .env files |
