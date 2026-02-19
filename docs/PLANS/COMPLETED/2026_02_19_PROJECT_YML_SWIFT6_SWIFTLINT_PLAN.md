# Step 1 — Update project.yml (Swift 6 MainActor, SwiftLint, Test Target, Schemes)

> **Status:** TODO
> **Created:** 2026-02-19
> **Feature:** #0 Architecture & Best Practices
> **Depends on:** None

## Summary

Update `project.yml` to establish the architectural foundation: Swift 6 with `MainActor` default isolation, SwiftLint build phase, a `LumnoTests` unit test target, and an explicit shared scheme for CI.

---

## Scope

### IN SCOPE
- Add `SWIFT_DEFAULT_ACTOR_ISOLATION: MainActor` to base settings
- Move `ENABLE_USER_SCRIPT_SANDBOXING` from base to target level (`false` for SwiftLint script)
- Add SwiftLint `postCompileScripts` to `Lumno` target
- Add SwiftMockKit as remote SPM dependency from `https://github.com/leocardz/SwiftMockKit-mirror`
- Add `LumnoTests` unit test target with `TEST_HOST`, `BUNDLE_LOADER`, and `SwiftMockKit` dependency
- Add explicit `schemes:` block for shared scheme (needed for CI)
- Regenerate Xcode project with `xcodegen generate`

### OUT OF SCOPE
- Actual test implementation (separate plan)
- CI pipeline configuration (separate plan)
- Source code changes for Swift 6 compliance (separate plan)

---

## Implementation Order

### Step 1: Modify `project.yml` base settings
- [ ] Add `SWIFT_DEFAULT_ACTOR_ISOLATION: MainActor` to `settings.base`
- [ ] Remove `ENABLE_USER_SCRIPT_SANDBOXING` from `settings.base`

### Step 2: Add SwiftMockKit as remote SPM package
- [ ] Add `packages:` block with GitHub URL `https://github.com/leocardz/SwiftMockKit-mirror` (branch: `main`)

### Step 3: Update `Lumno` target
- [ ] Add `ENABLE_USER_SCRIPT_SANDBOXING: false` to target-level settings (required for SwiftLint script)
- [ ] Add `postCompileScripts` with SwiftLint invocation
- [ ] Add `SwiftMockKit` as dependency (needed for `@Mockable` macro on protocols in main target)

### Step 4: Add `LumnoTests` target
- [ ] Define test target with `type: bundle.unit-test`
- [ ] Set `sources` to `LumnoTests/`
- [ ] Configure `TEST_HOST: "$(BUILT_PRODUCTS_DIR)/Lumno.app/Contents/MacOS/Lumno"`
- [ ] Configure `BUNDLE_LOADER: "$(TEST_HOST)"`
- [ ] Add dependency on `Lumno` target
- [ ] Add `SwiftMockKit` as dependency

### Step 5: Add shared scheme
- [ ] Define `schemes:` block with `Lumno` scheme
- [ ] Include both `Lumno` and `LumnoTests` targets in build
- [ ] Configure test action with `LumnoTests`

### Step 6: Regenerate and verify
- [ ] Run `xcodegen generate`
- [ ] Run `xcodebuild -scheme Lumno build` — zero errors, zero warnings

---

## Files to Modify

| File | Changes |
|------|---------|
| `project.yml` | Add MainActor isolation, SwiftMockKit package, SwiftLint script, test target, scheme |

---

## SwiftMockKit Package Reference

```yaml
packages:
  SwiftMockKit:
    url: https://github.com/leocardz/SwiftMockKit-mirror
    branch: main
```

SwiftMockKit provides the `@Mockable` macro that auto-generates mock classes from protocols:
- GitHub: `https://github.com/leocardz/SwiftMockKit-mirror`
- Generates `{ProtocolName}Mock` classes with call counting, argument capture, return value configuration
- Uses `swift-syntax-xcframeworks` for macro compilation

---

## SwiftLint Script Reference

```yaml
postCompileScripts:
  - script: |
      if which swiftlint > /dev/null; then
        swiftlint lint --config "${SRCROOT}/.swiftlint.yml" --path "${SRCROOT}/Lumno/Sources"
      else
        echo "warning: SwiftLint not installed"
      fi
    name: SwiftLint
    basedOnDependencyAnalysis: false
```

---

## Verification

1. `xcodegen generate` succeeds without errors
2. `xcodebuild -scheme Lumno build` — zero errors, zero warnings
3. Xcode opens project and shows both targets
4. SwiftLint runs automatically during build

---

## Notes

- `ENABLE_USER_SCRIPT_SANDBOXING` must be `false` at target level for SwiftLint scripts to access the filesystem
- The `MainActor` default isolation means all types are implicitly `@MainActor` unless explicitly opted out with `nonisolated`
- Test target uses hosted testing (runs inside the app) for access to internal types
