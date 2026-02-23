@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("Standalone Component Screenshots")
struct ScreenshotTests_Standalone {
    private let isRecording = false

    // MARK: - Toast Styles

    @Test
    func testToastSuccess() {
        let state = makeAppState(toastQueue: [ScreenshotData.successToast])

        snapshotView(
            ToastOverlay()
                .environment(state),
            size: ScreenshotSize.toast,
            named: "testToastSuccess",
            record: isRecording
        )
    }

    @Test
    func testToastError() {
        let state = makeAppState(toastQueue: [ScreenshotData.errorToast])

        snapshotView(
            ToastOverlay()
                .environment(state),
            size: ScreenshotSize.toast,
            named: "testToastError",
            record: isRecording
        )
    }

    @Test
    func testToastInfo() {
        let state = makeAppState(toastQueue: [ScreenshotData.infoToast])

        snapshotView(
            ToastOverlay()
                .environment(state),
            size: ScreenshotSize.toast,
            named: "testToastInfo",
            record: isRecording
        )
    }

    // MARK: - Config Badges

    @Test
    func testConfigBadgeAccent() {
        snapshotView(
            ConfigBadge(text: "Custom", fg: PoirotTheme.Colors.accent, bg: PoirotTheme.Colors.accent.opacity(0.15)),
            size: ScreenshotSize.badge,
            named: "testConfigBadgeAccent",
            record: isRecording
        )
    }

    @Test
    func testConfigBadgeBlue() {
        snapshotView(
            ConfigBadge(text: "Built-in", fg: PoirotTheme.Colors.blue, bg: PoirotTheme.Colors.blue.opacity(0.15)),
            size: ScreenshotSize.badge,
            named: "testConfigBadgeBlue",
            record: isRecording
        )
    }

    @Test
    func testConfigBadgeGreen() {
        snapshotView(
            ConfigBadge(text: "Active", fg: PoirotTheme.Colors.green, bg: PoirotTheme.Colors.green.opacity(0.15)),
            size: ScreenshotSize.badge,
            named: "testConfigBadgeGreen",
            record: isRecording
        )
    }

    // MARK: - Config Scope Badges

    @Test
    func testConfigScopeBadgeProject() {
        snapshotView(
            ConfigScopeBadge(scope: .project),
            size: ScreenshotSize.badge,
            named: "testConfigScopeBadgeProject",
            record: isRecording
        )
    }

    @Test
    func testConfigScopeBadgeGlobal() {
        snapshotView(
            ConfigScopeBadge(scope: .global),
            size: ScreenshotSize.badge,
            named: "testConfigScopeBadgeGlobal",
            record: isRecording
        )
    }

    // MARK: - Project Sessions View

    @Test
    func testProjectSessionsGrid() async throws {
        let state = makeAppState(selectedProject: ScreenshotData.projects.first?.id)

        try await snapshotView(
            ProjectSessionsView(project: ScreenshotData.projects.first!)
                .environment(state)
                .environment(\.provider, ClaudeCodeProvider()),
            size: ScreenshotSize.mainContent,
            named: "testProjectSessionsGrid",
            record: isRecording,
            delay: 1
        )
    }

    // MARK: - Session Skeleton

    @Test
    func testSessionSkeleton() {
        snapshotView(
            withEnvironment(SessionSkeletonView()),
            size: ScreenshotSize.mainContent,
            named: "testSessionSkeleton",
            record: isRecording
        )
    }
}
