import Foundation

/// Parses Claude Code debug log files from `~/.claude/debug/`.
///
/// Each file is a plain-text log named `<sessionId>.txt` with lines like:
/// ```
/// 2026-02-06T16:01:34.872Z [DEBUG] Loading MCP servers
/// 2026-02-06T16:01:35.000Z [ERROR] MCP server failed to start
/// ```
nonisolated struct DebugLogLoader: Sendable {
    let claudeDebugPath: String

    init(claudeDebugPath: String? = nil) {
        self.claudeDebugPath = claudeDebugPath ?? Self.defaultPath
    }

    /// Returns the parsed log entries for a given session ID.
    func loadEntries(for sessionId: String) -> [DebugLogEntry] {
        let fileURL = URL(fileURLWithPath: claudeDebugPath)
            .appendingPathComponent("\(sessionId).txt")

        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return []
        }

        return parse(content)
    }

    /// Returns a page of parsed log entries for a given session ID.
    ///
    /// - Parameters:
    ///   - sessionId: The session whose debug log to load.
    ///   - offset: The entry index to start from (0-based).
    ///   - limit: Maximum number of entries to return.
    /// - Returns: A `Page` containing the entries and total count.
    func loadEntries(
        for sessionId: String,
        offset: Int,
        limit: Int
    ) -> Page {
        let fileURL = URL(fileURLWithPath: claudeDebugPath)
            .appendingPathComponent("\(sessionId).txt")

        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return Page(entries: [], totalCount: 0)
        }

        return parsePaged(content, offset: offset, limit: limit)
    }

    struct Page: Sendable, Equatable {
        let entries: [DebugLogEntry]
        let totalCount: Int
    }

    /// Whether a debug log file exists for the given session ID.
    func hasLog(for sessionId: String) -> Bool {
        let path = (claudeDebugPath as NSString)
            .appendingPathComponent("\(sessionId).txt")
        return FileManager.default.fileExists(atPath: path)
    }

    /// Returns session IDs that have debug log files.
    func allSessionIds() -> [String] {
        let fm = FileManager.default
        let dirURL = URL(fileURLWithPath: claudeDebugPath)

        guard let contents = try? fm.contentsOfDirectory(
            at: dirURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return contents
            .filter { $0.pathExtension == "txt" }
            .map { $0.deletingPathExtension().lastPathComponent }
    }

    // MARK: - Parsing

    /// Parses raw debug log text into structured entries.
    func parse(_ text: String) -> [DebugLogEntry] {
        let lines = text.components(separatedBy: .newlines)
        var entries: [DebugLogEntry] = []
        var index = 0

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            if let entry = parseLine(trimmed, index: index) {
                entries.append(entry)
                index += 1
            }
        }

        return entries
    }

    /// Parses a page of entries from raw debug log text.
    func parsePaged(
        _ text: String,
        offset: Int,
        limit: Int
    ) -> Page {
        let lines = text.components(separatedBy: .newlines)
        var entries: [DebugLogEntry] = []
        var index = 0
        let end = offset + limit

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            if let entry = parseLine(trimmed, index: index) {
                if index >= offset, index < end {
                    entries.append(entry)
                }
                index += 1
            }
        }

        return Page(entries: entries, totalCount: index)
    }

    // MARK: - Private

    private func parseLine(
        _ line: String,
        index: Int
    ) -> DebugLogEntry? {
        // Format: "2026-02-06T16:01:34.872Z [DEBUG] message text"
        // The timestamp is an ISO 8601 string followed by a space,
        // then [LEVEL] and the rest is the message.
        guard let bracketOpen = line.firstIndex(of: "[") else {
            return nil
        }

        let timestampStr = String(
            line[line.startIndex ..< bracketOpen]
        ).trimmingCharacters(in: .whitespaces)

        guard let timestamp = Self.parseTimestamp(timestampStr) else {
            return nil
        }

        let afterTimestamp = line[bracketOpen...]
        guard let bracketClose = afterTimestamp.firstIndex(of: "]") else {
            return nil
        }

        let levelStr = String(
            afterTimestamp[
                afterTimestamp.index(after: bracketOpen) ..< bracketClose
            ]
        )

        let level = DebugLogEntry.Level(rawValue: levelStr) ?? .debug

        let messageStart = afterTimestamp.index(after: bracketClose)
        let message = String(afterTimestamp[messageStart...])
            .trimmingCharacters(in: .whitespaces)

        return DebugLogEntry(
            id: index,
            timestamp: timestamp,
            level: level,
            message: message
        )
    }

    nonisolated(unsafe) private static let dateFormatter: ISO8601DateFormatter = {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        return fmt
    }()

    private static func parseTimestamp(_ string: String) -> Date? {
        dateFormatter.date(from: string)
    }

    private static let defaultPath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.claude/debug"
    }()
}
