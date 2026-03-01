@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("Plans Screenshots")
struct ScreenshotTests_Plans {
    private let isRecording = false

    private var provider: ClaudeCodeProvider { ClaudeCodeProvider() }

    private func configItem(id: String) -> ConfigurationItem {
        provider.configurationItems.first { $0.id == id }!
    }

    @Test
    func testPlansList() async throws {
        try await snapshotView(
            withEnvironment(
                PlansListView(item: configItem(id: "plans")),
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testPlansList",
            record: isRecording,
            delay: 2,
            colorScheme: .light
        )
    }

    @Test
    func testPlansFullApp() async throws {
        let state = makeAppState(selectedNav: .plans)

        try await snapshotView(
            compositeAppView(state: state, provider: provider) {
                PlansListView(item: configItem(id: "plans"))
            },
            size: ScreenshotSize.fullApp,
            named: "testPlansFullApp",
            record: isRecording,
            delay: 2
        )
    }
}
