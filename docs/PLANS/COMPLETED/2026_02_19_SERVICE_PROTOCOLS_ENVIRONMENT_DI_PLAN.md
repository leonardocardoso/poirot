# Step 2 — Service Protocols + Environment DI

> **Status:** TODO
> **Created:** 2026-02-19
> **Feature:** #0 Architecture & Best Practices
> **Depends on:** Step 1 (project.yml)

## Summary

Introduce protocol-driven services with SwiftUI Environment dependency injection. Refactor `SessionLoader` from a static struct to an instance-based service conforming to a `SessionLoading` protocol, and wire it through `EnvironmentValues` so views and tests can inject custom implementations.

---

## Scope

### IN SCOPE
- Create `SessionLoading` protocol with `@Mockable` macro (SwiftMockKit)
- Create `EnvironmentKey` + `EnvironmentValues` extension for session loader
- Refactor `SessionLoader` to instance-based, conforming to `SessionLoading`
- Add injectable `claudeProjectsPath` init parameter for testability
- Mark `discoverProjects()` as `nonisolated` (file I/O should run off main actor)
- Update `ContentView` to use `@Environment(\.sessionLoader)` and load projects in `.task`

### OUT OF SCOPE
- Test implementation (separate plan)
- Additional service protocols (will add as features grow)

---

## Implementation Order

### Step 1: Create `SessionLoading` protocol
- [ ] Create `Lumno/Sources/Protocols/SessionLoading.swift`
- [ ] Import `SwiftMockKit`
- [ ] Annotate with `@Mockable` macro to auto-generate `SessionLoadingMock`
- [ ] Define `protocol SessionLoading: Sendable`
- [ ] Declare `nonisolated func discoverProjects() throws -> [Project]`

### Step 2: Refactor `SessionLoader`
- [ ] Convert from static methods to instance methods
- [ ] Add `let claudeProjectsPath: String` stored property with default
- [ ] Add `init(claudeProjectsPath: String = defaultPath)` for testability
- [ ] Conform to `SessionLoading`
- [ ] Mark `discoverProjects()` as `nonisolated`
- [ ] Make struct conform to `Sendable`

### Step 3: Create Environment integration
- [ ] Create `Lumno/Sources/Services/Environment+Services.swift`
- [ ] Define `SessionLoaderKey: EnvironmentKey` with `defaultValue: SessionLoader()`
- [ ] Add `EnvironmentValues.sessionLoader` computed property

### Step 4: Update `ContentView`
- [ ] Add `@Environment(\.sessionLoader) private var sessionLoader`
- [ ] Replace `.onAppear` with `.task` modifier
- [ ] Load projects using `Task.detached` for background file I/O
- [ ] Assign results to `appState.projects`
- [ ] Remove `// TODO: Load projects` comment

---

## Files to Create

| File | Purpose |
|------|---------|
| `Lumno/Sources/Protocols/SessionLoading.swift` | Protocol defining session loading contract |
| `Lumno/Sources/Services/Environment+Services.swift` | SwiftUI Environment key and extension |

## Files to Modify

| File | Changes |
|------|---------|
| `Lumno/Sources/Services/SessionLoader.swift` | Refactor to instance-based, add protocol conformance |
| `Lumno/Sources/App/ContentView.swift` | Add Environment DI, load projects in `.task` |

---

## Code Sketches

### SessionLoading Protocol

```swift
import SwiftMockKit

@Mockable
protocol SessionLoading: Sendable {
    nonisolated func discoverProjects() throws -> [Project]
}
```

The `@Mockable` macro (from `https://github.com/leocardz/SwiftMockKit-mirror`) auto-generates a `SessionLoadingMock` class with:
- `discoverProjectsCallsCount: Int`
- `discoverProjectsCalled: Bool`
- `discoverProjectsThrowableError: (any Error)?`
- `discoverProjectsReturnValue: [Project]!`
- `discoverProjectsClosure: (() throws -> [Project])?`

### Environment Key

```swift
private struct SessionLoaderKey: EnvironmentKey {
    static let defaultValue: any SessionLoading = SessionLoader()
}

extension EnvironmentValues {
    var sessionLoader: any SessionLoading {
        get { self[SessionLoaderKey.self] }
        set { self[SessionLoaderKey.self] = newValue }
    }
}
```

### ContentView Loading

```swift
@Environment(\.sessionLoader) private var sessionLoader

// In body, replace .onAppear with:
.task {
    let loader = sessionLoader
    do {
        let discovered = try await Task.detached {
            try loader.discoverProjects()
        }.value
        appState.projects = discovered
    } catch {
        print("Failed to load projects: \(error)")
    }
}
```

---

## Verification

1. App compiles with zero warnings
2. App runs and sidebar populates with projects from `~/.claude/projects/`
3. `@Mockable` generates `SessionLoadingMock` — verify in Xcode macro expansion
4. `SessionLoadingMock` can be injected via Environment for tests

---

## Notes

- `Sendable` conformance on the protocol ensures safe cross-isolation usage
- `nonisolated` on `discoverProjects()` allows calling from `Task.detached` without MainActor hop
- The injectable path parameter enables testing with temporary directories
