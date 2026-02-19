# LUMNO

A native macOS companion app for Claude Code.

Browse sessions, explore diffs, re-run commands, and manage your Claude Code configuration — all from a polished SwiftUI interface.

## Features (MVP)

- **Session History Browser** — Read Claude Code JSONL transcripts, grouped by project
- **Fuzzy Search** — Search across sessions, commands, and file changes (⌘K)
- **Code Diff Viewer** — Syntax-highlighted diffs with inline tool output
- **IDE Integration** — One-click open files in Cursor/VSCode
- **Quick Command Re-run** — Click to re-execute previous commands
- **Status Line** — Active session status, model, token usage
- **Configuration Dashboard** — Skills, Slash Commands, MCPs, Models, Sub-agents

## Requirements

- macOS 15.0+
- Xcode 26+
- Swift 6+

## Building

Open `Lumno.xcodeproj` in Xcode and run, or:

```bash
xcodebuild -scheme Lumno -configuration Debug build
```

## Architecture

Native SwiftUI app using:
- Swift 6 with strict concurrency
- SwiftUI + Observation framework
- FileMonitor for watching JSONL transcript changes
- Process API for Claude Code CLI integration

## License

MIT
