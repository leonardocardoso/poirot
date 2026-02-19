import Foundation

/// Loads Claude Code session transcripts from ~/.claude/projects/
struct SessionLoader: SessionLoading {
    let claudeProjectsPath: String

    init(claudeProjectsPath: String? = nil) {
        self.claudeProjectsPath = claudeProjectsPath ?? Self.defaultPath
    }

    /// Discovers all projects with JSONL transcript files
    func discoverProjects() throws -> [Project] {
        let fm = FileManager.default
        let projectsURL = URL(fileURLWithPath: claudeProjectsPath)

        guard fm.fileExists(atPath: projectsURL.path) else {
            return []
        }

        let contents = try fm.contentsOfDirectory(
            at: projectsURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        return contents.compactMap { url -> Project? in
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue else {
                return nil
            }

            return buildProject(at: url)
        }
    }

    // MARK: - Private

    private static let defaultPath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.claude/projects"
    }()

    private static let uuidRegex = try? NSRegularExpression(
        pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
    )

    private static let dateFormatter: ISO8601DateFormatter = {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fmt
    }()

    private let parser = TranscriptParser()

    private static let maxSessionsPerProject = 20

    private func buildProject(at directoryURL: URL) -> Project? {
        let fm = FileManager.default
        let dirName = directoryURL.lastPathComponent
        let index = readSessionsIndex(at: directoryURL)

        let projectName: String
        if let originalPath = index?.originalPath {
            projectName = (originalPath as NSString).lastPathComponent
        } else {
            projectName = decodeProjectPath(dirName)
        }

        let projectPath = index?.originalPath ?? ("/" + dirName.replacingOccurrences(of: "-", with: "/"))

        // Index fast path: build sessions from metadata without parsing JSONL
        if let entries = index?.entries, !entries.isEmpty {
            var sessions: [Session] = []
            for entry in entries where !entry.isSidechain {
                let fileURL = directoryURL.appendingPathComponent("\(entry.sessionId).jsonl")
                guard fm.fileExists(atPath: fileURL.path) else { continue }
                let startedAt = Self.dateFormatter.date(from: entry.created) ?? Date.distantPast
                let session = Session(
                    id: entry.sessionId,
                    projectPath: projectPath,
                    messages: [],
                    startedAt: startedAt,
                    model: nil,
                    totalTokens: 0,
                    fileURL: fileURL,
                    cachedTitle: entry.firstPrompt,
                    cachedTurnCount: nil
                )
                sessions.append(session)
            }
            sessions.sort { $0.startedAt > $1.startedAt }
            if sessions.count > Self.maxSessionsPerProject {
                sessions = Array(sessions.prefix(Self.maxSessionsPerProject))
            }
            return Project(id: dirName, name: projectName, path: projectPath, sessions: sessions)
        }

        // Fallback path: no index — parseSummary the most recent JSONL files
        guard let items = try? fm.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return Project(id: dirName, name: projectName, path: projectPath, sessions: [])
        }

        let jsonlFiles = items
            .filter {
                $0.pathExtension == "jsonl"
                    && isUUIDFilename($0.deletingPathExtension().lastPathComponent)
            }
            .sorted { lhs, rhs in
                let keys: Set<URLResourceKey> = [.contentModificationDateKey]
                let lhsDate = (try? lhs.resourceValues(forKeys: keys))
                    .flatMap(\.contentModificationDate) ?? .distantPast
                let rhsDate = (try? rhs.resourceValues(forKeys: keys))
                    .flatMap(\.contentModificationDate) ?? .distantPast
                return lhsDate > rhsDate
            }
            .prefix(Self.maxSessionsPerProject)

        var sessions: [Session] = []
        for item in jsonlFiles {
            let stem = item.deletingPathExtension().lastPathComponent
            if let session = parser.parseSummary(
                fileURL: item,
                projectPath: projectPath,
                sessionId: stem,
                indexStartedAt: nil
            ) {
                sessions.append(session)
            }
        }

        sessions.sort { $0.startedAt > $1.startedAt }

        return Project(id: dirName, name: projectName, path: projectPath, sessions: sessions)
    }

    private func readSessionsIndex(at directoryURL: URL) -> SessionsIndex? {
        let indexURL = directoryURL.appendingPathComponent("sessions-index.json")
        guard let data = try? Data(contentsOf: indexURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }

        let entries: [SessionsIndex.Entry] = {
            guard let rawEntries = json["entries"] as? [[String: Any]] else { return [] }
            return rawEntries.compactMap { entry in
                guard let sessionId = entry["sessionId"] as? String,
                      let created = entry["created"] as? String
                else { return nil }
                let isSidechain = entry["isSidechain"] as? Bool ?? false
                let projectPath = entry["projectPath"] as? String
                let firstPrompt = entry["firstPrompt"] as? String
                return SessionsIndex.Entry(
                    sessionId: sessionId,
                    created: created,
                    isSidechain: isSidechain,
                    projectPath: projectPath,
                    firstPrompt: firstPrompt
                )
            }
        }()

        let originalPath = entries.first?.projectPath
            ?? json["projectPath"] as? String

        return SessionsIndex(originalPath: originalPath, entries: entries)
    }

    private func isUUIDFilename(_ name: String) -> Bool {
        let range = NSRange(name.startIndex..., in: name)
        return Self.uuidRegex?.firstMatch(in: name, range: range) != nil
    }

    private func decodeProjectPath(_ encoded: String) -> String {
        let decoded = "/" + encoded.replacingOccurrences(of: "-", with: "/")
        return (decoded as NSString).lastPathComponent
    }
}

private struct SessionsIndex {
    let originalPath: String?
    let entries: [Entry]

    struct Entry {
        let sessionId: String
        let created: String
        let isSidechain: Bool
        let projectPath: String?
        let firstPrompt: String?
    }
}
