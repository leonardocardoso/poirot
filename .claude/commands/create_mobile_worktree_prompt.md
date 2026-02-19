---
model: claude-opus-4-6
description: Create a mobile git worktree from feature title with JIRA ticket support
argument-hint: [feature-title] [jira-ticket]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
output-style: tts-summary
---

# Purpose

Create a new git worktree for **iOS mobile development** from a human-readable feature title. This command simplifies worktree creation by accepting natural language descriptions instead of pre-formatted branch names.

## Overview

This command is specifically designed for **iOS projects** and provides:

**Key Features:**
- **Feature-based input**: Use natural descriptions like "Improve search performance" instead of branch names
- **Automatic branch naming**: Converts feature titles to kebab-case branch names
- **JIRA integration**: Optionally includes ticket numbers in branch names (e.g., `feature/PTECH-503-create-agents-locally`)
- **Smart directory naming**: Uses current folder name as prefix (e.g., `reellette-ios-PTECH-503-...`)
- **.claude config copying**: Automatically copies all Claude Code settings to the worktree
- **iOS-optimized**: Simplified workflow for Xcode projects without dependency management

**When to use this command:**
- You're working on an iOS project (has `.xcodeproj` or `.xcworkspace` files)
- You want to describe what you're building instead of creating branch names
- You have a JIRA ticket and want it in the branch name automatically
- You want each worktree to have independent Claude Code configuration
- You need to work on multiple features simultaneously in Xcode

**Comparison with `/create_worktree_prompt`:**
- `/create_mobile_worktree_prompt`: **Feature-first** approach for iOS projects
  - Input: "Improve search performance" + "PTECH-503"
  - Output: `feature/PTECH-503-improve-search-performance`

- `/create_worktree_prompt`: **Branch-first** approach for web/backend projects
  - Input: `feature-auth` + port-offset + project-type
  - Output: Worktree with isolated ports and services

## Variables

```
PROJECT_CWD: . (current working directory - the main project root)
FEATURE_TITLE: $1 (required) - Human-readable feature title (e.g., "Improve search performance")
JIRA_TICKET: $2 (optional) - JIRA ticket number (e.g., "PE-12345")
WORKTREE_BASE_DIR: ../${CURRENT_FOLDER}-trees/
CURRENT_FOLDER: basename of PROJECT_CWD (e.g., "reellette-ios")
BRANCH_NAME: Auto-generated from JIRA_TICKET and FEATURE_TITLE in kebab-case
WORKTREE_NAME: ${CURRENT_FOLDER}-${BRANCH_NAME_WITHOUT_PREFIX}
WORKTREE_DIR: ../${CURRENT_FOLDER}-trees/${WORKTREE_NAME}
```

## Instructions

This section provides step-by-step instructions for creating a mobile worktree. Each step includes detailed rationale and implementation guidance.

### 1. Parse and Validate Arguments

**Purpose:** Extract and validate user inputs before proceeding with worktree creation.

**Steps:**
- **Read FEATURE_TITLE from $1:**
  - This is the REQUIRED first argument
  - Should be a human-readable description (e.g., "Improve search performance")
  - If missing, provide a clear error message explaining the command usage
  - Example error: "Feature title is required. Usage: /create_mobile_worktree_prompt \"Feature description\" [JIRA-TICKET]"

- **Read JIRA_TICKET from $2 if provided:**
  - This is OPTIONAL second argument
  - Format: Uppercase letters + hyphen + numbers (e.g., "PTECH-503", "PE-12345")
  - If provided, will be included in branch name
  - If omitted, branch name won't have JIRA prefix

- **Get current folder name:**
  - Execute: `CURRENT_FOLDER=$(basename $(pwd))`
  - This captures the project directory name (e.g., "reellette-ios")
  - Used as prefix for worktree directory naming
  - Ensures worktree names are descriptive and project-specific

- **Validate FEATURE_TITLE is not empty:**
  - Check that FEATURE_TITLE contains at least one character
  - Reject empty strings or whitespace-only inputs
  - This prevents creating worktrees with invalid/empty branch names

**Why this matters:** Proper validation ensures the command fails fast with helpful errors rather than creating malformed worktrees or branch names.

### 2. Generate Branch Name

