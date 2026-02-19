---
name: worktree-manager
description: Comprehensive git worktree management for web and mobile iOS projects. Use when the user wants to create, remove, list, or manage worktrees. Handles all worktree operations including creation, deletion, and status checking with automatic project type detection.
allowed-tools: SlashCommand, Bash, Read, Write, Edit, Glob, Grep
---

# Worktree Manager Skill

Complete worktree lifecycle management for parallel development environments. Automatically detects project type (web or mobile iOS) and uses appropriate commands with proper isolation for ports, databases, and configuration.

## When to use this skill

Use this skill when the user wants to:
- **Create** a new worktree for parallel development
- **Remove** an existing worktree and its branch
- **List** all worktrees and their status
- **Check** worktree configuration or status
- **Manage** multiple parallel development environments
- **Work on mobile iOS features** with JIRA ticket integration
- **Work on web projects** with isolated ports and services

**Do NOT use this skill when:**
- User asks for a specific subagent or skill delegation
- User wants to manually use git commands directly
- The task is unrelated to worktree management

## Project Type Detection

This skill automatically detects whether you're working with:

### Mobile iOS Projects
**Indicators:**
- Presence of `*.xcodeproj` or `*.xcworkspace` files
- iOS development environment
- Xcode projects

**Features:**
- Feature-based naming (human-readable descriptions)
- JIRA ticket integration
- Automatic kebab-case branch naming
- Folder-prefixed worktree directories
- .claude configuration copying
- No service management (runs in Xcode/simulator)

### Web Projects (Legacy)
**Indicators:**
- Presence of `apps/server/` and `apps/client/` directories
- Server/client architecture
- Node.js/Bun environment

**Features:**
- Branch-based naming
- Port offset management
- Isolated services (server + client)
- Automatic service startup
- Database isolation
- Port conflict prevention

### Monorepo Projects (Turborepo/pnpm)
**Indicators:**
- `turbo.json` file in root
- `pnpm-workspace.yaml` file in root
- `apps/` directory with multiple applications (api, worker, dashboard, website)
- `packages/` directory with shared packages

**Features:**
- Branch-based naming (same as web)
- Port offset management for all services
- Docker Compose isolation via `COMPOSE_PROJECT_NAME`
- **Root `.env` symlinks to all apps** - ensures consistent env vars across monorepo
- Partner Framework auto-installation (if available)
- No auto-start services (use `pnpm dev` or `turbo dev`)

**IMPORTANT - .env Symlink Strategy:**
Monorepo apps (especially Next.js) only load `.env` from their own directory, not the monorepo root.
To ensure all apps read from the same source:
1. Copy root `.env` to worktree root (with port modifications)
2. Create symlinks from worktree root `.env` to each app's `.env` file:
   - `apps/api/.env` → `../../.env` (symlink)
   - `apps/worker/.env` → `../../.env` (symlink)
   - `apps/dashboard/.env` → `../../.env` (symlink)
   - `apps/website/.env` → `../../.env` (symlink)

This ensures `PORT`, `NEXT_PUBLIC_*`, and all other env vars are consistent across all apps.

## Operations Overview

This skill manages three core worktree operations:

| Operation | Web Command | Mobile Command | When to Use |
|-----------|-------------|----------------|-------------|
| **Create** | `/create_worktree_prompt` | `/create_mobile_worktree_prompt` | User wants a new parallel environment |
| **List** | `/list_worktrees_prompt` | `/list_worktrees_prompt` | User wants to see existing worktrees |
| **Remove** | `/remove_worktree_prompt` | `/remove_worktree_prompt` | User wants to delete a worktree |

## Decision Tree: Which Command to Use

### Step 1: Detect Project Type
```bash
# Check for iOS/mobile project
ls *.xcodeproj *.xcworkspace 2>/dev/null || ls -d ios/*.xcodeproj ios/*.xcworkspace 2>/dev/null

# Check for monorepo (Turborepo/pnpm)
ls turbo.json pnpm-workspace.yaml 2>/dev/null

# Check for apps directory structure
ls -d apps/api apps/worker apps/dashboard apps/website 2>/dev/null
```

**Decision logic:**
- If `.xcodeproj` or `.xcworkspace` found → **MOBILE iOS** → Use mobile commands
- If `turbo.json` or `pnpm-workspace.yaml` exists → **MONOREPO** → Use web commands with extra config
- If `apps/server` and `apps/client` exist → **WEB (Legacy)** → Use web commands
- Default if unclear → **WEB**

### Step 2: Choose Operation

