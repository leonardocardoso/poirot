# Feature Development Skill

End-to-end orchestrator for building features in LUMNO — from plan through implementation, testing, and shipping. Delegates to specialized skills at each phase.

## When to Use

- User asks to "build", "implement", "develop", or "add" a feature
- User wants to start working on a plan from `docs/PLANS/`
- User says "let's build this" or "start feature X"
- Any task that spans plan → code → test → ship

---

## Workflow Overview

```
┌─────────────────────────────────────────────────────┐
│  Phase 0 — UNDERSTAND                               │
│  Read the plan / gather requirements                 │
│  Explore codebase for context                        │
├─────────────────────────────────────────────────────┤
│  Phase 1 — PLAN                                      │
│  ► plan-manager-skill                                │
│  Create or refine plan in docs/PLANS/                │
│  Move plan TO-DO → IN-PROGRESS                       │
├─────────────────────────────────────────────────────┤
│  Phase 2 — IMPLEMENT                                 │
│  ► swiftui-expert-skill (views, state, composition)  │
│  ► sf-symbols-expert (icons, effects, animations)    │
│  ► swift-concurrency (async, actors, Sendable)       │
│  ► core-data-expert (persistence, if applicable)     │
│  Build after each logical unit                       │
├─────────────────────────────────────────────────────┤
│  Phase 3 — TEST                                      │
│  ► swift-testing-expert (unit + integration tests)   │
│  SwiftMockKit @Mockable for protocol mocks           │
│  Run tests, fix failures                             │
├─────────────────────────────────────────────────────┤
│  Phase 4 — VERIFY                                    │
│  Build succeeds (zero errors, zero warnings)         │
│  All tests pass                                      │
│  SwiftLint clean                                     │
│  SwiftFormat clean                                   │
│  Manual review of SF Symbols, accessibility          │
├─────────────────────────────────────────────────────┤
│  Phase 5 — SHIP                                      │
│  ► show-time-skill (commit, docs, PR, CI, merge)     │
│  Move plan IN-PROGRESS → COMPLETED                   │
└─────────────────────────────────────────────────────┘
```

---

## Phase 0 — Understand

Before writing any code, build a mental model of the feature.

### If a plan exists in `docs/PLANS/`
1. Read the plan file thoroughly
2. Identify all files to create and modify
3. Check dependencies — does this plan depend on another?
4. Read every file listed in "Files to Modify"

### If no plan exists
1. Ask the user to describe the feature
2. Explore the codebase for related patterns and conventions
3. Move to Phase 1 to create a plan

### Codebase Context Checklist
- [ ] Read `CLAUDE.md` for project rules
- [ ] Read `project.yml` for targets, dependencies, build settings
- [ ] Read `LumnoTheme.swift` for design tokens
- [ ] Read related existing views/models/services for patterns
- [ ] Check `design/mockups.html` for relevant screen mockups

---

## Phase 1 — Plan

**Skill**: `plan-manager-skill`

### Create or refine the plan
- If no plan exists: create one in `docs/PLANS/TO-DO/` following the template
- If a plan exists and is in TO-DO: review, refine if needed, then move to IN-PROGRESS

### Plan quality checklist
- [ ] Clear scope (what's in, what's out)
- [ ] Files to create and modify are listed
- [ ] Implementation steps are ordered with dependencies
- [ ] Test cases are identified
- [ ] No ambiguity — each step is actionable

### Move to IN-PROGRESS
```bash
mv docs/PLANS/TO-DO/<plan>.md docs/PLANS/IN-PROGRESS/
```
Update the plan's status header to `IN-PROGRESS`.

---

## Phase 2 — Implement

Work through the plan's implementation steps sequentially. After each logical unit of work, **build to catch issues early**.

### Skill Routing

For each piece of code, invoke the most relevant skill:

| I'm writing... | Invoke skill |
|-----------------|-------------|
| SwiftUI views, state management, view composition | `swiftui-expert-skill` |
| Icons, symbol effects, rendering modes, animations | `sf-symbols-expert` |
| async/await, actors, Task, Sendable, @MainActor | `swift-concurrency` |
| Core Data models, fetch requests, migrations | `core-data-expert` |
| Protocols for DI | Follow `CLAUDE.md` rules (add `@Mockable`) |

### Implementation Rules

1. **Read before write** — Always read existing files before modifying
2. **Follow existing patterns** — Match the style of surrounding code
3. **SF Symbols always** — Every icon must use `Image(systemName:)` with appropriate effect (see `sf-symbols-expert`)
4. **Accessibility** — Gate indefinite animations behind `@Environment(\.accessibilityReduceMotion)`
5. **Protocol-first DI** — New services get a protocol with `@Mockable`, injected via `EnvironmentValues`
6. **Concurrency** — File I/O and heavy work is `nonisolated`, UI stays on MainActor (default)
7. **Build frequently** — Run `xcodebuild -scheme Lumno build` after each logical unit:
   ```bash
   xcodebuild -scheme Lumno -destination 'platform=macOS' build 2>&1 | tail -5
   ```
