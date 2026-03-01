@testable import Poirot
import Foundation
import Testing

@Suite("AnalyticsViewModel")
struct AnalyticsViewModelTests {
    // MARK: - Test Data

    private static func makeStats(
        dailyActivity: [StatsCache.DailyActivity] = [],
        dailyModelTokens: [StatsCache.DailyModelTokens] = [],
        modelUsage: [String: StatsCache.ModelUsage] = [:],
        totalSpeculationTimeSavedMs: Int = 0
    ) -> StatsCache {
        StatsCache(
            version: 2,
            lastComputedDate: "2026-02-17",
            dailyActivity: dailyActivity,
            dailyModelTokens: dailyModelTokens,
            modelUsage: modelUsage,
            totalSessions: 10,
            totalMessages: 100,
            longestSession: StatsCache.LongestSession(
                sessionId: "test",
                duration: 3_600_000,
                messageCount: 50,
                timestamp: "2026-01-01T00:00:00.000Z"
            ),
            firstSessionDate: "2025-12-31T19:57:52.149Z",
            hourCounts: ["9": 5, "14": 10],
            totalSpeculationTimeSavedMs: totalSpeculationTimeSavedMs
        )
    }

    private static let sampleActivity: [StatsCache.DailyActivity] = [
        .init(date: "2026-01-01", messageCount: 100, sessionCount: 5, toolCallCount: 50),
        .init(date: "2026-01-15", messageCount: 200, sessionCount: 8, toolCallCount: 120),
        .init(date: "2026-02-01", messageCount: 300, sessionCount: 10, toolCallCount: 80),
        .init(date: "2026-02-15", messageCount: 150, sessionCount: 3, toolCallCount: 40),
    ]

    private static let sampleModelTokens: [StatsCache.DailyModelTokens] = [
        .init(date: "2026-01-01", tokensByModel: ["claude-opus-4-5-20251101": 1000]),
        .init(date: "2026-02-01", tokensByModel: ["claude-opus-4-5-20251101": 2000, "claude-opus-4-6": 500]),
    ]

    private static let sampleModelUsage: [String: StatsCache.ModelUsage] = [
        "claude-opus-4-5-20251101": .init(
            inputTokens: 1000,
            outputTokens: 2000,
            cacheReadInputTokens: 500,
            cacheCreationInputTokens: 300,
            webSearchRequests: 0,
            costUSD: 15.50,
            contextWindow: 200_000,
            maxOutputTokens: 32000
        ),
        "claude-opus-4-6": .init(
            inputTokens: 800,
            outputTokens: 1500,
            cacheReadInputTokens: 200,
            cacheCreationInputTokens: 100,
            webSearchRequests: 0,
            costUSD: 10.25,
            contextWindow: 200_000,
            maxOutputTokens: 32000
        ),
    ]

    // MARK: - Date Range Filtering

    @Test
    func filteredDailyActivity_allRange_returnsAll() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false
        vm.stats = Self.makeStats(dailyActivity: Self.sampleActivity)
        vm.selectedDateRange = .all