#### 1. User wants to CREATE a worktree

**Keywords:** create, new, setup, make, build, start, initialize

**For MOBILE iOS Projects:**
- Extract feature title (human-readable description)
- Extract JIRA ticket (if mentioned)
- **Action:** `/create_mobile_worktree_prompt "<feature-title>" [jira-ticket]`
- **Example:** `/create_mobile_worktree_prompt "Improve search performance" "PE-12345"`

**For WEB Projects:**
- Extract branch name (explicit git branch)
- Extract port offset (if mentioned)
- **Action:** `/create_worktree_prompt <branch-name> [port-offset] web`
- **Example:** `/create_worktree_prompt feature-auth 1 web`

#### 2. User wants to LIST worktrees

**Keywords:** list, show, display, what, which, status, check, view

**For ALL Project Types:**
- **Action:** `/list_worktrees_prompt`
- Shows both web and mobile worktrees with appropriate details

#### 3. User wants to REMOVE a worktree

**Keywords:** remove, delete, cleanup, destroy, stop, kill, terminate

**For MOBILE iOS Projects:**
- Extract branch name (may include folder prefix)
- **Action:** `/remove_worktree_prompt <branch-name>`
- **Example:** `/remove_worktree_prompt feature/PTECH-503-improve-search`

**For WEB Projects:**
- Extract branch name
- **Action:** `/remove_worktree_prompt <branch-name>`
- **Example:** `/remove_worktree_prompt feature-auth`

## Quick Start

For step-by-step operation instructions, see [OPERATIONS.md](OPERATIONS.md).

For detailed examples and usage patterns, see [EXAMPLES.md](EXAMPLES.md).

For troubleshooting and common issues, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

For technical details and quick reference, see [REFERENCE.md](REFERENCE.md).

## Important Notes

### Do NOT attempt to:
- Create worktrees manually with git commands
- Manually configure ports or environment files (web projects)
- Use bash to remove directories directly
- Manage worktree processes manually (web projects)
- Manually convert feature titles to branch names (mobile projects)

### Always use the slash commands because they:
- Handle all configuration automatically
- Ensure port uniqueness (web projects)
- Generate proper branch names (mobile projects)
- Validate operations
- Provide comprehensive error handling
- Clean up properly on removal
- Copy .claude configuration to worktrees
- Stop services gracefully (web projects)

### Mobile iOS vs Web Differences

| Aspect | Mobile iOS | Web |
|--------|-----------|-----|
| **Input** | Feature title + JIRA ticket | Branch name + port offset |
| **Branch naming** | Auto-generated kebab-case | User-specified |
| **Worktree directory** | Folder-prefixed | Simple branch name |
| **Services** | None (runs in Xcode) | Auto-started server + dashboard |
| **Ports** | N/A | Isolated per worktree (API, Dashboard, Postgres, Redis) |
| **Configuration** | .claude copied | .claude + .env files |
| **Dependencies** | Not pre-installed | Auto-installed |

### Web Project Port Configuration

Each web worktree gets isolated ports configured in the `.env` file:

| Variable | Base (Main) | Offset Formula | Example (Offset 1) |
|----------|-------------|----------------|-------------------|
| `PORT` (API) | 4000 | 4000 + (offset * 10) | 4010 |
| `DASHBOARD_PORT` | 3000 | 3000 + (offset * 10) | 3010 |
| `POSTGRES_PORT` | 5432 | 5432 + (offset * 10) | 5442 |
| `REDIS_PORT` | 6379 | 6379 + (offset * 10) | 6389 |

Additional `.env` variables set per worktree:
- `COMPOSE_PROJECT_NAME=ignio-{branch-name}` - Isolates Docker Compose containers
- `DATABASE_URL` - Uses worktree-specific Postgres port
- `REDIS_URL` - Uses worktree-specific Redis port

## Workflow Overview

### Mobile iOS Workflow
1. Detect iOS project (`.xcodeproj` file)
2. Extract feature title and JIRA ticket from user request
3. Call `/create_mobile_worktree_prompt "Feature Title" "JIRA-123"`
4. Branch created: `feature/JIRA-123-feature-title`
5. Worktree created: `trees/reellette-ios-JIRA-123-feature-title`
6. .claude config copied
7. Ready to open in Xcode

### Web Workflow
1. Detect web project (`apps/server` + `apps/client`)
2. Extract branch name and optional port offset
3. Call `/create_worktree_prompt branch-name [offset] web`
4. Worktree created: `trees/branch-name`
5. Services auto-started on unique ports
6. Ready to access via browser