8. **Fix immediately** — If build fails, fix before continuing to next step

### Implementation Order
When the plan has numbered steps, follow them in order. Within each step:
1. Create new files (protocols, models, services)
2. Modify existing files (wire up new code)
3. Build and verify

---

## Phase 3 — Test

**Skill**: `swift-testing-expert`

### Test Strategy
- **Unit tests** for models, services, and business logic
- **Mock-based tests** for anything depending on protocols (use `@Mockable` auto-generated mocks via SwiftMockKit)
- **View tests** only if behavior is complex (prefer testing the underlying logic)

### Writing Tests
1. Create test files in `LumnoTests/` mirroring the source structure
2. Use Swift Testing exclusively (`@Test`, `#expect`, `#require`, `@Suite`)
3. Follow naming: `func methodName_condition_expectedResult()`
4. Use SwiftMockKit-generated mocks (e.g., `SessionLoadingMock`) — never hand-write mocks for `@Mockable` protocols
5. Consult `swift-testing-expert` for:
   - Parameterized tests (`@Test(arguments:)`)
   - Async test patterns
   - Traits and tags
   - Test organization

### Running Tests
```bash
xcodebuild test -scheme Lumno -destination 'platform=macOS' 2>&1 | tail -20
```

### Test Quality Gate
- [ ] All tests pass
- [ ] Each new public method has at least one test
- [ ] Edge cases covered (empty arrays, nil values, error paths)
- [ ] Mocks verify expected interactions

---

## Phase 4 — Verify

Run all quality checks before shipping.

### Build
```bash
xcodebuild -scheme Lumno -destination 'platform=macOS' build 2>&1 | tail -5
```
**Gate**: Zero errors, zero warnings.

### Tests
```bash
xcodebuild test -scheme Lumno -destination 'platform=macOS' 2>&1 | tail -20
```
**Gate**: All tests pass.

### Lint
```bash
swiftlint lint --config .swiftlint.yml --path Lumno/Sources 2>&1 | tail -20
```
**Gate**: No errors (warnings acceptable but minimize).

### Format
```bash
swiftformat --config .swiftformat Lumno/Sources --lint 2>&1 | tail -20
```
**Gate**: No formatting violations.

### SF Symbols Review
Scan implemented views for:
- [ ] Every icon uses `Image(systemName:)` (no custom assets)
- [ ] Stateful icons have `.symbolEffect(...)` or `.contentTransition(...)`
- [ ] Indefinite effects gated by `reduceMotion`
- [ ] `hierarchical` rendering for sidebar/toolbar icons
- [ ] `.font(.system(size:))` for sizing, not `.resizable().frame()`

### Accessibility Review
- [ ] Icon-only buttons have `.accessibilityLabel(...)`
- [ ] Decorative icons have `.accessibilityHidden(true)`
- [ ] Animations respect `@Environment(\.accessibilityReduceMotion)`

---

## Phase 5 — Ship

**Skill**: `show-time-skill` (for full pipeline) or manual steps below.

### Commit
- Group changes by logical concern
- Concise commit message explaining "why"
- Never mention AI co-authoring

### PR
- Title under 70 characters
- Body includes summary bullets and test plan
- Link to related issues/plans

### Complete Plan
```bash
mv docs/PLANS/IN-PROGRESS/<plan>.md docs/PLANS/COMPLETED/
```
Update the plan's status header to `COMPLETED`.

---

## Quick Reference — Skill Decision Tree

```
"I need to..."
│
├── "...plan a feature"
│   └── plan-manager-skill
│
├── "...build a SwiftUI view"
│   └── swiftui-expert-skill
│       └── needs icons? → sf-symbols-expert
│
├── "...add an icon or animate a symbol"
│   └── sf-symbols-expert
│
├── "...handle async work, actors, Sendable"
│   └── swift-concurrency
│
├── "...persist data with Core Data"
│   └── core-data-expert
│
├── "...write or fix tests"
│   └── swift-testing-expert
│
├── "...create a PR"
│   └── create-pr-skill
│
├── "...commit, review, merge — full pipeline"
│   └── show-time-skill
│       ├── docs-update-skill (auto)
│       └── create-pr-skill (auto)
│
└── "...update documentation"
    └── docs-update-skill
```

---

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Implement without reading existing code | Read all related files first |
| Write all code then build once at the end | Build after each logical unit |
| Hand-write mocks for `@Mockable` protocols | Use SwiftMockKit auto-generated mocks |
| Skip SF Symbols effects on stateful icons | Add appropriate `.symbolEffect(...)` |
| Use XCTest APIs in new tests | Use Swift Testing (`@Test`, `#expect`) |
| Add explicit `@MainActor` annotations | Rely on default isolation; use `nonisolated` for opt-out |
| Ship without running lint + format | Always run Phase 4 checks |
| Push large monolithic commits | Group by logical concern |