**Purpose:** Convert human-readable feature title into a valid, standardized git branch name.

**Kebab-Case Conversion Algorithm:**

Execute these transformations in order:

1. **Convert to lowercase:**
   - "Improve Search Performance" → "improve search performance"
   - Ensures consistency regardless of input casing

2. **Replace spaces with hyphens:**
   - "improve search performance" → "improve-search-performance"
   - Makes branch name URL-safe and git-compatible

3. **Remove special characters:**
   - Keep only: letters (a-z), numbers (0-9), hyphens (-)
   - Remove: punctuation, symbols, special characters
   - "Fix: Auth Bug!" → "fix-auth-bug"
   - This ensures branch names work across all git operations

4. **Remove leading/trailing hyphens:**
   - "-fix-auth-bug-" → "fix-auth-bug"
   - Prevents malformed branch names

5. **Collapse multiple consecutive hyphens:**
   - "improve--search---performance" → "improve-search-performance"
   - Creates clean, readable branch names

**Branch Name Construction:**

- **With JIRA ticket:** `feature/${JIRA_TICKET}-${kebab-case-title}`
  - Format: `feature/UPPERCASE-NUMBERS-lowercase-words`
  - JIRA ticket preserved in original case
  - Feature title converted to kebab-case

- **Without JIRA ticket:** `feature/${kebab-case-title}`
  - Format: `feature/lowercase-words`
  - Simple feature branch without ticket reference

**Examples:**

| Input Title | JIRA Ticket | Generated Branch Name |
|------------|-------------|----------------------|
| "Improve search performance" | PTECH-503 | `feature/PTECH-503-improve-search-performance` |
| "Split Discover and Catalog code" | - | `feature/split-discover-and-catalog-code` |
| "Fix: Auth Bug!" | PE-999 | `feature/PE-999-fix-auth-bug` |
| "Add Dark Mode Support" | PROJ-100 | `feature/PROJ-100-add-dark-mode-support` |

**Worktree Directory Naming:**

Pattern: `${CURRENT_FOLDER}-${BRANCH_NAME_WITHOUT_PREFIX}`

- Removes "feature/" prefix from branch name
- Prepends current project folder name
- Creates unique, descriptive directory names

Examples:
| Current Folder | Branch Name | Worktree Directory |
|---------------|-------------|-------------------|
| reellette-ios | feature/PTECH-503-improve-search | ../reellette-ios-trees/reellette-ios-PTECH-503-improve-search |
| reellette-ios | feature/split-catalog | ../reellette-ios-trees/reellette-ios-split-catalog |
| my-app | feature/PE-100-dark-mode | ../my-app-trees/my-app-PE-100-dark-mode |

**Why this matters:** Standardized branch names ensure consistency across the team, work seamlessly with git, and remain readable months later when reviewing git history.

### 3. Pre-Creation Validation

**Purpose:** Verify the environment is ready for worktree creation and prevent conflicts with existing worktrees or branches.

**Validation Steps:**

1. **Ensure `../${CURRENT_FOLDER}-trees/` directory exists:**
   - Check if `../${CURRENT_FOLDER}-trees/` directory exists
   - If not, create it: `mkdir -p trees`
   - The `-p` flag creates parent directories and doesn't error if directory exists
   - This directory will hold all worktrees for the project

2. **Verify `.gitignore` configuration:**
   - Check if `trees/` is listed outside the project (no need for .gitignore)
   - Should already be there from initial repository setup
   - If missing, warn user to add it manually
   - **Why:** Prevents accidentally committing worktree directories to git
   - Worktrees should be local development environments, not versioned

3. **Check for existing worktree:**
   - Verify WORKTREE_DIR doesn't already exist
   - Check both git worktree list and filesystem
   - Command: `git worktree list | grep ../${CURRENT_FOLDER}-trees/${WORKTREE_NAME}`
   - **If exists:** Error with clear message
     - "Worktree already exists at ../${CURRENT_FOLDER}-trees/${WORKTREE_NAME}"
     - "Use /remove_worktree_prompt ${BRANCH_NAME} to remove it first"
     - "Or choose a different feature title/JIRA ticket"

