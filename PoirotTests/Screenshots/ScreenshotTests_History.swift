@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("History Screenshots")
struct ScreenshotTests_History {
    private let isRecording = false
    private let historyMock = ScreenshotData.makeHistoryLoaderMock()

    @Test
    func testHistoryList() async throws {
        try await snapshotView(
            withEnvironment(
                HistoryListView(),
                state: makeAppState(selectedNav: .history),
                historyLoader: historyMock
            ),
            size: ScreenshotSize.mainContent,
            named: "testHistoryList",
            record: isRecording,
            delay: 2
        )
    }

    @Test
    func testHistoryFullApp() async throws {
        let state = makeAppState(selectedNav: .history)

        try await snapshotView(
            compositeAppView(state: state, historyLoader: historyMock) {
                HistoryListView()
            },
            size: ScreenshotSize.fullApp,
            named: "testHistoryFullApp",
            record: isRecording,
            delay: 2,
            precision: 0.97
        )
    }

    @Test
    func testHistoryGrid() async throws {
        let state = makeAppState(selectedNav: .history)
        state.configLayouts[NavigationItem.history.id] = .grid

        try await snapshotView(
            compositeAppView(state: state, historyLoader: historyMock) {
                HistoryListView()
            },
            size: ScreenshotSize.fullApp,
            named: "testHistoryGrid",
            record: isRecording,
            delay: 2,
            precision: 0.97
        )
    }
}
