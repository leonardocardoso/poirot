# Worktree Operations Guide

Detailed step-by-step instructions for each worktree operation, covering both web and mobile iOS projects.

## Project Type Detection

**ALWAYS start by detecting the project type** before choosing which command to use:

```bash
# Check for iOS/mobile project
ls *.xcodeproj *.xcworkspace 2>/dev/null || ls -d ios/*.xcodeproj ios/*.xcworkspace 2>/dev/null
```

**Decision:**
- If `.xcodeproj` or `.xcworkspace` found → **MOBILE iOS PROJECT**
- If `apps/server` and `apps/client` exist → **WEB PROJECT**
- Default if unclear → **WEB PROJECT**

---

## CREATE Operations

### For MOBILE iOS Projects

**When user wants to create a worktree for iOS:**

#### Step 1: Extract information
- **Feature title** (required) - Human-readable description of what they're building
  - Examples: "Improve search performance", "Add dark mode", "Fix auth bug"
- **JIRA ticket** (optional) - Ticket number if mentioned
  - Format: UPPERCASE-NUMBERS (e.g., "PTECH-503", "PE-12345")

#### Step 2: Invoke command
```
/create_mobile_worktree_prompt "<feature-title>" [jira-ticket]
```

**Examples:**
```bash
/create_mobile_worktree_prompt "Improve search performance" "PE-12345"
/create_mobile_worktree_prompt "Add dark mode support"
/create_mobile_worktree_prompt "Fix authentication bug" "PROJ-999"
```

#### Step 3: What happens automatically
The command handles:
- Generates kebab-case branch name from feature title
- Creates branch: `feature/<JIRA>-<kebab-case-title>` or `feature/<kebab-case-title>`
- Creates git worktree in `trees/<folder-prefix>-<branch-name>`
- Copies .claude configuration folder
- Ready to open in Xcode

**Branch naming examples:**
| Feature Title | JIRA Ticket | Generated Branch |
|--------------|-------------|------------------|
| "Improve search performance" | PE-12345 | `feature/PE-12345-improve-search-performance` |
| "Add dark mode" | - | `feature/add-dark-mode` |
| "Fix: Auth Bug!" | PROJ-999 | `feature/PROJ-999-fix-auth-bug` |

**Worktree directory naming:**
- Pattern: `trees/<current-folder>-<branch-name-without-prefix>`
- Example: `trees/reellette-ios-PE-12345-improve-search-performance`

#### Step 4: Share results with user
Include:
- Generated branch name
- Worktree location
- Instructions to open in Xcode
- .claude configuration copied status

**Example response:**
> I've created a worktree for "Improve search performance":
> - Branch: `feature/PE-12345-improve-search-performance`
> - Location: `trees/reellette-ios-PE-12345-improve-search-performance`
> - Open in Xcode: `cd trees/reellette-ios-PE-12345-improve-search-performance && open *.xcworkspace`
> - .claude configuration copied ✓

---

### For WEB Projects

**When user wants to create a worktree for web:**

#### Step 1: Extract information
- **Branch name** (required) - The git branch to create the worktree from
  - Should be explicit branch name (e.g., "feature-auth", "hotfix-security")
- **Port offset** (optional) - Custom port offset, defaults to auto-calculated
  - Number (1, 2, 3, etc.)

#### Step 2: Invoke command
```
/create_worktree_prompt <branch-name> [port-offset] web
```

**Examples:**
```bash
/create_worktree_prompt feature-authentication
/create_worktree_prompt hotfix-security 3 web
/create_worktree_prompt refactor-api 2 web
```

#### Step 3: What happens automatically
The command handles:
- Creates git worktree in `trees/<branch-name>`
- Calculates unique ports (auto if offset not provided)
- Sets up all environment files (.env files with SERVER_PORT, VITE_PORT)
- Installs dependencies (npm/bun install in apps/server and apps/client)
- Starts services in background (server + client)
- Provides access URLs

**Port calculation (all configured in .env):**

