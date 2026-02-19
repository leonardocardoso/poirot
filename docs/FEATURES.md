# LUMNO — Feature Roadmap

## Foundation

- [ ] **0. Architecture & Best Practices** — Establish project conventions for open-source readiness: Swift 6 language mode with `@MainActor` default isolation, MVVM with Observation, dependency injection via SwiftUI Environment, protocol-driven services, unit test target (Swift Testing), SwiftLint strict profile, SwiftFormat, CONTRIBUTING.md, code documentation standards, CI pipeline (GitHub Actions for build/test/lint), and semantic versioning.
- [ ] **1. Provider Configuration System** — Scalable LLM provider architecture. Each provider (Claude, future: GPT, Gemini, etc.) defines its supported models, feature capabilities (skills, commands, MCPs, sub-agents), file system paths (history, config), and UI adaptations. Loaded from a `Providers/` configuration directory. The UI adapts based on provider capabilities (e.g., hide Skills tab if provider doesn't support them).

## MVP

- [ ] **2. JSONL Transcript Parser** — Read and parse `~/.claude/projects/` JSONL files into Session/Message models. The foundation everything else depends on.
- [ ] **3. Session History Browser** — List sessions grouped by project with timestamps, model, token counts. Sidebar navigation with project tree.
- [ ] **4. Session Detail View** — Render conversation timeline — user messages, assistant responses, tool blocks (Read, Edit, Bash, etc.) with collapsible sections.
- [ ] **5. Code Diff Viewer** — Syntax-highlighted inline diffs for Edit tool blocks. Show added/removed lines with file paths.
- [ ] **6. Bash Output Renderer** — Render terminal command output from Bash tool blocks with monospace styling and exit status.
- [ ] **7. Fuzzy Search (⌘K)** — Search across all sessions, commands, file paths, and message content. Grouped results with keyboard navigation.
- [ ] **8. IDE/Editor Integration** — One-click open files in preferred editor. Detect from `$EDITOR`/`$VISUAL` env vars, `~/.zshrc`/`~/.bashrc`, or Settings preference. Support: VS Code, Cursor, Xcode, Zed, Vim, etc.
- [ ] **9. Terminal App Selection** — User selects preferred terminal app (Terminal.app, iTerm, Warp, Ghostty, etc.) for opening commands. Auto-detect installed terminals, allow custom app selection.
- [ ] **10. Quick Command Re-run** — Click a previous Bash command to copy it or re-execute. Opens in preferred terminal app.
- [ ] **11. MCP Status Sidebar** — Show connected MCP servers in the sidebar with health status indicators (success/warning/failure). One tap opens the MCP log or config in the preferred terminal.
- [ ] **12. Status Bar** — Show Claude Code active/idle status, current project, working directory, git branch.
- [ ] **13. Real-time File Watching** — Watch `~/.claude/projects/` for new/changed JSONL files using FSEvents. Auto-update session list.

## V1

- [ ] **14. Configuration Dashboard** — Browse and quick-access Skills, Slash Commands, MCPs, Sub-agents, Models from a card-based UI.
- [ ] **15. Model Selection** — Switch default model from a dropdown. Per-project model preferences stored locally.
- [ ] **16. Message Streaming Animation** — Animated token-by-token text rendering when viewing active sessions. Toggle in Settings.
- [ ] **17. ElevenLabs TTS Integration** — Read assistant responses aloud. Integrated audio player with voice selection. Requires API key.
- [ ] **18. One-Click Message Reuse** — Click any message to copy it to clipboard or send it back as input to a new CC session.
- [ ] **19. Update Announcements** — Toast notifications for new LUMNO versions. Check GitHub releases or a manifest URL. Use Sparkle framework.
- [ ] **20. Onboarding Flow** — First-run experience: detect Claude Code CLI, request file access permissions, brief feature tour.
- [ ] **21. User-Defined Panels** — Custom panels for lint output, build logs, test results — user-configured commands that run alongside sessions.

## Future

- [ ] **22. Subscription & Licensing** — RevenueCat/Stripe integration for Lumno Pro. Trial period, license validation, premium feature gates.
- [ ] **23. Menu Bar Companion** — Lightweight menu bar icon showing CC status, quick search, recent sessions without opening the main window.
- [ ] **24. Session Analytics** — Token usage over time, model distribution, most-used tools, project activity charts.
- [ ] **25. Theme Customization** — Light mode, custom accent colors, font size preferences.
- [ ] **26. Keyboard-First Navigation** — Vim-style key bindings, full keyboard navigation across all views, command palette.
- [ ] **27. Export & Share** — Export sessions as Markdown/HTML/PDF. Share diffs or conversations.
- [ ] **28. Additional LLM Providers** — Add support for OpenAI/Codex, Gemini, and other CLI-based coding agents using the provider configuration system.

## Release

- [ ] **29. Create Open-Source Repository** — Create the public GitHub repository (e.g. `lumno-app/lumno`). Prepare a clean history (squash or cherry-pick from this closed-source repo), strip any private config, add CONTRIBUTING.md, CODE_OF_CONDUCT.md, issue templates, and publish the first tagged release.
