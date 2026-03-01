@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("Session Detail Screenshots")
struct ScreenshotTests_SessionDetail {
    private let isRecording = false

    private func enableExpandedBlocks() {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
    }

    private func disableExpandedBlocks() {
        UserDefaults.standard.removeObject(forKey: "autoExpandBlocks")
    }

    // MARK: - Conversation

    @Test
    func testSessionConversation() async throws {
        enableExpandedBlocks()
        defer { disableExpandedBlocks() }

        try await snapshotView(
            withEnvironment(SessionDetailView(session: ScreenshotData.conversationSession)),
            size: ScreenshotSize.mainContent,
            named: "testSessionConversation",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - Tool Blocks in Context

    @Test
    func testSessionToolBlocks() async throws {
        enableExpandedBlocks()
        defer { disableExpandedBlocks() }

        try await snapshotView(
            withEnvironment(SessionDetailView(session: ScreenshotData.toolBlocksSession)),
            size: ScreenshotSize.mainContent,
            named: "testSessionToolBlocks",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - Thinking Blocks in Context

    @Test
    func testSessionThinking() async throws {
        enableExpandedBlocks()
        defer { disableExpandedBlocks() }

        try await snapshotView(
            withEnvironment(SessionDetailView(session: ScreenshotData.thinkingSession)),
            size: ScreenshotSize.mainContent,
            named: "testSessionThinking",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - Error Tools in Context

    @Test
    func testSessionErrors() async throws {
        enableExpandedBlocks()
        defer { disableExpandedBlocks() }

        try await snapshotView(
            withEnvironment(SessionDetailView(session: ScreenshotData.errorToolSession)),
            size: ScreenshotSize.mainContent,
            named: "testSessionErrors",
            record: isRecording,
            delay: 2,
            colorScheme: .light
        )
    }

    // MARK: - Edit Diffs in Context

    @Test
    func testSessionEditDiffs() async throws {
        enableExpandedBlocks()
        defer { disableExpandedBlocks() }

        try await snapshotView(
            withEnvironment(SessionDetailView(session: ScreenshotData.editDiffSession)),
            size: ScreenshotSize.mainContent,
            named: "testSessionEditDiffs",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - Session Search Active

    @Test
    func testSessionSearchActive() async throws {
        enableExpandedBlocks()
        defer { disableExpandedBlocks() }

        let state = makeAppState(
            isSessionSearchActive: true,
            sessionSearchQuery: "dark"
        )

        try await snapshotView(
            SessionDetailView(session: ScreenshotData.conversationSession)
                .environment(state)
                .environment(\.provider, ClaudeCodeProvider()),
            size: ScreenshotSize.mainContent,
            named: "testSessionSearchActive",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - Tool Filter Active

    @Test
    func testSessionToolFilter() async throws {
        enableExpandedBlocks()
        defer { disableExpandedBlocks() }

        let state = makeAppState(
            isToolFilterActive: true,
            activeToolFilters: ["Bash"]
        )

        try await snapshotView(
            SessionDetailView(session: ScreenshotData.allToolTypesSession)
                .environment(state)
                .environment(\.provider, ClaudeCodeProvider()),
            size: ScreenshotSize.mainContent,
            named: "testSessionToolFilter",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - Empty Session

    @Test
    func testSessionEmpty() {
        snapshotView(
            withEnvironment(SessionDetailView(session: ScreenshotData.emptySession)),
            size: ScreenshotSize.mainContent,
            named: "testSessionEmpty",
            record: isRecording
        )
    }
}
