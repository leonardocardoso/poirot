import Foundation

enum AnalyticsFormatters {
    private static let dateParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static func parseDate(_ string: String) -> Date {
        dateParser.date(from: string) ?? .now
    }

    static func formatFirstSessionDate(_ date: Date?) -> String {
        guard let date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    static func formatLargeNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        }
        if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000)
        }
        return "\(number)"
    }

    static func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour)\(period)"
    }

    static func formatCost(_ cost: Double) -> String {
        if cost >= 1000 {
            return String(format: "$%.0f", cost)
        }
        if cost >= 100 {
            return String(format: "$%.1f", cost)
        }
        return String(format: "$%.2f", cost)
    }

    static func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    /// Formats a `yyyy-MM-dd` string into the user's locale (e.g. "Feb 17, 2026" or "17 fev. 2026").
    static func formatLocalizedDate(_ dateString: String) -> String {
        let date = parseDate(dateString)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Converts a Date back to `yyyy-MM-dd` string for lookup.
    static func dateToString(_ date: Date) -> String {
        dateParser.string(from: date)
    }

    /// Formats a `yyyy-MM-dd` string into a localized date + time (e.g. "Feb 17, 2026 at 3:45 PM").
    /// When the source is date-only, the time portion will be midnight.
    static func formatLocalizedDateTime(_ dateString: String) -> String {
        // Try ISO8601 with time first, fall back to date-only
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = iso.date(from: dateString) ?? parseDate(dateString)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static func formatDuration(milliseconds: Int) -> String {
        let totalSeconds = milliseconds / 1000
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
