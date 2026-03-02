import AppKit
import Foundation

nonisolated enum AnalyticsExportType: String, CaseIterable, Identifiable, Sendable {
    case dailyActivity = "Daily Activity"
    case modelUsage = "Model Usage"
    case dailyTokens = "Daily Tokens"
    case hourlyActivity = "Hourly Activity"

    var id: String { rawValue }

    var suggestedFileName: String {
        switch self {
        case .dailyActivity: "daily-activity.csv"
        case .modelUsage: "model-usage.csv"
        case .dailyTokens: "daily-tokens.csv"
        case .hourlyActivity: "hourly-activity.csv"
        }
    }
}

enum AnalyticsCSVExporter {
    nonisolated static func export(_ stats: StatsCache, type: AnalyticsExportType) -> String {
        switch type {
        case .dailyActivity: exportDailyActivity(stats)
        case .modelUsage: exportModelUsage(stats)
        case .dailyTokens: exportDailyTokens(stats)
        case .hourlyActivity: exportHourlyActivity(stats)
        }
    }

    // MARK: - Daily Activity

    nonisolated private static func exportDailyActivity(_ stats: StatsCache) -> String {
        var csv = "Date,Messages,Sessions,Tool Calls\n"
        for day in stats.dailyActivity {
            csv += "\(day.date),\(day.messageCount),\(day.sessionCount),\(day.toolCallCount)\n"
        }
        return csv
    }

    // MARK: - Model Usage

    nonisolated private static func exportModelUsage(_ stats: StatsCache) -> String {
        var csv = "Model,Input Tokens,Output Tokens,Cache Read Tokens,Cache Creation Tokens,Cost USD\n"
        for (modelId, usage) in stats.modelUsage.sorted(by: { $0.value.costUSD > $1.value.costUSD }) {
            let name = StatsCache.friendlyModelName(modelId)
            csv += "\(name),\(usage.inputTokens),\(usage.outputTokens),"
            csv += "\(usage.cacheReadInputTokens),\(usage.cacheCreationInputTokens),"
            csv += String(format: "%.2f", usage.costUSD) + "\n"
        }
        return csv
    }

    // MARK: - Daily Tokens

    nonisolated private static func exportDailyTokens(_ stats: StatsCache) -> String {
        let allModels = Set(stats.dailyModelTokens.flatMap(\.tokensByModel.keys)).sorted()
        let friendlyNames = allModels.map { StatsCache.friendlyModelName($0) }
        var csv = "Date," + friendlyNames.joined(separator: ",") + "\n"
        for day in stats.dailyModelTokens {
            let values = allModels.map { "\(day.tokensByModel[$0] ?? 0)" }
            csv += day.date + "," + values.joined(separator: ",") + "\n"
        }
        return csv
    }

    // MARK: - Hourly Activity

    nonisolated private static func exportHourlyActivity(_ stats: StatsCache) -> String {
        var csv = "Hour,Sessions\n"
        for entry in stats.sortedHourCounts {
            csv += "\(entry.hour),\(entry.count)\n"
        }
        return csv
    }

    // MARK: - Save Panel

    @MainActor static func presentSavePanel(csv: String, suggestedName: String) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = suggestedName
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return }

        try? csv.write(to: url, atomically: true, encoding: .utf8)
    }
}
