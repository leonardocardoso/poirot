@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("History Screenshots")
struct ScreenshotTests_History {
    private let isRecording = false

    @Test
    func testHistoryList() async throws {
        try await snapshotView(
            withEnvironment(
                HistoryListView(),
                state: makeAppState(selectedNav: .history)
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
            compositeAppView(state: state) {
                HistoryListView()
            },
            size: ScreenshotSize.fullApp,
            named: "testHistoryFullApp",
            record: isRecording,
            delay: 2
        )
    }
}
