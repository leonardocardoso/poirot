# Step 3 — Swift 6 + MainActor Compliance

> **Status:** TODO
> **Created:** 2026-02-19
> **Feature:** #0 Architecture & Best Practices
> **Depends on:** Step 1 (project.yml), Step 2 (Service Protocols)

## Summary

Verify and ensure full Swift 6 compliance with `SWIFT_DEFAULT_ACTOR_ISOLATION: MainActor`. With this setting, all types are implicitly `@MainActor` — the goal is to confirm the codebase builds cleanly with zero warnings and only opt out where necessary.

---

## Scope

### IN SCOPE
- Verify `AppState` is implicitly `@MainActor` (no annotation needed)
- Verify all views are implicitly `@MainActor` (no changes needed)
- Verify all model structs are value types and automatically `Sendable`
- Ensure `SessionLoader.discoverProjects()` is `nonisolated` (done in Step 2)
- Build with zero warnings

### OUT OF SCOPE
- Adding explicit `@MainActor` annotations (the default isolation handles this)
- Changing model types from struct to class

---

## Analysis

### Types Already Compliant (No Changes Needed)

| Type | Reason |
|------|--------|
| `AppState` | Implicitly `@MainActor` via default isolation; `@Observable` class |
| `ContentView`, `SidebarView`, etc. | All SwiftUI views — implicitly `@MainActor` |
| `Project`, `Session`, `Message` | Value-type structs — automatically `Sendable` |
| `ContentBlock`, `ToolUse`, `ToolResult`, `TokenUsage` | Value-type structs/enums — automatically `Sendable` |
| `LumnoTheme` | Static constants struct — `Sendable` |

### Types Requiring `nonisolated` Opt-Out

| Type | Method | Reason |
|------|--------|--------|
| `SessionLoader` | `discoverProjects()` | File I/O should not block MainActor |

---

## Implementation Order

### Step 1: Verify clean build
- [ ] Run `xcodebuild -scheme Lumno build` after Steps 1–2 are complete
- [ ] Identify any concurrency warnings or errors
- [ ] Fix any issues (expected: none beyond what Step 2 handles)

### Step 2: Address any remaining warnings
- [ ] Add `nonisolated` to any pure-computation methods that trigger warnings
- [ ] Ensure `Sendable` conformance where needed (should be automatic for structs)

---

## Files to Modify

| File | Changes |
|------|---------|
| None expected | Default MainActor isolation + value-type models = automatic compliance |

---

## Verification

1. `xcodebuild -scheme Lumno build` — zero errors, zero warnings
2. No explicit `@MainActor` annotations needed anywhere
3. All file I/O happens off the main actor via `nonisolated` + `Task.detached`

---

## Notes

- `SWIFT_DEFAULT_ACTOR_ISOLATION: MainActor` is a Swift 6 build setting that makes all declarations implicitly `@MainActor`
- This eliminates the need for manual `@MainActor` annotations on every view and observable
- Only opt out with `nonisolated` where you explicitly want non-isolated behavior (e.g., file I/O)
- Value-type structs (all our models) are automatically `Sendable` in Swift 6
