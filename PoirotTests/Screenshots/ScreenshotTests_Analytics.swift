@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("Analytics Dashboard Screenshots")
struct ScreenshotTests_Analytics {
    private let isRecording = false

    // Charts have minor anti-aliasing differences between runs, so we use
    // a slightly relaxed precision compared to static UI tests.
    private let chartPrecision: Float = 0.97

    // MARK: - Full App (Sidebar + Analytics Dashboard)

    @Test
    func testAnalyticsDashboard() async throws {
        let state = makeAppState(
            selectedNav: .analytics,
            selectedProject: ScreenshotData.projects.first?.id
        )

        let vm = AnalyticsViewModel(preloaded: Self.mockStats)
        let size = ScreenshotSize.fullApp

        let hostingView = NSHostingController(
            rootView: compositeAppView(state: state) {
                AnalyticsDashboardView(viewModel: vm)
            }
            .environment(\.disableAnimations, true)
            .frame(width: size.width, height: size.height)
        )
        hostingView.view.frame = CGRect(origin: .zero, size: size)

        let window = NSWindow(
            contentRect: CGRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = hostingView
        window.makeKeyAndOrderFront(nil)

        try await Task.sleep(for: .seconds(2))

        assertSnapshot(
            of: hostingView,
            as: .image(precision: chartPrecision, size: size),
            named: "testAnalyticsDashboard",
            record: isRecording
        )
    }

    // MARK: - Main Content Only

    @Test
    func testAnalyticsDashboardContent() async throws {
        let vm = AnalyticsViewModel(preloaded: Self.mockStats)
        let size = ScreenshotSize.mainContent

        let hostingView = NSHostingController(
            rootView: withEnvironment(
                AnalyticsDashboardView(viewModel: vm)
            )
            .environment(\.disableAnimations, true)
            .frame(width: size.width, height: size.height)
        )
        hostingView.view.frame = CGRect(origin: .zero, size: size)

        let window = NSWindow(
            contentRect: CGRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = hostingView
        window.makeKeyAndOrderFront(nil)

        try await Task.sleep(for: .seconds(2))

        assertSnapshot(
            of: hostingView,
            as: .image(precision: chartPrecision, size: size),
            named: "testAnalyticsDashboardContent",
            record: isRecording
        )
    }

    // MARK: - Mock Data

    // swiftlint:disable function_body_length
    private static let mockStats: StatsCache = {
        // Generate 60 days of daily activity for a rich chart
        let calendar = Calendar(identifier: .gregorian)
        let startDate = Date(timeIntervalSince1970: 1_766_500_800) // 2025-12-23
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        var dailyActivity: [StatsCache.DailyActivity] = []
        var dailyModelTokens: [StatsCache.DailyModelTokens] = []

        for dayOffset in 0..<60 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { continue }
            let dateStr = dateFormatter.string(from: date)

            // Varied realistic patterns — more activity on weekdays, occasional spikes
            let weekday = calendar.component(.weekday, from: date)
            let isWeekend = weekday == 1 || weekday == 7
            let baseMsgs = isWeekend ? 120 : 380
            let variance = (dayOffset * 37 + 13) % 200 // deterministic pseudo-random
            let msgCount = max(20, baseMsgs + variance - 100)
            let sessionCount = max(1, msgCount / 40)
            let toolCallCount = msgCount * 2 + variance

            dailyActivity.append(.init(
                date: dateStr,
                messageCount: msgCount,
                sessionCount: sessionCount,
                toolCallCount: toolCallCount
            ))

            // Token distribution — mix of models
            var tokensByModel: [String: Int] = [:]
            tokensByModel["claude-opus-4-5-20251101"] = msgCount * 3200 + variance * 100
            if dayOffset > 20 {
                tokensByModel["claude-opus-4-6"] = msgCount * 2800 + variance * 80
            }
            if dayOffset % 5 == 0 {
                tokensByModel["claude-sonnet-4-5-20250929"] = msgCount * 1200
            }

            dailyModelTokens.append(.init(date: dateStr, tokensByModel: tokensByModel))
        }

        // Hour counts — realistic distribution with peak in afternoon
        var hourCounts: [String: Int] = [:]
        let hourDistribution = [
            0: 2, 1: 1, 2: 0, 3: 0, 4: 0, 5: 1, 6: 3, 7: 8,
            8: 18, 9: 32, 10: 45, 11: 52, 12: 28, 13: 41, 14: 48,
            15: 44, 16: 38, 17: 30, 18: 22, 19: 15, 20: 12, 21: 8,
            22: 5, 23: 3,
        ]
        for (hour, count) in hourDistribution {
            hourCounts["\(hour)"] = count
        }

        return StatsCache(
            version: 2,
            lastComputedDate: "2026-02-20",
            dailyActivity: dailyActivity,
            dailyModelTokens: dailyModelTokens,
            modelUsage: [
                "claude-opus-4-5-20251101": .init(
                    inputTokens: 4_020_186,
                    outputTokens: 3_833_943,
                    cacheReadInputTokens: 7_246_318_082,
                    cacheCreationInputTokens: 325_882_562,
                    webSearchRequests: 0,
                    costUSD: 142.37,
                    contextWindow: 200_000,
                    maxOutputTokens: 32000
                ),
                "claude-opus-4-6": .init(
                    inputTokens: 592_180,
                    outputTokens: 1_778_001,
                    cacheReadInputTokens: 2_323_328_386,
                    cacheCreationInputTokens: 103_861_546,
                    webSearchRequests: 0,
                    costUSD: 68.92,
                    contextWindow: 200_000,
                    maxOutputTokens: 32000
                ),
                "claude-sonnet-4-5-20250929": .init(
                    inputTokens: 32_900,
                    outputTokens: 130_944,
                    cacheReadInputTokens: 684_102_476,
                    cacheCreationInputTokens: 12_340_200,
                    webSearchRequests: 0,
                    costUSD: 8.15,
                    contextWindow: 200_000,
                    maxOutputTokens: 16000
                ),
            ],
            totalSessions: 466,
            totalMessages: 18_742,
            longestSession: .init(
                sessionId: "ce55f01b-e4f4-4c6a-934e-f95ba536935f",
                duration: 321_972_719,
                messageCount: 1504,
                timestamp: "2026-01-13T19:55:30.879Z"
            ),
            firstSessionDate: "2025-12-23T09:15:42.000Z",
            hourCounts: hourCounts,
            totalSpeculationTimeSavedMs: 847_320
        )
    }()
    // swiftlint:enable function_body_length
}
