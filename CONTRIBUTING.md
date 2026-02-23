# Contributing to Poirot

Thanks for your interest in contributing to Poirot! Here's how to get started.

## Prerequisites

- macOS 15.0+
- Xcode 16.0+

SwiftLint and SwiftFormat versions are pinned in the `Mintfile`. If you use [Mint](https://github.com/yonaskolb/Mint), run `mint bootstrap` to install them. Otherwise install via Homebrew (`brew install swiftlint swiftformat`).

> **Note:** The Xcode project is checked into git, so you don't need XcodeGen to build. Only run `mint run xcodegen` if you modify `project.yml`.

## Building

```bash
git clone https://github.com/LeonardoCardoso/Poirot.git
cd Poirot
mint bootstrap        # install SwiftLint & SwiftFormat from Mintfile
open Poirot.xcodeproj
```

Build with **Cmd+B** in Xcode, or from the command line:

```bash
xcodebuild -scheme Poirot -destination 'platform=macOS' -skipMacroValidation build
```

## Testing

Run the full test suite:

```bash
xcodebuild test -scheme Poirot -destination 'platform=macOS' -skipMacroValidation
```

Tests use [Swift Testing](https://developer.apple.com/documentation/testing/) (`@Test`, `#expect`, `#require`). We do not use XCTest for new tests.

## Code Style

- **Swift 6** with `MainActor` default isolation — all types are implicitly `@MainActor`
- **SwiftLint** runs automatically during build (see `.swiftlint.yml`)
- **SwiftFormat** for formatting (see `.swiftformat`)
- Use `nonisolated` only for file I/O or heavy computation
- New service protocols get hand-written mocks in `PoirotTests/Mocks/`

## Architecture

```
Poirot/Sources/
├── App/           # App entry point, ContentView, AppState
├── Models/        # Value-type structs (Project, Session, Message)
├── Protocols/     # Service protocols
├── Services/      # Concrete implementations + Environment DI
├── Theme/         # Design tokens (PoirotTheme)
└── Views/         # SwiftUI views organized by feature
```

- **Models** — Plain structs, `Sendable` by default
- **Services** — Protocol-first with `EnvironmentValues` injection
- **State** — `@Observable` with `@State` (not `ObservableObject`)
- **Icons** — SF Symbols only, with symbol effects for stateful icons

## Pull Requests

1. Fork the repo and create a feature branch from `main`
2. Make your changes with tests
3. Ensure build passes with zero warnings
4. Ensure all tests pass
5. Ensure SwiftLint passes
6. Open a PR against `main`