| Variable | Base | Formula | Offset 1 | Offset 2 |
|----------|------|---------|----------|----------|
| `PORT` (API) | 4000 | 4000 + (offset * 10) | 4010 | 4020 |
| `DASHBOARD_PORT` | 3000 | 3000 + (offset * 10) | 3010 | 3020 |
| `WEBSITE_PORT` | 8080 | 8080 + (offset * 10) | 8090 | 8100 |
| `POSTGRES_PORT` | 5432 | 5432 + (offset * 10) | 5442 | 5452 |
| `REDIS_PORT` | 6379 | 6379 + (offset * 10) | 6389 | 6399 |

Additional `.env` variables:
- `COMPOSE_PROJECT_NAME=ignio-{branch-name}` - Isolates Docker containers
- `DATABASE_URL=postgresql://ignio:ignio@localhost:{POSTGRES_PORT}/ignio`
- `REDIS_URL=redis://localhost:{REDIS_PORT}`

#### Step 4: Share results with user
Include:
- Dashboard URL (e.g., http://localhost:5183/dashboard)
- Configured ports (server + client)
- How to access the running services
- Location of worktree directory

**Example response:**
> I've created a worktree for `feature-authentication`:
> - Location: `trees/feature-authentication`
> - **API**: http://localhost:4010 (PORT=4010)
> - **Dashboard**: http://localhost:3010 (DASHBOARD_PORT=3010)
> - **Website**: http://localhost:8090 (WEBSITE_PORT=8090)
> - **PostgreSQL**: localhost:5442 (POSTGRES_PORT=5442)
> - **Redis**: localhost:6389 (REDIS_PORT=6389)
> - Docker Compose: `ignio-feature-authentication`
> - Services are running in the background ✓

---

### For MONOREPO Projects (Turborepo/pnpm)

**When user wants to create a worktree for a monorepo (e.g., IGNIO):**

Uses same commands as web projects, but with additional configuration steps.

#### Step 1: Extract information (same as web)
- **Branch name** (required) - The git branch name
- **Port offset** (optional) - Custom port offset

#### Step 2: Invoke command (same as web)
```
/create_worktree_prompt <branch-name> [port-offset] web
```

#### Step 3: Configure Docker Compose Isolation

After worktree creation, set `COMPOSE_PROJECT_NAME` to match the branch name:

```bash
WORKTREE_PATH="../ignio-trees/<branch-name>"
BRANCH_NAME=$(git -C "$WORKTREE_PATH" branch --show-current)

# Add or update COMPOSE_PROJECT_NAME in .env
if grep -q "^COMPOSE_PROJECT_NAME=" "$WORKTREE_PATH/.env" 2>/dev/null; then
    sed -i '' "s/^COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=ignio-$BRANCH_NAME/" "$WORKTREE_PATH/.env"
else
    echo "COMPOSE_PROJECT_NAME=ignio-$BRANCH_NAME" >> "$WORKTREE_PATH/.env"
fi
```

This ensures each worktree's Docker containers don't conflict with containers from other worktrees.

#### Step 4: Create .env Symlinks for All Apps

In monorepos, each app only loads `.env` from its own directory. Create symlinks to the worktree root `.env`:

```bash
WORKTREE_PATH="../ignio-trees/<branch-name>"

# Find all app directories and create .env symlinks
for app_dir in "$WORKTREE_PATH"/apps/*/; do
    if [ -d "$app_dir" ]; then
        # Remove existing .env if present (not a symlink)
        [ -f "${app_dir}.env" ] && [ ! -L "${app_dir}.env" ] && rm "${app_dir}.env"
        # Create symlink to root .env
        ln -sf "../../.env" "${app_dir}.env"
        echo "Created symlink: ${app_dir}.env -> ../../.env"
    fi
done
```

**Why symlinks (not copies):**
- Single source of truth: all apps read from root `.env`
- Changes to root `.env` immediately affect all apps
- No risk of env vars getting out of sync
- `PORT`, `NEXT_PUBLIC_*`, etc. are consistent everywhere

**IMPORTANT - Dashboard must use `.env`, not `.env.local`:**
- All apps should use `.env` symlinks for consistency
- The symlink ensures `PORT` is read correctly for API URL construction
- This fixes issues where Google OAuth redirects to wrong port

#### Step 5: Install Partner Framework (if available)

Check if `partner-framework.zip` exists and install it:

```bash
if [ -f "partner-framework.zip" ]; then
    WORKTREE_PATH="../ignio-trees/<branch-name>"
    cp partner-framework.zip "$WORKTREE_PATH/"
    cd "$WORKTREE_PATH"
    unzip -o partner-framework.zip
    ./partner-framework/install.sh --all
    rm partner-framework.zip
fi
```

#### Step 6: Share results with user

Include everything from web projects, plus:
- Docker Compose project name
- .env.local symlinks created
- Partner Framework status

**Example response:**
> I've created a monorepo worktree for `feature-auth`:
> - Location: `../ignio-trees/feature-auth`
> - **API**: http://localhost:4010 (PORT=4010)
> - **Dashboard**: http://localhost:3010 (DASHBOARD_PORT=3010)
> - **Website**: http://localhost:8090 (WEBSITE_PORT=8090)
> - **PostgreSQL**: localhost:5442 (POSTGRES_PORT=5442)
> - **Redis**: localhost:6389 (REDIS_PORT=6389)
> - Docker Compose: `ignio-feature-auth` (isolated containers)
> - .env symlinks created for all apps ✓
> - Partner Framework installed ✓
>
> **To start:** `cd ../ignio-trees/feature-auth && pnpm dev`

---

## LIST Operations

**When user wants to see worktrees:**

### For ALL Project Types

#### Step 1: Invoke command
```
/list_worktrees_prompt
```

#### Step 2: What the command shows

**For WEB worktrees:**
- All existing worktrees with their paths
- Port configuration for each (server + client)
- Service status (running/stopped with PIDs)
- Access URLs for each worktree
- Quick action commands for management

**For MOBILE iOS worktrees:**
- All existing worktrees with their paths (may have folder prefix)
- Branch name
- .claude configuration status
- iOS project info (.xcodeproj or .xcworkspace)
- Status (READY)
- Quick action commands

#### Step 3: Share the overview with user
Highlight:
- Which worktrees are currently running (web only)
- How to access each one
- Any issues or conflicts
- Total worktree count
- Next available port offset (web only)

**Example response for mixed projects:**
> Here are your worktrees:
>
> **Web Worktrees:**
> 1. feature-auth (ports 4010/5183) - Running ✓
> 2. hotfix-bug (ports 4020/5193) - Stopped
>
> **Mobile iOS Worktrees:**
> 1. feature/PE-12345-improve-search (reellette-ios-PE-12345-improve-search) - Ready ✓
> 2. feature/add-dark-mode (reellette-ios-add-dark-mode) - Ready ✓
>
> Total: 4 worktrees (2 web, 2 mobile)

---

## REMOVE Operations

**When user wants to remove a worktree:**

### For MOBILE iOS Projects

#### Step 1: Extract information
- **Branch name** (required) - The name of the branch to remove
  - May include full branch path (e.g., `feature/PTECH-503-improve-search`)
  - Or just the feature portion (e.g., `PTECH-503-improve-search`)

#### Step 2: Invoke command
```
/remove_worktree_prompt <branch-name>
```

**Examples:**
```bash
/remove_worktree_prompt feature/PE-12345-improve-search-performance
/remove_worktree_prompt feature/add-dark-mode
```

#### Step 3: What happens automatically
The command handles:
- Finds worktree (may have folder prefix like `trees/reellette-ios-...`)
- Removes git worktree
- Deletes git branch (PERMANENT)
- Cleans up directories
- Validates complete removal
- Reports success or any issues

**Note:** No service shutdown needed for mobile projects

#### Step 4: Confirm removal with user
Share:
- Confirmation that worktree was removed
- Branch deletion confirmation (PERMANENT)
- Any cleanup actions performed

**Example response:**
> Successfully removed the worktree:
> - Branch: `feature/PE-12345-improve-search-performance`
> - Worktree: `trees/reellette-ios-PE-12345-improve-search-performance`
> - Both worktree and branch have been permanently deleted ✓

---

### For WEB Projects

#### Step 1: Extract information
- **Branch name** (required) - The name of the worktree to remove
  - Should match the branch name used in creation

#### Step 2: Invoke command
```
/remove_worktree_prompt <branch-name>
```

**Examples:**
```bash
/remove_worktree_prompt feature-authentication
/remove_worktree_prompt hotfix-security
```

#### Step 3: What happens automatically
The command handles:
- Identifies ports from .env files
- Stops running services (server + client)
- Kills processes on worktree ports
- Removes git worktree
- Deletes git branch (PERMANENT)
- Cleans up directories
- Validates complete removal
- Reports success or any issues

#### Step 4: Confirm removal with user
Share:
- Confirmation that worktree was removed
- Services that were stopped
- Ports that were freed
- Branch deletion confirmation
- Any cleanup actions performed

**Example response:**
> Successfully removed the worktree:
> - Branch: `feature-authentication`
> - Stopped API server on port 4010 ✓
> - Stopped dashboard on port 3010 ✓
> - Freed ports: 4010 (API), 3010 (Dashboard), 5442 (Postgres), 6389 (Redis)
> - Docker containers `ignio-feature-authentication` stopped ✓
> - Both worktree and branch have been permanently deleted ✓

---

## Common Workflows

### Multiple Worktree Creation

**User wants multiple worktrees:**

#### For Mobile iOS:
```bash
/create_mobile_worktree_prompt "Feature A" "PE-100"
/create_mobile_worktree_prompt "Feature B" "PE-101"
/create_mobile_worktree_prompt "Feature C"
```

Each gets:
- Unique branch name
- Unique worktree directory
- Independent .claude config

#### For Web:
```bash
/create_worktree_prompt feature-a
/create_worktree_prompt feature-b
/create_worktree_prompt feature-c
```

Each gets:
- Unique ports (auto-calculated per offset):
  - feature-a: API 4010, Dashboard 3010, Website 8090, Postgres 5442, Redis 6389
  - feature-b: API 4020, Dashboard 3020, Website 8100, Postgres 5452, Redis 6399
  - feature-c: API 4030, Dashboard 3030, Website 8110, Postgres 5462, Redis 6409
- Independent Docker Compose containers (`ignio-{branch}`)
- Independent services and databases
- Independent .env files with all ports configured

---

### Status Check Workflow

**User wants to check all worktrees:**

1. Run `/list_worktrees_prompt`
2. Analyze output for both web and mobile
3. Highlight any issues:
   - Stopped services (web)
   - Port conflicts (web)
   - Orphaned worktrees
   - Missing .claude config

---

### Cleanup Workflow

**User wants to clean up old worktrees:**

1. Run `/list_worktrees_prompt` to see all worktrees
2. Identify worktrees to remove
3. For each worktree:
   - Run `/remove_worktree_prompt <branch-name>`
   - Confirm removal completed
4. Run `/list_worktrees_prompt` again to verify

---

## Error Handling

### Mobile iOS Project Errors

**Common issues:**
- **Missing feature title**: Ask user what they want to work on
- **Branch already exists**: Use different feature description or remove existing
- **Worktree already exists**: Remove existing worktree first
- **Folder prefix confusion**: Use `git worktree list | grep <branch>` to find actual worktree

### Web Project Errors

**Common issues:**
- **Port conflicts**: Use explicit port offset or remove old worktrees
- **Services won't start**: Check logs, verify dependencies installed
- **Branch already has worktree**: Remove existing worktree first
- **Missing .env files**: Recreate worktree (may be corrupted)

---

## Best Practices

### For Mobile iOS:
✓ Use descriptive feature titles
✓ Include JIRA tickets when available
✓ Open in Xcode immediately after creation
✓ Remove worktrees when feature is merged

### For Web:
✓ Use meaningful branch names
✓ Let port offset auto-calculate
✓ Access dashboard to verify services running
✓ Remove worktrees to free up ports

### For Both:
✓ Regularly run `/list_worktrees_prompt` to audit
✓ Remove merged/abandoned worktrees promptly
✓ Don't manually edit git worktrees
✓ Use slash commands for all operations
