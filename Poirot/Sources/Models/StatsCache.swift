import Foundation

/// Pre-computed analytics cache produced by Claude Code at `~/.claude/stats-cache.json`.
nonisolated struct StatsCache: Codable, Sendable, Equatable {
    let version: Int
    let lastComputedDate: String
    let dailyActivity: [DailyActivity]
    let dailyModelTokens: [DailyModelTokens]
    let modelUsage: [String: ModelUsage]
    let totalSessions: Int
    let totalMessages: Int
    let longestSession: LongestSession
    let firstSessionDate: String
    let hourCounts: [String: Int]
    let totalSpeculationTimeSavedMs: Int

    // MARK: - Nested Types

    nonisolated struct DailyActivity: Codable, Sendable, Equatable, Identifiable {
        var id: String { date }
        let date: String
        let messageCount: Int
        let sessionCount: Int
        let toolCallCount: Int
    }

    nonisolated struct DailyModelTokens: Codable, Sendable, Equatable, Identifiable {
        var id: String { date }
        let date: String
        let tokensByModel: [String: Int]
    }

    nonisolated struct ModelUsage: Codable, Sendable, Equatable {
        let inputTokens: Int
        let outputTokens: Int
        let cacheReadInputTokens: Int
        let cacheCreationInputTokens: Int
        let webSearchRequests: Int
        let costUSD: Double
        let contextWindow: Int
        let maxOutputTokens: Int
    }

    nonisolated struct LongestSession: Codable, Sendable, Equatable {
        let sessionId: String
        let duration: Int
        let messageCount: Int
        let timestamp: String
    }
}

// MARK: - Computed Helpers

nonisolated extension StatsCache {
    /// First session date parsed as a `Date`.
    var firstSessionParsedDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: firstSessionDate)
    }

    /// Longest session duration formatted as a human-readable string.
    var longestSessionFormatted: String {
        let totalSeconds = longestSession.duration / 1000
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    /// Total output tokens across all models.
    var totalOutputTokens: Int {
        modelUsage.values.reduce(0) { $0 + $1.outputTokens }
    }

    /// Total input tokens across all models (including cache reads and creation).
    var totalInputTokens: Int {
        modelUsage.values.reduce(0) { $0 + $1.inputTokens + $1.cacheReadInputTokens + $1.cacheCreationInputTokens }
    }

    /// Total cost across all models.
    var totalCostUSD: Double {
        modelUsage.values.reduce(0) { $0 + $1.costUSD }
    }

    /// Total tool calls across all daily activity.
    var totalToolCalls: Int {
        dailyActivity.reduce(0) { $0 + $1.toolCallCount }
    }

    /// Hour counts sorted by hour (0-23).
    var sortedHourCounts: [(hour: Int, count: Int)] {
        hourCounts
            .compactMap { key, value in
                guard let hour = Int(key) else { return nil }
                return (hour: hour, count: value)
            }
            .sorted { $0.hour < $1.hour }
    }

    /// Friendly model name from raw model ID.
    static func friendlyModelName(_ modelId: String) -> String {
        if modelId.contains("opus-4-6") { return "Opus 4.6" }
        if modelId.contains("opus-4-5") { return "Opus 4.5" }
        if modelId.contains("sonnet-4-5") { return "Sonnet 4.5" }
        if modelId.contains("sonnet-4") { return "Sonnet 4" }
        if modelId.contains("haiku") { return "Haiku" }
        return modelId
    }
}
