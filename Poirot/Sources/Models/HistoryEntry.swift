import Foundation

/// A single prompt from Claude Code's global input history (`~/.claude/history.jsonl`).
nonisolated struct HistoryEntry: Identifiable, Hashable, Sendable {
    let id: String
    let display: String
    let pastedContents: [String: String]
    let timestamp: Date
    let project: String

    /// The last path component of the project path, used as a short label.
    var projectName: String {
        (project as NSString).lastPathComponent
    }

    /// A truncated snippet of the prompt suitable for previews.
    var snippet: String {
        let lines = display.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return lines.prefix(3).joined(separator: " ")
    }

    nonisolated(unsafe) private static let relativeDateFormatter = RelativeDateTimeFormatter()

    var timeAgo: String {
        Self.relativeDateFormatter.localizedString(for: timestamp, relativeTo: .now)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: HistoryEntry, rhs: HistoryEntry) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Date Grouping

enum HistoryDateGroup: String, CaseIterable, Identifiable, Sendable {
    case today
    case yesterday
    case thisWeek
    case lastWeek
    case thisMonth
    case older

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: String(localized: "Today")
        case .yesterday: String(localized: "Yesterday")
        case .thisWeek: String(localized: "This Week")
        case .lastWeek: String(localized: "Last Week")
        case .thisMonth: String(localized: "This Month")
        case .older: String(localized: "Older")
        }
    }

    static func group(for date: Date) -> HistoryDateGroup {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return .today
        } else if calendar.isDateInYesterday(date) {
            return .yesterday
        } else if let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start,
                  date >= weekStart {
            return .thisWeek
        } else if let lastWeekDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now),
                  let lastWeekInterval = calendar.dateInterval(of: .weekOfYear, for: lastWeekDate),
                  date >= lastWeekInterval.start {
            return .lastWeek
        } else if let monthStart = calendar.dateInterval(of: .month, for: now)?.start,
                  date >= monthStart {
            return .thisMonth
        } else {
            return .older
        }
    }
}