4. **Check for existing branch:**
   - Verify branch name doesn't already exist in repository
   - Command: `git branch --list ${BRANCH_NAME}`
   - **If exists:** Error with clear message
     - "Branch ${BRANCH_NAME} already exists"
     - "This might be from a previous worktree that was removed"
     - "Options:"
     - "  1. Choose a different feature title"
     - "  2. Delete the branch: git branch -D ${BRANCH_NAME}"
     - "  3. Use the existing branch if it's the right one"

**Why validation matters:**

- **Prevents data loss:** Ensures we don't overwrite existing work
- **Clear error messages:** Helps user understand what went wrong and how to fix it
- **Early failure:** Catches issues before creating partial worktree state
- **Clean state:** Guarantees fresh, isolated environment for new work

### 4. Create Git Worktree

**Purpose:** Create an isolated git worktree with a new branch for independent feature development.

**Creation Steps:**

1. **Execute git worktree creation:**
   - From PROJECT_CWD, run: `git worktree add ../${CURRENT_FOLDER}-trees/${WORKTREE_NAME} -b ${BRANCH_NAME}`
   - **Breakdown:**
     - `git worktree add`: Git command to create new worktree
     - `../${CURRENT_FOLDER}-trees/${WORKTREE_NAME}`: Target directory path
     - `-b ${BRANCH_NAME}`: Create new branch with this name
   - **What happens:**
     - Git creates new directory at ../${CURRENT_FOLDER}-trees/${WORKTREE_NAME}
     - Creates new branch from current HEAD
     - Checks out the new branch in the worktree
     - Worktree is fully independent from main repo

2. **Verify worktree creation:**
   - Run: `git worktree list | grep ../${CURRENT_FOLDER}-trees/${WORKTREE_NAME}`
   - Should return the worktree path and branch name
   - If empty, creation failed - investigate git errors

3. **Set working context:**
   - All subsequent operations reference WORKTREE_DIR
   - WORKTREE_DIR = `../${CURRENT_FOLDER}-../${CURRENT_FOLDER}-trees/${WORKTREE_NAME}`
   - This is now an independent checkout of the repository

