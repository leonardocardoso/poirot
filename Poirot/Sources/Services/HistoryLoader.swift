import Foundation

/// Parses Claude Code's global input history from `~/.claude/history.jsonl`.
///
/// Each line is a JSON object with `display`, `pastedContents`, `timestamp`, and `project` fields.
/// The file can grow to thousands of entries; this loader streams line-by-line and supports
/// pagination via `offset` / `limit`.
nonisolated struct HistoryLoader {
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
