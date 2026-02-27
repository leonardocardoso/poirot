import Foundation
import SwiftUI

// MARK: - Date Range

enum AnalyticsDateRange: String, CaseIterable, Identifiable {
    case week = "7d"
    case month = "30d"
    case quarter = "90d"
    case all = "All"

    var id: String { rawValue }

    var dayCount: Int? {
        switch self {
        case .week: 7
        case .month: 30
        case .quarter: 90
        case .all: nil
        }
    }
}

// MARK: - Supporting Types

struct TokenTimeSeriesEntry: Identifiable {
    let id = UUID()
    let date: Date
    let model: String
    let tokens: Int
}

nonisolated struct HeatmapEntry: Sendable {
    let date: Date
    let dateString: String
    let messages: Int
    let sessions: Int
}

struct CostBreakdownEntry: Identifiable {
    let id = UUID()
    let model: String
    let cost: Double
    let inputTokens: Int
    let outputTokens: Int
    let cacheTokens: Int
}

// MARK: - ViewModel

@Observable
final class AnalyticsViewModel {
    var stats: StatsCache?
    var isLoading = true
    var selectedDateRange: AnalyticsDateRange = .all

    // MARK: - Loading

    func loadStats() async {
        isLoading = true
        let loaded = await Task.detached {
            StatsCacheLoader.load()
        }.value
        stats = loaded
        isLoading = false
    }

    // MARK: - Date Filtering

    private var cutoffDate: Date? {
        guard let dayCount = selectedDateRange.dayCount else { return nil }
        return Calendar.current.date(byAdding: .day, value: -dayCount, to: .now)
    }

    // MARK: - Filtered Data

    var filteredDailyActivity: [StatsCache.DailyActivity] {
        guard let stats else { return [] }
        guard let cutoff = cutoffDate else { return stats.dailyActivity }
        return stats.dailyActivity.filter { AnalyticsFormatters.parseDate($0.date) >= cutoff }
    }

    var filteredDailyModelTokens: [StatsCache.DailyModelTokens] {
        guard let stats else { return [] }
        guard let cutoff = cutoffDate else { return stats.dailyModelTokens }
        return stats.dailyModelTokens.filter { AnalyticsFormatters.parseDate($0.date) >= cutoff }
    }

    // MARK: - Token Time Series

    var tokenTimeSeriesData: [TokenTimeSeriesEntry] {
        filteredDailyModelTokens.flatMap { day in
            day.tokensByModel.map { model, tokens in
                TokenTimeSeriesEntry(
                    date: AnalyticsFormatters.parseDate(day.date),
                    model: StatsCache.friendlyModelName(model),
                    tokens: tokens
                )
            }
        }
    }

    // MARK: - Heatmap Data

    var heatmapData: [HeatmapEntry] {
        filteredDailyActivity.map { day in
            HeatmapEntry(
                date: AnalyticsFormatters.parseDate(day.date),
                dateString: day.date,
                messages: day.messageCount,
                sessions: day.sessionCount
            )
        }
    }

    // MARK: - Cost Breakdown

    var costBreakdownEntries: [CostBreakdownEntry] {
        guard let stats else { return [] }
        return stats.modelUsage.map { key, value in
            CostBreakdownEntry(
                model: StatsCache.friendlyModelName(key),
                cost: value.costUSD,
                inputTokens: value.inputTokens,
                outputTokens: value.outputTokens,
                cacheTokens: value.cacheReadInputTokens + value.cacheCreationInputTokens
            )
        }
        .sorted { $0.cost > $1.cost }
    }

    // MARK: - Summary Computations

    var totalCost: Double {
        stats?.totalCostUSD ?? 0
    }

    var totalTokens: Int {
        guard let stats else { return 0 }
        return stats.totalInputTokens + stats.totalOutputTokens
    }

    var totalToolCalls: Int {
        stats?.totalToolCalls ?? 0
    }

    var filteredTotalMessages: Int {
        filteredDailyActivity.reduce(0) { $0 + $1.messageCount }
    }

    var filteredTotalSessions: Int {
        filteredDailyActivity.reduce(0) { $0 + $1.sessionCount }
    }

    var filteredTotalToolCalls: Int {
        filteredDailyActivity.reduce(0) { $0 + $1.toolCallCount }
    }

    var timeSavedFormatted: String {
        guard let stats else { return "0m" }
        return AnalyticsFormatters.formatDuration(milliseconds: stats.totalSpeculationTimeSavedMs)
    }
}
