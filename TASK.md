# Task: Debug Log Viewer (#24)

**Issue**: https://github.com/leonardocardoso/poirot/issues/24

## Overview

Browse per-session debug logs for diagnosing MCP server issues, permission failures, and startup problems.

### Data Source

`~/.claude/debug/<sessionId>.txt` — plain text log files with timestamped entries:
```
[2026-02-26T10:32:15.123Z] [DEBUG] Loading MCP servers from ~/.claude.json
[2026-02-26T10:32:15.456Z] [DEBUG] Starting MCP server: playwright
[2026-02-26T10:32:16.789Z] [ERROR] MCP server "notion" failed to start: connection refused
[2026-02-26T10:32:17.012Z] [DEBUG] Permission update: allow Bash for project /path/to/repo
```

There are ~1,800 log files on a typical install, one per session.

## Scope

- [ ] Associate debug logs with sessions by matching session ID filenames
- [ ] Show "View Debug Log" action in session detail view (button or menu item)
- [ ] Log viewer with syntax-colored entries (DEBUG=gray, ERROR=red, WARN=amber)
- [ ] Filter by log level (DEBUG, ERROR, WARN)
- [ ] Full-text search within a log
- [ ] Auto-scroll to first error when opening
- [ ] Timestamp display (relative or absolute toggle)

### Design Considerations

- This is a diagnostic tool — don't surface it prominently, but make it accessible
- A sheet or secondary panel from the session detail view is appropriate
- Log files can be large — use lazy loading and virtualized list
- Color-coding by level is essential for scannability
- Consider a "Copy Log" action for sharing in bug reports

### Files Involved

| File | Change |
|------|--------|
| New `Models/DebugLogEntry.swift` | Parsed log entry model (timestamp, level, message) |
| New `Services/DebugLogLoader.swift` | Text parser for debug log format |
| New `Views/Session/DebugLogView.swift` | Log viewer with filtering and search |
| `Views/Session/SessionDetailView.swift` | Add "View Debug Log" action |

## TODOs

- [ ] 0. Assign issue #24 to @leonardocardoso
- [ ] 1. Use existing patterns (list, gallery) for page content layout
- [ ] 2. Use markdown rendering as pertinent (see Sessions, Plans sidebar items for examples)
- [ ] 3. Add items to the universal search (⌘K)
- [ ] 4. Watch for file changes in `~/.claude/debug/` for live updates
- [ ] 5. Include in navigation history if pertinent
- [ ] 6. Move new screenshots to `assets/showcase/`
- [ ] 7. Add new information to the `README.md` file
- [ ] 8. Create PR with `Closes #24` in the body
