---
name: raw-docs-processor
model: claude-opus-4-6
description: Process docs/RAW folders containing screenshot PNGs into structured markdown documentation files.
allowed-tools: Bash, Read, Glob, Grep
---

# Raw Documentation Processor Skill

Process docs/RAW folders containing screenshot PNGs into structured markdown documentation files.

## When to Use

Use this skill when:
- User has docs/RAW folder with screenshot images of API documentation
- User wants to create structured markdown docs from these screenshots
- User mentions processing "raw docs", "screenshots to docs", or "document from images"

## Input Structure

docs/RAW folder contains numbered subfolders with PNG screenshots:
```
docs/RAW/
├── 01. screencapture-developers-example-api-overview/
│   ├── screencapture-...-part01.png
│   ├── screencapture-...-part02.png
│   └── ...
├── 02. screencapture-developers-example-api-concepts/
│   └── ...
```

## URL Derivation

Extract URL from folder name:
- Folder: `02. screencapture-developers-google-workspace-calendar-api-concepts`
- URL: `https://developers.google.com/workspace/calendar/api/concepts`

Pattern: Replace `screencapture-` prefix and convert hyphens in domain to dots, then path hyphens remain.

## Output Format

Create markdown files matching WhatsApp docs style:

```markdown
---
Title: [Extracted from page content]
URL: [Derived from folder name]
API Version: [From content, e.g., "v3", "Cloud API v17.0+"]
Type: [Guide/Resource/Method - for API Reference docs]
---

## Content Summary

[Main content organized with headers from the screenshots]

### Section 1
[Content]

### Section 2
[Content]

## Highlights

- [Key point 1]
- [Key point 2]
- [Important limits, constraints, or notes]
```

## Processing Steps

1. **List docs/RAW folders**: `ls docs/RAW/` to see all folders to process
2. **Count files per folder**: Check how many PNGs in each folder
3. **Read images sequentially**: Read all PNG parts for a folder
4. **Extract content**: Parse text, tables, code samples from screenshots
5. **Derive URL**: Convert folder name to URL
6. **Create structured doc**: Write markdown file with frontmatter
7. **Track progress**: Use TodoWrite to track folders processed

## Output Location Detection

Determine the correct output folder based on URL path patterns:

### docs/API/ (API Reference)
Place in `docs/API/{SERVICE-NAME}/` when URL contains:
- `/reference/` - API reference documentation
- `/v3/reference/` or similar versioned reference paths
- `/support/error-codes` - Error code references
- `/api/` followed by resource names (events, settings, freebusy)
- Method documentation (get, list, create, delete, update, patch, watch)

**Examples:**
- `developers.google.com/workspace/calendar/api/v3/reference/events` → `docs/API/GOOGLE-CALENDAR/`
- `developers.facebook.com/docs/whatsapp/cloud-api/support/error-codes` → `docs/API/WHATSAPP/`

### docs/STACK/ (Guides & Concepts)
Place in `docs/STACK/{SERVICE-NAME}/` when URL contains:
- `/guides/` - How-to guides
- `/concepts/` - Conceptual documentation
- `/overview` - Product overviews
- `/get-started` - Getting started guides
- `/auth` or `/authentication` - Auth setup guides
- `/webhooks` - Webhook setup guides (not webhook reference)
- `/best-practices` - Best practice guides

**Examples:**
- `developers.google.com/workspace/calendar/api/guides/overview` → `docs/STACK/GOOGLE-CALENDAR/`
- `developers.facebook.com/docs/whatsapp/cloud-api/get-started` → `docs/STACK/WHATSAPP-BUSINESS-PLATFORM/`

### Detection Logic

```
IF url contains "/reference/" OR "/error-codes" OR "/support/" THEN
  → docs/API/{SERVICE}/
ELSE IF url contains "/guides/" OR "/concepts/" OR "/overview" OR "/get-started" THEN
  → docs/STACK/{SERVICE}/
ELSE
  → Ask user or default to docs/STACK/
```

## Naming Convention

Files are numbered to match folder order:
- `01-OVERVIEW.md`
- `02-CONCEPTS.md`
- `03-AUTH.md`
- etc.

## Example Workflow

```bash
# 1. List all docs/RAW folders
ls docs/RAW/ | head -20

# 2. Check files in first folder
ls "docs/RAW/01. screencapture-developers-google-workspace-calendar-api-guides-overview/"

# 3. Read each PNG
Read file_path=".../part01.png"
Read file_path=".../part02.png"
# ... continue for all parts

# 4. Create output directory if needed
mkdir -p docs/STACK/GOOGLE-CALENDAR

# 5. Write structured markdown
Write file_path="docs/STACK/GOOGLE-CALENDAR/01-OVERVIEW.md"

# 6. Repeat for each folder
```

## Content Extraction Tips

- **Tables**: Convert to markdown tables with proper alignment
- **Code samples**: Wrap in appropriate code blocks with language
- **Lists**: Preserve bullet points and numbered lists
- **Links**: Note important links but don't include broken refs
- **Images/Diagrams**: Describe in text what the diagram shows
- **Warnings/Notes**: Use blockquotes or callout format

## Batch Processing

For efficiency, process multiple folders in parallel:
1. Read all images for 2-3 folders simultaneously
2. Create all docs for those folders
3. Commit as a batch (e.g., "Add [Service] docs 01-12")
4. Continue with next batch

## Commit Message Format

```
Add [Service Name] [doc type] documentation ([N] docs)

- [Category 1]: [Brief description]
- [Category 2]: [Brief description]

Total: [N] docs, [X] lines
```
