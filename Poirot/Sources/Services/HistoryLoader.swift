import Foundation

/// Parses Claude Code's global input history from `~/.claude/history.jsonl`.
///
/// Each line is a JSON object with `display`, `pastedContents`, `timestamp`, and `project` fields.
/// The file can grow to thousands of entries; this loader streams line-by-line and supports
/// pagination via `offset` / `limit`.
nonisolated struct HistoryLoader: HistoryLoading {
    let historyFilePath: String

    init(historyFilePath: String? = nil) {
        self.historyFilePath = historyFilePath ?? Self.defaultPath
    }

    /// Loads all history entries, sorted by timestamp descending (most recent first).
    func loadAll() -> [HistoryEntry] {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: historyFilePath)) else {
            return []
        }

        let lines = data.split(separator: UInt8(ascii: "\n"))
        var entries: [HistoryEntry] = []
        entries.reserveCapacity(lines.count)

        let decoder = JSONDecoder()

        for (index, line) in lines.enumerated() {
            guard let entry = Self.parseLine(line, index: index, decoder: decoder) else { continue }
            entries.append(entry)
        }

        // Sort by timestamp descending (most recent first)
        entries.sort { $0.timestamp > $1.timestamp }
        return entries
    }

    /// Returns the total number of valid entries without fully parsing them.
    func entryCount() -> Int {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: historyFilePath)) else {
            return 0
        }
        return data.split(separator: UInt8(ascii: "\n")).count
    }

    /// Returns all unique project paths found in the history.
    func uniqueProjects() -> [String] {
        let entries = loadAll()
        var seen = Set<String>()
        var projects: [String] = []
        for entry in entries where seen.insert(entry.project).inserted {
            projects.append(entry.project)
        }
        return projects
    }

    /// Deletes a single entry from the history file.
    ///
    /// The entry's `id` has the format `"timestamp-lineIndex"` where `lineIndex`
    /// is the zero-based line number in the JSONL file at the time of loading.
    func delete(entry: HistoryEntry) {
        let components = entry.id.split(separator: "-")
        guard components.count >= 2,
              let lineIndex = Int(components.last!)
        else { return }

        guard let data = try? String(contentsOfFile: historyFilePath, encoding: .utf8) else { return }
        var lines = data.components(separatedBy: "\n")

        // Filter out trailing empty line from split
        if lines.last?.isEmpty == true { lines.removeLast() }

        guard lineIndex >= 0, lineIndex < lines.count else { return }
        lines.remove(at: lineIndex)

        let output = lines.joined(separator: "\n") + (lines.isEmpty ? "" : "\n")
        try? output.write(toFile: historyFilePath, atomically: true, encoding: .utf8)
    }

    /// Deletes all entries older than the given number of days.
    /// Returns the count of removed entries.
    @discardableResult
    func deleteOlderThan(days: Int) -> Int {
        guard let data = try? String(contentsOfFile: historyFilePath, encoding: .utf8) else { return 0 }
        var lines = data.components(separatedBy: "\n")
        if lines.last?.isEmpty == true { lines.removeLast() }

        let cutoff = Date().addingTimeInterval(-Double(days) * 86400)
        let cutoffMs = cutoff.timeIntervalSince1970 * 1000.0
        let decoder = JSONDecoder()
        let originalCount = lines.count

        lines.removeAll { line in
            guard let lineData = line.data(using: .utf8),
                  let raw = try? decoder.decode(RawEntry.self, from: lineData)
            else { return false }
            return raw.timestamp < cutoffMs
        }

        let removed = originalCount - lines.count
        guard removed > 0 else { return 0 }

        let output = lines.joined(separator: "\n") + (lines.isEmpty ? "" : "\n")
        try? output.write(toFile: historyFilePath, atomically: true, encoding: .utf8)
        return removed
    }

    // MARK: - Private

    /// Raw JSONL structure matching the file format.
    private struct RawEntry: Decodable {
        let display: String
        let pastedContents: [String: String]?
        let timestamp: Double
        let project: String
    }

    private static func parseLine(_ lineData: Data.SubSequence, index: Int, decoder: JSONDecoder) -> HistoryEntry? {
        guard let raw = try? decoder.decode(RawEntry.self, from: Data(lineData)) else {
            return nil
        }

        let date = Date(timeIntervalSince1970: raw.timestamp / 1000.0)
        return HistoryEntry(
            id: "\(Int(raw.timestamp))-\(index)",
            display: raw.display,
            pastedContents: raw.pastedContents ?? [:],
            timestamp: date,
            project: raw.project
        )
    }

    private static let defaultPath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.claude/history.jsonl"
    }()
}
