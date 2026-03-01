@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("Window Screenshots")
struct ScreenshotTests_Windows {
    private let isRecording = false

    // MARK: - Settings Window

    @Test
    func testSettingsWindow() async throws {
        try await snapshotView(
            withEnvironment(SettingsView()),
            size: ScreenshotSize.settings,
            named: "testSettingsWindow",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - Onboarding Window

    @Test
    func testOnboardingWindow() async throws {
        try await snapshotView(
            withEnvironment(OnboardingView()),
            size: ScreenshotSize.onboarding,
            named: "testOnboardingWindow",
            record: isRecording,
            delay: 0.5,
            colorScheme: .light
        )
    }

    // MARK: - Help Window

    @Test
    func testHelpWindow() async throws {
        try await snapshotView(
            withEnvironment(HelpView()),
            size: ScreenshotSize.help,
            named: "testHelpWindow",
            record: isRecording,
            delay: 0.5
        )
    }

    // MARK: - Home View

    @Test
    func testHomeWindow() async throws {
        try await snapshotView(
            withEnvironment(HomeView()),
            size: ScreenshotSize.mainContent,
            named: "testHomeWindow",
            record: isRecording,
            delay: 0.5
        )
    }
}
