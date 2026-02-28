@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("Todos Screenshots")
struct ScreenshotTests_Todos {
    private let isRecording = false

    @Test
    func testTodosList() async throws {
        try await snapshotView(
            withEnvironment(
                TodosOverviewView(),
                state: makeAppState(selectedNav: .todos)
            ),
            size: ScreenshotSize.mainContent,
            named: "testTodosList",
            record: isRecording,
            delay: 2
        )
    }

    @Test
    func testTodosFullApp() async throws {
        let state = makeAppState(selectedNav: .todos)

        try await snapshotView(
            compositeAppView(state: state) {
                TodosOverviewView()
            },
            size: ScreenshotSize.fullApp,
            named: "testTodosFullApp",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - Solarized Theme

    @Test
    func testTodosFullAppSolarized() async throws {
        ColorThemeStorage.current = .solarized
        defer { ColorThemeStorage.current = .default }

        let state = makeAppState(selectedNav: .todos)

        try await snapshotView(
            compositeAppView(state: state) {
                TodosOverviewView()
            },
            size: ScreenshotSize.fullApp,
            named: "testTodosFullAppSolarized",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - High Contrast Theme

    @Test
    func testTodosFullAppHighContrast() async throws {
        ColorThemeStorage.current = .highContrast
        defer { ColorThemeStorage.current = .default }

        let state = makeAppState(selectedNav: .todos)

        try await snapshotView(
            compositeAppView(state: state) {
                TodosOverviewView()
            },
            size: ScreenshotSize.fullApp,
            named: "testTodosFullAppHighContrast",
            record: isRecording,
            delay: 2
        )
    }
}
