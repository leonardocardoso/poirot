# Step 5 — CI Pipeline

> **Status:** TODO
> **Created:** 2026-02-19
> **Feature:** #0 Architecture & Best Practices
> **Depends on:** Step 1 (project.yml), Step 4 (Test Target)

## Summary

Create a GitHub Actions CI pipeline that builds, tests, and lints the project on every PR to `main` and push to `main`. Uses `macos-latest` runner with `CODE_SIGNING_ALLOWED=NO` for CI compatibility.

---

## Scope

### IN SCOPE
- GitHub Actions workflow file
- Trigger on PR to `main` and push to `main`
- Steps: checkout, select Xcode, install XcodeGen, generate project, build, test, lint
- SwiftLint with `github-actions-logging` reporter for inline annotations

### OUT OF SCOPE
- Release automation
- Code signing / notarization
- Deployment pipelines
- Caching (can add later for speed)

---

## Implementation Order

### Step 1: Create workflow file
- [ ] Create `.github/workflows/build-and-test.yml`
- [ ] Configure trigger events (`pull_request` to `main`, `push` to `main`)
- [ ] Set `macos-latest` runner
- [ ] Add concurrency group to cancel stale runs

### Step 2: Define build steps
- [ ] Checkout code
- [ ] Select Xcode version with `sudo xcode-select -s`
- [ ] Install XcodeGen via Homebrew
- [ ] Run `xcodegen generate`
- [ ] Build with `xcodebuild -scheme Lumno build CODE_SIGNING_ALLOWED=NO`

### Step 3: Define test steps
- [ ] Run `xcodebuild test -scheme Lumno -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO`

### Step 4: Define lint step
- [ ] Install SwiftLint via Homebrew
- [ ] Run `swiftlint lint --config .swiftlint.yml --path Lumno/Sources --reporter github-actions-logging`

---

## Files to Create

| File | Purpose |
|------|---------|
| `.github/workflows/build-and-test.yml` | GitHub Actions CI pipeline |

---

## Workflow Reference

```yaml
name: Build & Test

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build-and-test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

      - name: Install XcodeGen
        run: brew install xcodegen

      - name: Generate Xcode project
        run: xcodegen generate

      - name: Build
        run: |
          xcodebuild -scheme Lumno \
            -destination 'platform=macOS' \
            CODE_SIGNING_ALLOWED=NO \
            build

      - name: Test
        run: |
          xcodebuild -scheme Lumno \
            -destination 'platform=macOS' \
            CODE_SIGNING_ALLOWED=NO \
            test

      - name: Lint
        run: |
          brew install swiftlint
          swiftlint lint \
            --config .swiftlint.yml \
            --path Lumno/Sources \
            --reporter github-actions-logging
```

---

## Verification

1. Workflow file passes YAML validation
2. CI runs successfully on push to a test branch
3. Build, test, and lint steps all pass
4. SwiftLint violations appear as inline annotations on PRs

---

## Notes

- `CODE_SIGNING_ALLOWED=NO` bypasses code signing for CI (no certificates needed)
- `github-actions-logging` reporter makes SwiftLint issues appear inline in PR diffs
- `concurrency` group cancels previous runs when new commits are pushed
- `macos-latest` provides Xcode pre-installed
