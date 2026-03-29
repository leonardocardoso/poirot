@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("Full View Screenshots")
struct ScreenshotTests_FullViews {
    private let isRecording = false

    // MARK: - Hero (Full App — Sidebar + Session Detail)

    @Test
    func testHero() async throws {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        let state = makeAppState(
            selectedSession: ScreenshotData.conversationSession,
            selectedProject: ScreenshotData.projects.first?.id
        )

        try await snapshotView(
            compositeAppView(state: state) {
                SessionDetailView(session: ScreenshotData.conversationSession)
            },
            size: ScreenshotSize.fullApp,
            named: "testHero",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - Session Browser (Sidebar + Sessions Navigation) — light mode

    @Test
    func testSessionBrowser() async throws {
        let state = makeAppState(
            selectedSession: ScreenshotData.conversationSession,
            selectedProject: ScreenshotData.projects.first?.id
        )

        try await snapshotView(
            compositeAppView(state: state) {
                SessionsNavigationView()
            },
            size: ScreenshotSize.fullApp,
            named: "testSessionBrowser",
            record: isRecording,
            delay: 2,
            colorScheme: .light
        )
    }

    // MARK: - Multi-Agent Sessions (Sidebar + Sessions with sub-agents grouped)

    @Test
    func testMultiAgentSessions() async throws {
        let state = makeAppState(
            selectedSession: ScreenshotData.conversationSession,
            selectedProject: ScreenshotData.projects.first?.id
        )
        state.showAgentSessions = true

        try await snapshotView(
            compositeAppView(state: state) {
                SessionsNavigationView()
            },
            size: ScreenshotSize.fullApp,
            named: "testMultiAgentSessions",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - Conversation View

    @Test
    func testConversationView() async throws {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        try await snapshotView(
            withEnvironment(SessionDetailView(session: ScreenshotData.conversationSession)),
            size: ScreenshotSize.mainContent,
            named: "testConversationView",
            record: isRecording,
            delay: 0.5
        )
    }

    // MARK: - Tool Blocks — light mode

    @Test
    func testToolBlocks() async throws {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        try await snapshotView(
            withEnvironment(SessionDetailView(session: ScreenshotData.toolBlocksSession)),
            size: ScreenshotSize.mainContent,
            named: "testToolBlocks",
            record: isRecording,
            delay: 0.5,
            colorScheme: .light
        )
    }

    // MARK: - Thinking Blocks

    @Test
    func testThinkingBlocks() async throws {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        try await snapshotView(
            withEnvironment(SessionDetailView(session: ScreenshotData.thinkingSession)),
            size: ScreenshotSize.mainContent,
            named: "testThinkingBlocks",
            record: isRecording,
            delay: 0.5
        )
    }

    // MARK: - Search Overlay (Sidebar + Overlay) — light mode

    @Test
    func testSearch() async throws {
        let state = makeAppState(isSearchPresented: true)

        try await snapshotView(
            compositeAppView(state: state) {
                Color.clear
                    .overlay {
                        SearchOverlayView()
                    }
            },
            size: ScreenshotSize.fullApp,
            named: "testSearch",
            record: isRecording,
            delay: 2,
            colorScheme: .light
        )
    }

    // MARK: - Config Screen

    @Test
    func testConfigScreen() async throws {
        let provider = ClaudeCodeProvider()

        try await snapshotView(
            CommandsListView(item: provider.configurationItems.first { $0.id == "commands" }!)
                .environment(makeAppState())
                .environment(\.provider, provider),
            size: ScreenshotSize.mainContent,
            named: "testConfigScreen",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - Settings

    @Test
    func testSettings() async throws {
        try await snapshotView(
            withEnvironment(SettingsView()),
            size: CGSize(width: 500, height: 400),
            named: "testSettings",
            record: isRecording,
            delay: 2
        )
    }
}
