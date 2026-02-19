# Contributing to LUMNO

Thanks for your interest in contributing to LUMNO! Here's how to get started.

## Prerequisites

- macOS 15.0+
- Xcode 16.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — `brew install xcodegen`
- [SwiftLint](https://github.com/realm/SwiftLint) — `brew install swiftlint`

## Building

```bash
git clone https://github.com/leocardz/lumno.git
cd lumno
xcodegen generate
open Lumno.xcodeproj
```

Build with **Cmd+B** in Xcode, or from the command line:

```bash
xcodebuild -scheme Lumno -destination 'platform=macOS' -skipMacroValidation build
```

## Testing

Run the full test suite:

```bash
xcodebuild test -scheme Lumno -destination 'platform=macOS' -skipMacroValidation
```

Tests use [Swift Testing](https://developer.apple.com/documentation/testing/) (`@Test`, `#expect`, `#require`). We do not use XCTest for new tests.

## Code Style

- **Swift 6** with `MainActor` default isolation — all types are implicitly `@MainActor`
- **SwiftLint** runs automatically during build (see `.swiftlint.yml`)
- **SwiftFormat** for formatting (see `.swiftformat`)
- Use `nonisolated` only for file I/O or heavy computation
- New service protocols use `@Mockable` macro for auto-generated mocks

## Architecture

```
Lumno/Sources/
├── App/           # App entry point, ContentView, AppState
├── Models/        # Value-type structs (Project, Session, Message)
├── Protocols/     # Service protocols with @Mockable
├── Services/      # Concrete implementations + Environment DI
├── Theme/         # Design tokens (LumnoTheme)
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
