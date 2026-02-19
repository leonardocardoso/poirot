# Step 7 — Update SwiftLint

> **Status:** TODO
> **Created:** 2026-02-19
> **Feature:** #0 Architecture & Best Practices
> **Depends on:** None

## Summary

Upgrade SwiftLint from the currently installed v0.22.0 to the latest version. The current version is extremely outdated (2017-era) and lacks support for Swift 6, modern rules, and the `github-actions-logging` reporter needed for CI.

---

## Scope

### IN SCOPE
- Upgrade SwiftLint via Homebrew
- Verify `.swiftlint.yml` compatibility with new version
- Fix any rule name changes or deprecations
- Verify lint passes on existing codebase

### OUT OF SCOPE
- Adding new lint rules beyond what's already configured
- Changing rule thresholds

---

## Implementation Order

### Step 1: Upgrade SwiftLint
- [ ] Run `brew upgrade swiftlint` (or `brew install swiftlint` if the formula changed)
- [ ] Verify new version with `swiftlint version`

### Step 2: Check config compatibility
- [ ] Run `swiftlint lint --config .swiftlint.yml --path Lumno/Sources`
- [ ] Identify any deprecated/renamed rules
- [ ] Update `.swiftlint.yml` if needed

### Step 3: Fix any violations
- [ ] Address any new violations from updated rules
- [ ] Ensure zero errors on existing codebase

---

## Files to Modify

| File | Changes |
|------|---------|
| `.swiftlint.yml` | Update any deprecated/renamed rules (if needed) |

---

## Known Rule Changes (v0.22 → latest)

The following rules may have been renamed or deprecated between v0.22 and the latest:
- `legacy_cggeometry_functions` — may be consolidated
- `legacy_nsgeometry_functions` — may be consolidated
- `multiple_closures_with_trailing_closure` — renamed to `multiple_closures_with_trailing_closure` (check)
- Various new rules available but not adding them in this step

---

## Verification

1. `swiftlint version` shows a recent version (0.55+)
2. `swiftlint lint --config .swiftlint.yml --path Lumno/Sources` — no errors
3. CI pipeline (Step 5) can use `github-actions-logging` reporter

---

## Notes

- SwiftLint v0.22.0 was released in 2017 — 9 years old
- Modern SwiftLint supports Swift 6 syntax, async/await, and macros
- The `github-actions-logging` reporter was added in a much later version
- May need to handle the `swiftlint` binary being at a different path after upgrade
