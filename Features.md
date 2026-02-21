# LUMNO — Feature Plan: Settings

## Overview

Redesign the Settings window (macOS native `Settings` scene) with a complete set of user preferences across two tabs: **General** and **Appearance**. The window is standalone (not embedded in the main app) and opens via `NSApp.sendAction(Selector(("showSettingsWindow:")))`.

**Design reference:** `design/mockups.html` — Screen 7a (General), Screen 7b (Appearance)

---

## General Tab

| Setting | Control | Storage Key | Type | Default | Options / Details |
|---------|---------|-------------|------|---------|-------------------|
| Preferred Terminal | `Picker` | `preferredTerminal` | `String` | `"terminal"` | Terminal, iTerm2, Warp, Ghostty, Kitty, Alacritty |
| Default Editor | `Picker` | `textEditor` | `String` | `"code"` | VS Code, Cursor, Xcode, Zed |
| _subtitle_ | | | | | _"Or set `EDITOR` in your `.zshrc` / `.bashrc`"_ |
| Claude Code CLI Path | `TextField` | `claudeCodePath` | `String` | `"/usr/local/bin/claude"` | Monospace font, validates file exists |
| Confirm before delete | `Toggle` | `confirmBeforeDelete` | `Bool` | `true` | Skip the two-step delete confirmation when OFF |
| Max cached sessions | `Picker` | `maxCachedSessions` | `Int` | `50` | 10, 25, 50, 100, 0 (Unlimited) |

### Terminal enum

```swift
enum PreferredTerminal: String, CaseIterable {
    case terminal   = "Terminal"
    case iterm2     = "iTerm2"
    case warp       = "Warp"
    case ghostty    = "Ghostty"
    case kitty      = "Kitty"
    case alacritty  = "Alacritty"

    var icon: String {
        switch self {
        case .terminal:  "terminal"
        case .iterm2:    "terminal"
        case .warp:      "terminal"
        case .ghostty:   "terminal"
        case .kitty:     "terminal"
        case .alacritty: "terminal"
        }
    }
}
```

### Editor enum

```swift
enum PreferredEditor: String, CaseIterable {
    case vscode = "VS Code"
    case cursor = "Cursor"
    case xcode  = "Xcode"
    case zed    = "Zed"

    var bundleIdentifier: String {
        switch self {
        case .vscode: "com.microsoft.VSCode"
        case .cursor: "com.todesktop.230313mzl4w4u92"
        case .xcode:  "com.apple.dt.Xcode"
        case .zed:    "dev.zed.Zed"
        }
    }

    var cliCommand: String {
        switch self {
        case .vscode: "code"
        case .cursor: "cursor"
        case .xcode:  "xed"
        case .zed:    "zed"
        }
    }
}
```

---

## Appearance Tab

| Setting | Control | Storage Key | Type | Default | Details |
|---------|---------|-------------|------|---------|---------|
| Font Size | `Stepper` (−/+/Reset) | `fontScale` | `CGFloat` | `1.0` | Range: 0.75–1.5, step: 0.05. Already implemented via `AppState`. |
| Format in Markdown | `Toggle` | `formatMarkdown` | `Bool` | `true` | Renders assistant messages as Markdown. Subtitle: _"May increase memory usage on large sessions"_ |
| Message animations | `Toggle` | `showAnimations` | `Bool` | `true` | Already stored as `@AppStorage("showAnimations")` |

---

## Persistence Strategy

All settings use `@AppStorage` (backed by `UserDefaults`), except `fontScale` which is managed through `AppState` (already implemented).

| Key | Type | Default |
|-----|------|---------|
| `preferredTerminal` | `String` | `"terminal"` |
| `textEditor` | `String` | `"code"` |
| `claudeCodePath` | `String` | `"/usr/local/bin/claude"` |
| `confirmBeforeDelete` | `Bool` | `true` |
| `maxCachedSessions` | `Int` | `50` |
| `fontScale` | `Double` | `1.0` |
| `formatMarkdown` | `Bool` | `true` |
| `showAnimations` | `Bool` | `true` |

---

## Window Specification

- **Type:** macOS `Settings` scene (standalone window)
- **Size:** `frame(width: 450, height: 300)` (existing)
- **Tabs:** `TabView` with `.tabItem { Label("General", systemImage: "gearshape") }` and `.tabItem { Label("Appearance", systemImage: "paintbrush") }`
- **Theme:** LUMNO dark palette (`LumnoTheme`)
- **Entry point:** Sidebar footer "Settings" button → `NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)`

---

## Files to Modify

| File | Changes |
|------|---------|
| `Lumno/Sources/App/SettingsView.swift` | Add new settings rows (terminal, confirm delete, max cached sessions, format markdown) |
| `Lumno/Sources/Models/PreferredTerminal.swift` | New enum for terminal options |
| `Lumno/Sources/Models/PreferredEditor.swift` | New enum replacing raw string storage |

---

## Implementation Notes

- **SF Symbols** for all icons (`gearshape`, `paintbrush`, `terminal`, `chevron.down`, `minus`, `plus`)
- **No external assets** — all icons are SF Symbols
- Pickers should display icon + name for terminals and editors
- The `claudeCodePath` text field should use a monospace font (`.font(.system(.body, design: .monospaced))`)
- The "Confirm before delete" toggle gates the deletion confirmation alert in `SidebarView`
- The "Max cached sessions" picker should be consumed by the session-loading service to limit in-memory cache
- The "Format in Markdown" toggle should gate `MarkdownUI` rendering in `SessionDetailView`
