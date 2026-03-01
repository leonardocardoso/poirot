@testable import Poirot
import Foundation
import Testing

@Suite("AnalyticsCSVExporter")
struct AnalyticsCSVExporterTests {
    // MARK: - Test Data

    private static func makeStats() -> StatsCache {
        StatsCache(
            version: 2,
            lastComputedDate: "2026-02-17",
            dailyActivity: [
                .init(date: "2026-01-01", messageCount: 100, sessionCount: 5, toolCallCount: 50),
                .init(date: "2026-01-02", messageCount: 200, sessionCount: 8, toolCallCount: 120),
            ],
            dailyModelTokens: [
                .init(date: "2026-01-01", tokensByModel: [
                    "claude-opus-4-5-20251101": 1000,
                    "claude-opus-4-6": 500,
                ]),
                .init(date: "2026-01-02", tokensByModel: [
                    "claude-opus-4-5-20251101": 2000,
                ]),
            ],
            modelUsage: [
                "claude-opus-4-5-20251101": .init(
                    inputTokens: 4000,
                    outputTokens: 3000,
                    cacheReadInputTokens: 7000,
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
            ],
            totalSessions: 10,
            totalMessages: 300,
            longestSession: .init(
                sessionId: "test",
                duration: 3_600_000,
                messageCount: 50,
                timestamp: "2026-01-01T00:00:00.000Z"
            ),
            firstSessionDate: "2025-12-31T00:00:00.000Z",
            hourCounts: ["9": 5, "14": 10, "22": 3],
            totalSpeculationTimeSavedMs: 0
        )
    }

    // MARK: - Daily Activity Export

    @Test
    func dailyActivity_hasCorrectHeader() {
        let csv = AnalyticsCSVExporter.export(Self.makeStats(), type: .dailyActivity)
        let lines = csv.components(separatedBy: "\n")

        #expect(lines[0] == "Date,Messages,Sessions,Tool Calls")
    }

    @Test
    func dailyActivity_hasCorrectRowCount() {
        let csv = AnalyticsCSVExporter.export(Self.makeStats(), type: .dailyActivity)
        let lines = csv.components(separatedBy: "\n").filter { !$0.isEmpty }

        // 1 header + 2 data rows
        #expect(lines.count == 3)
    }

    @Test
    func dailyActivity_hasCorrectValues() {
        let csv = AnalyticsCSVExporter.export(Self.makeStats(), type: .dailyActivity)
        let lines = csv.components(separatedBy: "\n")

        #expect(lines[1] == "2026-01-01,100,5,50")
        #expect(lines[2] == "2026-01-02,200,8,120")
    }

    // MARK: - Model Usage Export

    @Test
    func modelUsage_hasCorrectHeader() {
        let csv = AnalyticsCSVExporter.export(Self.makeStats(), type: .modelUsage)
        let lines = csv.components(separatedBy: "\n")

        #expect(lines[0] == "Model,Input Tokens,Output Tokens,Cache Read Tokens,Cache Creation Tokens,Cost USD")
    }

    @Test
    func modelUsage_sortedByCostDescending() {
        let csv = AnalyticsCSVExporter.export(Self.makeStats(), type: .modelUsage)
        let lines = csv.components(separatedBy: "\n").filter { !$0.isEmpty }

        // First data row should be the higher cost model
        #expect(lines[1].hasPrefix("Opus 4.5"))
    }

    // MARK: - Daily Tokens Export

    @Test
    func dailyTokens_hasModelColumnsInHeader() {
        let csv = AnalyticsCSVExporter.export(Self.makeStats(), type: .dailyTokens)
        let header = csv.components(separatedBy: "\n")[0]

        #expect(header.hasPrefix("Date,"))
        #expect(header.contains("Opus"))
    }

    @Test
    func dailyTokens_hasMissingModelsAsZero() {
        let csv = AnalyticsCSVExporter.export(Self.makeStats(), type: .dailyTokens)
        let lines = csv.components(separatedBy: "\n").filter { !$0.isEmpty }

        // Second data row: opus-4-6 has no tokens for 2026-01-02 → should be 0
        let secondRow = lines[2]
        #expect(secondRow.contains("0"))
    }

    // MARK: - Hourly Activity Export

    @Test
    func hourlyActivity_hasCorrectHeader() {
        let csv = AnalyticsCSVExporter.export(Self.makeStats(), type: .hourlyActivity)
        let lines = csv.components(separatedBy: "\n")

        #expect(lines[0] == "Hour,Sessions")
    }

    @Test
    func hourlyActivity_sortedByHour() {
        let csv = AnalyticsCSVExporter.export(Self.makeStats(), type: .hourlyActivity)
        let lines = csv.components(separatedBy: "\n").filter { !$0.isEmpty }

        #expect(lines[1] == "9,5")
        #expect(lines[2] == "14,10")
        #expect(lines[3] == "22,3")
    }

    // MARK: - Edge Cases

    @Test
    func emptyDailyActivity_onlyHeader() {
        let stats = StatsCache(
            version: 2,
            lastComputedDate: "2026-02-17",
            dailyActivity: [],
            dailyModelTokens: [],
            modelUsage: [:],
            totalSessions: 0,
            totalMessages: 0,
            longestSession: .init(sessionId: "", duration: 0, messageCount: 0, timestamp: ""),
            firstSessionDate: "",
            hourCounts: [:],
            totalSpeculationTimeSavedMs: 0
        )

        let csv = AnalyticsCSVExporter.export(stats, type: .dailyActivity)
        let lines = csv.components(separatedBy: "\n").filter { !$0.isEmpty }

        #expect(lines.count == 1)
        #expect(lines[0] == "Date,Messages,Sessions,Tool Calls")
    }

    // MARK: - Export Type Properties

    @Test
    func exportType_suggestedFileNames() {
        #expect(AnalyticsExportType.dailyActivity.suggestedFileName == "daily-activity.csv")
        #expect(AnalyticsExportType.modelUsage.suggestedFileName == "model-usage.csv")
        #expect(AnalyticsExportType.dailyTokens.suggestedFileName == "daily-tokens.csv")
        #expect(AnalyticsExportType.hourlyActivity.suggestedFileName == "hourly-activity.csv")
    }
}
