# LUMNO — Feature Roadmap

## Foundation

- [ ] **0. Architecture & Best Practices** — Establish project conventions for open-source readiness: strict Swift concurrency, MVVM with Observation, dependency injection via Environment, protocol-driven services, unit test targets, SwiftLint config, CONTRIBUTING.md, code documentation standards, CI pipeline (GitHub Actions for build/test/lint), and semantic versioning.

## MVP

- [ ] **1. JSONL Transcript Parser** — Read and parse `~/.claude/projects/` JSONL files into Session/Message models. The foundation everything else depends on.
- [ ] **2. Session History Browser** — List sessions grouped by project with timestamps, model, token counts. Sidebar navigation with project tree.
- [ ] **3. Session Detail View** — Render conversation timeline — user messages, assistant responses, tool blocks (Read, Edit, Bash, etc.) with collapsible sections.
- [ ] **4. Code Diff Viewer** — Syntax-highlighted inline diffs for Edit tool blocks. Show added/removed lines with file paths.
- [ ] **5. Bash Output Renderer** — Render terminal command output from Bash tool blocks with monospace styling and exit status.
- [ ] **6. Fuzzy Search (⌘K)** — Search across all sessions, commands, file paths, and message content. Grouped results with keyboard navigation.
- [ ] **7. IDE Integration** — One-click open files in Cursor/VSCode/Xcode. Detect from `$TEXT_EDITOR` env or Settings preference.
- [ ] **8. Quick Command Re-run** — Click a previous Bash command to copy it or re-execute via `claude` CLI.
- [ ] **9. Status Bar** — Show Claude Code active/idle status, current project, working directory, git branch.
- [ ] **10. Real-time File Watching** — Watch `~/.claude/projects/` for new/changed JSONL files using FSEvents. Auto-update session list.

## V1

- [ ] **11. Configuration Dashboard** — Browse and quick-access Skills, Slash Commands, MCPs, Sub-agents, Models from a card-based UI.
- [ ] **12. Model Selection** — Switch default model from a dropdown. Per-project model preferences stored locally.
- [ ] **13. Message Streaming Animation** — Animated token-by-token text rendering when viewing active sessions. Toggle in Settings.
- [ ] **14. ElevenLabs TTS Integration** — Read assistant responses aloud. Integrated audio player with voice selection. Requires API key.
- [ ] **15. One-Click Message Reuse** — Click any message to copy it to clipboard or send it back as input to a new CC session.
- [ ] **16. Update Announcements** — Toast notifications for new LUMNO versions. Check GitHub releases or a manifest URL. Use Sparkle framework.
- [ ] **17. Onboarding Flow** — First-run experience: detect Claude Code CLI, request file access permissions, brief feature tour.
- [ ] **18. User-Defined Panels** — Custom panels for lint output, build logs, test results — user-configured commands that run alongside sessions.

## Future

- [ ] **19. Subscription & Licensing** — RevenueCat/Stripe integration for Lumno Pro. Trial period, license validation, premium feature gates.
- [ ] **20. Menu Bar Companion** — Lightweight menu bar icon showing CC status, quick search, recent sessions without opening the main window.
- [ ] **21. Session Analytics** — Token usage over time, model distribution, most-used tools, project activity charts.
- [ ] **22. Theme Customization** — Light mode, custom accent colors, font size preferences.
- [ ] **23. Keyboard-First Navigation** — Vim-style key bindings, full keyboard navigation across all views, command palette.
- [ ] **24. Export & Share** — Export sessions as Markdown/HTML/PDF. Share diffs or conversations.

## Release

- [ ] **25. Create Open-Source Repository** — Create the public GitHub repository (e.g. `lumno-app/lumno`). Prepare a clean history (squash or cherry-pick from this closed-source repo), strip any private config, add CONTRIBUTING.md, CODE_OF_CONDUCT.md, issue templates, and publish the first tagged release.
