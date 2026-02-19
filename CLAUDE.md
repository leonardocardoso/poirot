# LUMNO — Project Rules

## Overview
LUMNO is a native macOS SwiftUI companion app for Claude Code. It reads session transcripts from `~/.claude/projects/`, displays them in a rich UI, and lets users manage their Claude Code configuration.

## Architecture
- **Platform**: macOS 15.0+, Swift 6, Xcode 16+
- **Project generation**: XcodeGen (`project.yml` → `xcodegen generate`)
- **Concurrency**: `SWIFT_DEFAULT_ACTOR_ISOLATION: MainActor` — all types are implicitly `@MainActor` unless opted out with `nonisolated`
- **DI**: Protocol-driven services injected via SwiftUI `EnvironmentValues`
- **State**: `@Observable` with `@State` (not `ObservableObject`)
- **Testing**: Swift Testing (`@Test`, `#expect`, `#require`) + SwiftMockKit (`@Mockable`)
- **Linting**: SwiftLint (runs as Xcode build phase)
- **Formatting**: SwiftFormat (see `.swiftformat`)

## Rules

### Icons — SF Symbols Only
- **Always use SF Symbols** (`Image(systemName:)`) for all icons in the app. Never use custom icon assets or emoji for UI elements.
- **Always add symbol effects / animations** where meaningful:
  - `.symbolEffect(.bounce, value:)` for discrete user actions (taps, confirmations)
  - `.symbolEffect(.pulse, isActive:)` for ongoing activity (loading, recording)
  - `.symbolEffect(.variableColor, isActive:)` for scanning/searching states
  - `.contentTransition(.symbolEffect(.replace))` when swapping between related symbols (e.g., play/pause, bell/bell.slash)
  - `.symbolEffect(.breathe, isActive:)` for alive/active indicators (macOS 15+)
  - `.symbolEffect(.wiggle, value:)` for attention-drawing notifications (macOS 15+)
  - `.symbolEffect(.rotate, isActive:)` for processing/syncing states (macOS 15+)
- **Respect accessibility**: gate animations behind `@Environment(\.accessibilityReduceMotion)`
- **Prefer `hierarchical` rendering mode** for sidebar and toolbar icons (adds depth with a single color)
- **Use `.font(.system(size:))` for sizing**, not `.resizable().frame()` — ensures crisp vector rendering
- Refer to the `sf-symbols-expert` skill for comprehensive guidance

### Design System
- Follow the design tokens defined in `design/mockups.html` (LUMNO palette)
- Warm golden accent (`#E8A642`) for active/selected states
- Near-black backgrounds for an IDE-like feel
- Use `LumnoTheme` for all color and spacing constants

### Code Style
- SwiftLint enforced (see `.swiftlint.yml`)
- SwiftFormat enforced (see `.swiftformat`)
- No explicit `@MainActor` annotations needed (default isolation handles it)
- Mark file I/O and heavy computation as `nonisolated`
- All protocols use `@Mockable` macro for auto-generated mocks

### Git & PRs
- Never mention AI co-authoring in commits or PRs
- Branch naming: `feature/description` or `feature/TICKET-description`
- Commits should be concise and explain "why" not "what"
