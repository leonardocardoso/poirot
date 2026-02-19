# Step 6 — Open-Source Docs

> **Status:** TODO
> **Created:** 2026-02-19
> **Feature:** #0 Architecture & Best Practices
> **Depends on:** None

## Summary

Create contributor documentation for open-source readiness: `CONTRIBUTING.md` with prerequisites, building, testing, code style, and PR process; `CODE_OF_CONDUCT.md` using Contributor Covenant v2.1.

---

## Scope

### IN SCOPE
- `CONTRIBUTING.md` — full contributor guide
- `CODE_OF_CONDUCT.md` — Contributor Covenant v2.1

### OUT OF SCOPE
- LICENSE file (already exists or separate decision)
- Issue templates
- PR templates

---

## Implementation Order

### Step 1: Create `CONTRIBUTING.md`
- [ ] Prerequisites section (macOS 15+, Xcode 16+, XcodeGen, SwiftLint)
- [ ] Building instructions (`xcodegen generate`, open Xcode, build)
- [ ] Testing instructions (`xcodebuild test` command)
- [ ] Code style section (SwiftLint, Swift 6, MainActor default)
- [ ] Architecture overview (project structure, Environment DI, protocol-driven services)
- [ ] PR process (fork, branch, test, lint, PR)

### Step 2: Create `CODE_OF_CONDUCT.md`
- [ ] Use Contributor Covenant v2.1
- [ ] Fill in contact details

---

## Files to Create

| File | Purpose |
|------|---------|
| `CONTRIBUTING.md` | Contributor guide |
| `CODE_OF_CONDUCT.md` | Community standards |

---

## CONTRIBUTING.md Outline

```markdown
# Contributing to LUMNO

## Prerequisites
- macOS 15.0+
- Xcode 16.0+
- XcodeGen (`brew install xcodegen`)
- SwiftLint (`brew install swiftlint`)

## Building
1. Clone the repository
2. Run `xcodegen generate`
3. Open `Lumno.xcodeproj`
4. Build with Cmd+B

## Testing
Run tests from Xcode or CLI:
xcodebuild test -scheme Lumno -destination 'platform=macOS'

## Code Style
- Swift 6 with MainActor default isolation
- SwiftLint enforced (runs on build)
- Protocol-driven services with Environment DI

## Architecture
- Models: Value-type structs (Sendable by default)
- Services: Protocol + concrete impl, injected via Environment
- Views: SwiftUI with @Observable state

## Pull Requests
1. Fork and create a feature branch
2. Make changes with tests
3. Ensure build and tests pass
4. Ensure SwiftLint passes
5. Open a PR against main
```

---

## Verification

1. Files exist at project root
2. `CONTRIBUTING.md` is accurate and matches actual build/test commands
3. `CODE_OF_CONDUCT.md` is valid Contributor Covenant v2.1

---

## Notes

- Keep `CONTRIBUTING.md` concise — it should get someone building in under 5 minutes
- Contributor Covenant is the most widely adopted code of conduct for open source
