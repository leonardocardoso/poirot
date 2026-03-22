import Foundation

/// Loads versioned file snapshots from Claude Code's file history.
///
/// Session JSONL files contain `file-history-snapshot` entries that map
/// file names to content hashes. The actual file content lives in
/// `~/.claude/file-history/<sessionId>/<hash@vN>`.
nonisolated struct FileHistoryLoader: FileHistoryLoading {
    let claudeProjectsPath: String
    let claudeFileHistoryPath: String

    init(claudeProjectsPath: String? = nil, claudeFileHistoryPath: String? = nil) {
        self.claudeProjectsPath = claudeProjectsPath ?? Self.defaultProjectsPath
        self.claudeFileHistoryPath = claudeFileHistoryPath ?? Self.defaultFileHistoryPath
    }

    func loadFileHistory(for sessionId: String, projectPath: String) -> [FileHistoryEntry] {
        let snapshots = parseSnapshots(sessionId: sessionId, projectPath: projectPath)
        guard !snapshots.isEmpty else { return [] }

        // Group by file name, collecting all versions
        var grouped: [String: [FileVersion]] = [:]
        for snapshot in snapshots {
            for (fileName, backup) in snapshot.trackedFileBackups {
                let version = FileVersion(
                    fileName: fileName,
                    sessionId: sessionId,
                    version: backup.version,
                    backupTime: backup.backupTime,
                    contentHash: backup.contentHash,
                    backupFileName: backup.backupFileName
                )
                grouped[fileName, default: []].append(version)
            }
        }

        // Deduplicate versions by backupFileName
        let entries = grouped.map { fileName, versions in
            var seen = Set<String>()
            let unique = versions
                .sorted { $0.version < $1.version }
                .filter { seen.insert($0.backupFileName).inserted }
            return FileHistoryEntry(fileName: fileName, versions: unique)
        }

        return entries.sorted { $0.fileName.localizedCaseInsensitiveCompare($1.fileName) == .orderedAscending }
    }

    func loadFileContent(for sessionId: String, backupFileName: String) -> String? {
        let filePath = (claudeFileHistoryPath as NSString)
            .appendingPathComponent(sessionId)
            .appending("/\(backupFileName)")
        return try? String(contentsOfFile: filePath, encoding: .utf8)
    }

    // MARK: - Private

    private static let defaultProjectsPath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.claude/projects"
    }()

    private static let defaultFileHistoryPath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.claude/file-history"
    }()

    nonisolated(unsafe) private static let dateFormatter: ISO8601DateFormatter = {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fmt
    }()

    private func parseSnapshots(sessionId: String, projectPath: String) -> [FileHistorySnapshot] {
        let fm = FileManager.default
        let projectsURL = URL(fileURLWithPath: claudeProjectsPath)

        // Find the project directory that contains this session's JSONL
        guard let projectDirs = try? fm.contentsOfDirectory(
            at: projectsURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        var jsonlURL: URL?
        for dir in projectDirs {
            let candidate = dir.appendingPathComponent("\(sessionId).jsonl")
            if fm.fileExists(atPath: candidate.path) {
                jsonlURL = candidate
                break
            }
        }

        guard let fileURL = jsonlURL,
              let data = try? Data(contentsOf: fileURL)
        else { return [] }

        let content = String(decoding: data, as: UTF8.self)
        var snapshots: [FileHistorySnapshot] = []

        for line in content.components(separatedBy: "\n") where !line.isEmpty {
            guard let lineData = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: lineData) as? [String: Any],
                  let type = json["type"] as? String,
                  type == "file-history-snapshot",
                  let snapshot = json["snapshot"] as? [String: Any],
                  let trackedFileBackups = snapshot["trackedFileBackups"] as? [String: [String: Any]]
            else { continue }

            var backups: [String: FileBackup] = [:]
            for (fileName, backupData) in trackedFileBackups {
                guard let backupFileName = backupData["backupFileName"] as? String,
                      let version = backupData["version"] as? Int,
                      let backupTimeStr = backupData["backupTime"] as? String,
                      let backupTime = Self.dateFormatter.date(from: backupTimeStr)
                else { continue }

                // Extract content hash from backupFileName (format: "hash@vN")
                let contentHash = backupFileName.components(separatedBy: "@").first ?? backupFileName

                backups[fileName] = FileBackup(
                    backupFileName: backupFileName,
                    version: version,
                    backupTime: backupTime,
                    contentHash: contentHash
                )
            }

            if !backups.isEmpty {
                snapshots.append(FileHistorySnapshot(trackedFileBackups: backups))
            }
        }

        return snapshots
    }
}

// MARK: - Internal Types

private struct FileHistorySnapshot {
    let trackedFileBackups: [String: FileBackup]
}

private struct FileBackup {
    let backupFileName: String
    let version: Int
    let backupTime: Date
    let contentHash: String
}
