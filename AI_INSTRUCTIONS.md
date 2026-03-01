# POIROT — Project Rules

## Overview
POIROT is a native macOS SwiftUI companion app for Claude Code. It reads session transcripts from `~/.claude/projects/`, displays them in a rich UI, and lets users manage their Claude Code configuration.

## Architecture
- **Platform**: macOS 15.0+, Swift 6, Xcode 16+
- **Project generation**: XcodeGen (`project.yml` → `xcodegen generate`)
- **Concurrency**: `SWIFT_DEFAULT_ACTOR_ISOLATION: MainActor` — all types are implicitly `@MainActor` unless opted out with `nonisolated`
- **DI**: Protocol-driven services injected via SwiftUI `EnvironmentValues`
- **State**: `@Observable` with `@State` (not `ObservableObject`)
- **Testing**: Swift Testing (`@Test`, `#expect`, `#require`) with hand-written mocks in `PoirotTests/Mocks/`
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
- Follow the design tokens defined in `design/mockups.html` (Poirot palette)
- Warm golden accent (`#E8A642`) for active/selected states
- Near-black backgrounds for an IDE-like feel
- Use `PoirotTheme` for all color and spacing constants

### Code Style
- SwiftLint enforced (see `.swiftlint.yml`)
- SwiftFormat enforced (see `.swiftformat`)
- No explicit `@MainActor` annotations needed (default isolation handles it)
- Mark file I/O and heavy computation as `nonisolated`
- Service protocols have hand-written mocks in `PoirotTests/Mocks/`

### Parallel Development (Worktrees)
- When creating a worktree, change `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml` to avoid conflicts with running instances
- Pattern: `fyi.poirot-N` where N is the worktree number (e.g., `fyi.poirot-1`, `fyi.poirot-2`)
- Determine N by checking existing worktrees or running Poirot instances
- This allows multiple Poirot builds to run simultaneously during development
- Always regenerate the Xcode project after changing: `xcodegen generate`
- Copy `.claude/` directory (skills, commands, settings) from the main branch to the worktree

### Feature Development Workflow
- Create a plan following the project guidelines before implementing
- Use available skills during planning and implementation:
  - `sf-symbols-expert` — icon selection, rendering modes, animations
  - `swiftui-expert-skill` — view composition, state management, performance
  - `swift-testing-expert` — test structure, macros, parameterized tests
  - `swift-concurrency` — async/await, actors, nonisolated patterns
  - `core-data-expert` — if persistence is involved
- Write unit tests when pertinent using Swift Testing (`@Suite`, `@Test`, `#expect`)
- Add snapshot tests when pertinent for new UI components
- Update README with new feature documentation when pertinent, including snapshots

### New Feature Checklist
Every new feature or view must follow these steps:
1. Use existing patterns (list, gallery) for page content layout — do not invent new layout paradigms
2. Use markdown rendering as pertinent (see Sessions and Plans sidebar items for examples)
3. Add items to the universal search (⌘K)
4. Watch for file changes in the feature's respective folder/file for live updates
5. Include in navigation history if pertinent
6. Move new screenshots to `assets/showcase/`
7. Add new information to the `README.md` file

### Git & PRs
- Never mention AI co-authoring in commits or PRs
- Branch naming: `feature/description` or `feature/TICKET-description`
- Commits should be concise and explain "why" not "what"