**What you get:**
- Complete, isolated copy of repository at new branch
- Independent HEAD pointer (won't affect main repo)
- Shared .git database (efficient disk usage)
- Ability to switch between worktrees instantly

### 4b. Setup Remote Tracking for New Branch

**Purpose:** Ensure the new branch has its own remote tracking branch instead of tracking the original branch.

**Steps:**

1. **Change to worktree directory:**
   - Execute: `cd ${WORKTREE_DIR}`
   - All git commands in this step run from the worktree context

2. **Remove any existing upstream tracking:**
   - Execute: `git branch --unset-upstream ${BRANCH_NAME} 2>/dev/null || true`
   - This removes tracking to the original remote branch (if any)
   - The `|| true` ensures the command doesn't fail if there was no upstream
   - **Why:** We want the new branch to have its own identity, not track another branch

3. **Push the new branch to origin and set up tracking:**
   - Execute: `git push -u origin ${BRANCH_NAME}`
   - This creates `origin/${BRANCH_NAME}` on the remote
   - The `-u` flag sets up tracking so `git pull` and `git push` work correctly
   - **Result:** The branch now tracks `origin/${BRANCH_NAME}` instead of the original branch

4. **Return to original directory:**
   - Execute: `cd ${PROJECT_CWD}`

**Why this matters:**
- When creating from a remote branch, the local branch would track that remote
- This means `git pull` would pull from the original branch, not the feature branch
- By pushing immediately with `-u`, we create proper tracking for the feature branch
- Future `git push` and `git pull` operations work as expected

### 5. Copy .claude Configuration

**Purpose:** Ensure consistent Claude Code experience across all worktrees by copying configuration.

**Why this matters:**
- Each worktree benefits from same slash commands
- Same skills available in all worktrees
- Consistent todo templates and task management
- Same hooks and automations
- Unified development experience

**Copy Steps:**

1. **Check for source configuration:**
   - Verify `.claude/` directory exists at PROJECT_CWD
   - If missing, skip this step (optional feature)

2. **Remove any existing .claude in worktree:**
   - Execute: `rm -rf ${WORKTREE_DIR}/.claude`
   - This MUST succeed before copying to avoid nesting issues
   - Verify removal: `test ! -d ${WORKTREE_DIR}/.claude`

3. **Copy entire .claude directory:**
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

4. **Verify NO nesting occurred:**
   - Check: `test ! -d ${WORKTREE_DIR}/.claude/.claude`
   - If nested .claude exists, REMOVE IT: `rm -rf ${WORKTREE_DIR}/.claude/.claude`
   - This is a critical safeguard against accidental nesting

5. **Verify successful copy:**
   - Check that key files exist: `test -d ${WORKTREE_DIR}/.claude/commands`
   - If copy failed, log warning but continue

6. **Handle missing configuration:**
   - If .claude doesn't exist in main repo:
     - Log informational message
     - "No .claude configuration found to copy"
     - This is OK - worktree will work without it

**Benefits:**
- Immediate access to all custom commands in new worktree
- No need to reconfigure Claude Code for each worktree
- Consistent workflow across all branches
- Skills and automations work identically everywhere

### 5b. Copy Environment Files

**Purpose:** Copy environment configuration files needed for the project to run.

**Copy Steps:**

1. **Copy .env if exists:**
   - Check if PROJECT_CWD/.env exists
   - If exists: `cp ${PROJECT_CWD}/.env ${WORKTREE_DIR}/.env`
   - This preserves API keys (OPENAI_API_KEY, GOOGLE_CLOUD_CREDENTIALS, etc.)
   - If missing: Skip (project may use .env.example or other config method)

2. **Copy google-credentials.json if exists:**
   - Check if PROJECT_CWD/google-credentials.json exists
   - If exists: `cp ${PROJECT_CWD}/google-credentials.json ${WORKTREE_DIR}/google-credentials.json`
   - This preserves Google Cloud service account credentials for OCR/Vision API
   - If missing: Skip (not all projects use Google Cloud services)

**Why this matters:**
- Ensures worktree can access external services (LLM APIs, Google Cloud, etc.)
- Prevents "missing credentials" errors when running the project
- Keeps sensitive files out of git while sharing them across worktrees

### 6. Validation

**Purpose:** Verify the worktree was created correctly before reporting success.

**Validation Checks:**

1. **Verify worktree directory exists:**
   - Check filesystem: `test -d ${WORKTREE_DIR}`
   - Should return true (directory exists)
   - If false, creation failed

2. **Verify .claude configuration (if applicable):**
   - If source had .claude: `test -d ${WORKTREE_DIR}/.claude`
   - Should return true if copy succeeded
   - Log warning if expected but missing

3. **Verify git recognizes worktree:**
   - Run: `git worktree list`
   - Output should include entry for new worktree
   - Shows: path, HEAD commit, branch name

4. **Verify branch was created:**
   - Run: `git branch --list ${BRANCH_NAME}`
   - Should return the branch name
   - If empty, branch creation failed

**What to check in output:**
```bash
# Example git worktree list output:
/path/to/main                    abc123 [main]
/path/to/../reellette-ios-trees/reellette-ios-... def456 [feature/PTECH-503-create-agents-locally]
```

**If validation fails:**
- Do NOT proceed to summary/completion
- Clean up partial state if possible
- Provide clear error message with:
  - What failed
  - Why it might have failed
  - How to fix it
  - How to clean up

### 7. Generate Summary Report

Create a comprehensive summary with the following information:

```
✅ Mobile Worktree Created Successfully!

📁 Worktree Details:
   Location: ../${CURRENT_FOLDER}-trees/${WORKTREE_NAME}
   Branch: ${BRANCH_NAME}
   Remote: origin/${BRANCH_NAME} (tracking configured)
   Feature: ${FEATURE_TITLE}
   [If JIRA_TICKET provided] JIRA Ticket: ${JIRA_TICKET}
   Project Type: Mobile Application
   Status: 🟢 READY

⚙️  Configuration:
   ✓ Claude Code settings (.claude/ folder copied from parent)
   ✓ Root .env (if exists - API keys and configuration)
   ✓ google-credentials.json (if exists - Google Cloud service account)
   ✓ Ready for development

📝 Important Notes:
   • This worktree is completely isolated from the main codebase
   • You can work on multiple branches simultaneously
   • Each worktree maintains its own configuration
   • .claude configuration copied for consistent development experience

🚀 To Work on This Worktree:

   # Navigate to the worktree
   cd ../${CURRENT_FOLDER}-trees/${WORKTREE_NAME}

   # Open Claude Code in this worktree
   code .
   # or
   cursor .

   # Open the project in Xcode
   open *.xcworkspace
   # or
   open *.xcodeproj
   # Then run from Xcode

🗑️  To Remove This Worktree:

   # Remove the worktree (from main project directory):
   git worktree remove ../${CURRENT_FOLDER}-trees/${WORKTREE_NAME}

   # Or force remove if needed:
   git worktree remove ../${CURRENT_FOLDER}-trees/${WORKTREE_NAME} --force

   # Delete the branch if no longer needed:
   git branch -D ${BRANCH_NAME}

🎉 Next Steps:
   1. Navigate to ../${CURRENT_FOLDER}-trees/${WORKTREE_NAME}
   2. Open Claude Code (benefits from copied .claude configuration)
   3. Open the project in Xcode
   4. Run the app on your preferred simulator/device
   5. Make changes and test independently from main branch
   6. Each worktree maintains its own build artifacts and cache
```

### 7. Generate Summary Report

**Purpose:** Provide clear, actionable summary of what was created and how to use it.

The summary report should include all the information shown in the Report section above. Format it clearly with emojis and sections for easy scanning.

### 8. Announce Completion (TTS Summary)

**Purpose:** Provide audio feedback to the user about task completion using the `tts-summary` output style.

**Important:** This command uses `output-style: tts-summary` which requires:

1. **Normal response content** (steps 1-7 above)

2. **Tool calls listing** (if tools were used):
   ```typescript
   Bash({ command: "git worktree add ..." })
   // Create isolated git worktree

   Bash({ command: "cp -R .claude ..." })
   // Copy Claude Code configuration
   ```

3. **Audio Summary for Léo:**
   - Write a separator: `---`
   - Add heading: `## Audio Summary for Léo`
   - Craft message addressing Léo directly about what was accomplished
   - Execute TTS command:
   ```bash
   uv run ~/.claude/hooks/utils/tts/elevenlabs/elevenlabs_tts.py "Léo, I've created a worktree for ${FEATURE_TITLE} on branch ${BRANCH_NAME}."
   ```

**Example completion message:**
```bash
echo "Worktree created: ../${CURRENT_FOLDER}-trees/${WORKTREE_NAME}"
echo "Branch: ${BRANCH_NAME}"
[If JIRA_TICKET] echo "JIRA: ${JIRA_TICKET}"
echo "Feature: ${FEATURE_TITLE}"
```

**TTS Message Guidelines:**
- Address user directly: "Léo, I've created..."
- Focus on outcome: what user can now do
- Be conversational: speak naturally
- Highlight value: emphasize what's useful
- Keep concise: under 20 words
- Example: "Léo, I've set up your worktree for PTECH-503 with Claude Code ready to go in Xcode."

## Error Handling

If any step fails:
1. Provide clear error message with what went wrong
2. Suggest remediation steps
3. If worktree was partially created, provide cleanup instructions
4. Common errors:
   - Missing FEATURE_TITLE argument
   - Branch already exists
   - Worktree directory already exists
   - Git errors (uncommitted changes, etc.)

## Examples

### Example 1: With JIRA ticket

**Input:**
```bash
/create_mobile_worktree_prompt "Improve search performance" "PE-12345"
```

**Result:**
- Branch: `feature/PE-12345-improve-search-performance`
- Worktree: `../reellette-ios-trees/reellette-ios-PE-12345-improve-search-performance`

### Example 2: Without JIRA ticket

**Input:**
```bash
/create_mobile_worktree_prompt "Split Discover and Catalog code"
```

**Result:**
- Branch: `feature/split-discover-and-catalog-code`
- Worktree: `../reellette-ios-trees/reellette-ios-split-discover-and-catalog-code`

### Example 3: Complex title with special characters

**Input:**
```bash
/create_mobile_worktree_prompt "Fix: User Auth Bug (iOS)" "PE-999"
```

**Result:**
- Branch: `feature/PE-999-fix-user-auth-bug-ios`
- Worktree: `../reellette-ios-trees/reellette-ios-PE-999-fix-user-auth-bug-ios`
