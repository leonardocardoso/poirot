import Foundation

/// A single parsed entry from a Claude Code debug log file.
nonisolated struct DebugLogEntry: Identifiable, Hashable, Sendable {
    let id: Int
    let timestamp: Date
    let level: Level
    let message: String

    enum Level: String, CaseIterable, Sendable {
        case debug = "DEBUG"
        case warn = "WARN"
        case error = "ERROR"

        var label: String { rawValue }
    }
}
