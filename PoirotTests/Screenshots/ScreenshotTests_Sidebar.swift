import SnapshotTesting
import SwiftUI
import Testing

@testable import Poirot

@Suite("Sidebar Screenshots")
struct ScreenshotTests_Sidebar {
    private let isRecording = false

    // MARK: - Sidebar with Projects

    @Test
    func testSidebarWithProjects() {
        let state = makeAppState(
            selectedProject: ScreenshotData.projects.first?.id
        )

        snapshotView(
            SidebarView()
                .environment(state)
                .environment(\.provider, ClaudeCodeProvider()),
            size: ScreenshotSize.sidebar,
            named: "testSidebarWithProjects",
            record: isRecording
        )
    }

    // MARK: - Sidebar Loading

    @Test
    func testSidebarLoading() {
        let state = makeAppState(
            projects: [],
            isLoadingProjects: true,
            isLoadingMoreProjects: true
        )

        snapshotView(
            SidebarView()
                .environment(state)
                .environment(\.provider, ClaudeCodeProvider()),
            size: ScreenshotSize.sidebar,
            named: "testSidebarLoading",
            record: isRecording
        )
    }

    // MARK: - Sidebar Config Nav Active

    @Test
    func testSidebarConfigActive() {
        let state = makeAppState(selectedNav: .commands)

        snapshotView(
            SidebarView()
                .environment(state)
                .environment(\.provider, ClaudeCodeProvider()),
            size: ScreenshotSize.sidebar,
            named: "testSidebarConfigActive",
            record: isRecording
        )
    }

    // MARK: - Sidebar with Search

    @Test
    func testSidebarSearch() {
        let state = makeAppState()
        state.sidebarSearchQuery = "poirot"

        snapshotView(
            SidebarView()
                .environment(state)
                .environment(\.provider, ClaudeCodeProvider()),
            size: ScreenshotSize.sidebar,
            named: "testSidebarSearch",
            record: isRecording
        )
    }
}
