@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("Memory Screenshots")
struct ScreenshotTests_Memory {
    private let isRecording = false

    private var provider: ClaudeCodeProvider { ClaudeCodeProvider() }

    private func configItem(id: String) -> ConfigurationItem {
        provider.configurationItems.first { $0.id == id }!
    }

    @Test
    func testMemoryList() async throws {
        try await snapshotView(
            withEnvironment(
                MemoryListView(item: configItem(id: "memory")),
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testMemoryList",
            record: isRecording,
            delay: 2,
            colorScheme: .light
        )
    }

    @Test
    func testMemoryFullApp() async throws {
        let state = makeAppState(selectedNav: .memory)

        try await snapshotView(
            compositeAppView(state: state, provider: provider) {
                MemoryListView(item: configItem(id: "memory"))
            },
            size: ScreenshotSize.fullApp,
            named: "testMemoryFullApp",
            record: isRecording,
            delay: 2
        )
    }
}