        #expect(vm.filteredDailyActivity.count == 4)
    }

    @Test
    func filteredDailyActivity_weekRange_filtersOldEntries() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false

        // Dates relative to lastComputedDate ("2026-02-17") used in makeStats
        let recentStr = "2026-02-15" // 2 days before lastComputed → within 7d
        let oldStr = "2026-01-18" // 30 days before lastComputed → outside 7d

        vm.stats = Self.makeStats(dailyActivity: [
            .init(date: recentStr, messageCount: 10, sessionCount: 1, toolCallCount: 5),
            .init(date: oldStr, messageCount: 20, sessionCount: 2, toolCallCount: 10),
        ])
        vm.selectedDateRange = .week

        #expect(vm.filteredDailyActivity.count == 1)
        #expect(vm.filteredDailyActivity.first?.date == recentStr)
    }

    // MARK: - Token Time Series

    @Test
    func tokenTimeSeriesData_flatMapsModels() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false
        vm.stats = Self.makeStats(dailyModelTokens: Self.sampleModelTokens)
        vm.selectedDateRange = .all

        // First day: 1 model, second day: 2 models = 3 entries
        #expect(vm.tokenTimeSeriesData.count == 3)
    }

    @Test
    func tokenTimeSeriesData_usesFriendlyNames() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false
        vm.stats = Self.makeStats(dailyModelTokens: Self.sampleModelTokens)
        vm.selectedDateRange = .all

        let models = Set(vm.tokenTimeSeriesData.map(\.model))
        #expect(models.contains("Opus 4.5"))
        #expect(models.contains("Opus 4.6"))
    }

    // MARK: - Cost Breakdown

    @Test
    func costBreakdownEntries_sortedByCostDescending() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false
        vm.stats = Self.makeStats(modelUsage: Self.sampleModelUsage)

        let entries = vm.costBreakdownEntries
        #expect(entries.count == 2)
        #expect(entries[0].cost >= entries[1].cost)
    }

    // MARK: - Summary Computations

    @Test
    func totalCost_sumsModelCosts() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false
        vm.stats = Self.makeStats(modelUsage: Self.sampleModelUsage)

        #expect(vm.totalCost == 15.50 + 10.25)
    }

    @Test
    func totalTokens_sumsInputAndOutput() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false
        vm.stats = Self.makeStats(modelUsage: Self.sampleModelUsage)

        // Input: (1000 + 500 + 300) + (800 + 200 + 100) = 2900
        // Output: 2000 + 1500 = 3500
        #expect(vm.totalTokens == 2900 + 3500)
    }

    @Test
    func totalToolCalls_sumsDailyActivity() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false
        vm.stats = Self.makeStats(dailyActivity: Self.sampleActivity)

        #expect(vm.totalToolCalls == 50 + 120 + 80 + 40)
    }

    @Test
    func timeSavedFormatted_displaysCorrectly() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false
        vm.stats = Self.makeStats(totalSpeculationTimeSavedMs: 3_660_000) // 1h 1m

        #expect(vm.timeSavedFormatted == "1h 1m")
    }

    @Test
    func timeSavedFormatted_zeroMs_showsDash() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false
        vm.stats = Self.makeStats(totalSpeculationTimeSavedMs: 0)

        #expect(vm.timeSavedFormatted == "—")
        #expect(vm.hasTimeSavedData == false)
    }

    @Test
    func hasCostData_zeroCost_returnsFalse() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false
        vm.stats = Self.makeStats(modelUsage: [:])

        #expect(vm.hasCostData == false)
    }

    @Test
    func hasCostData_withCost_returnsTrue() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false
        vm.stats = Self.makeStats(modelUsage: Self.sampleModelUsage)

        #expect(vm.hasCostData == true)
    }

    // MARK: - Custom Date Range

    @Test
    func customRange_filtersCorrectly() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        vm.stats = Self.makeStats(dailyActivity: [
            .init(date: "2026-01-01", messageCount: 10, sessionCount: 1, toolCallCount: 5),
            .init(date: "2026-01-15", messageCount: 20, sessionCount: 2, toolCallCount: 10),
            .init(date: "2026-02-01", messageCount: 30, sessionCount: 3, toolCallCount: 15),
        ])

        let start = formatter.date(from: "2026-01-10")!
        let end = formatter.date(from: "2026-01-20")!
        vm.selectedDateRange = .custom(start: start, end: end)

        #expect(vm.filteredDailyActivity.count == 1)
        #expect(vm.filteredDailyActivity.first?.date == "2026-01-15")
        #expect(vm.isCustomRange == true)
    }

    // MARK: - Heatmap Data

    @Test
    func heatmapData_mapsActivityEntries() {
        let vm = AnalyticsViewModel()
        vm.isLoading = false
        vm.stats = Self.makeStats(dailyActivity: Self.sampleActivity)
        vm.selectedDateRange = .all

        let heatmap = vm.heatmapData
        #expect(heatmap.count == 4)
        #expect(heatmap[0].messages == 100)
        #expect(heatmap[0].sessions == 5)
        #expect(heatmap[0].dateString == "2026-01-01")
    }

    // MARK: - Nil Stats

    @Test
    func filteredDailyActivity_nilStats_returnsEmpty() {
        let vm = AnalyticsViewModel()
        vm.stats = nil

        #expect(vm.filteredDailyActivity.isEmpty)
        #expect(vm.tokenTimeSeriesData.isEmpty)
        #expect(vm.heatmapData.isEmpty)
        #expect(vm.costBreakdownEntries.isEmpty)
        #expect(vm.totalCost == 0)
        #expect(vm.totalTokens == 0)
        #expect(vm.totalToolCalls == 0)
    }
}
