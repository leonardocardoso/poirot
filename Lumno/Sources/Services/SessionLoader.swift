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

        guard let items = try? fm.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return Project(id: dirName, name: projectName, path: projectPath, sessions: [])
        }

        let createdDates: [String: Date] = {
            guard let entries = index?.entries else { return [:] }
            var map: [String: Date] = [:]
            for entry in entries {
                if let date = Self.dateFormatter.date(from: entry.created) {
                    map[entry.sessionId] = date
                }
            }
            return map
        }()

        var sessions: [Session] = []
        for item in items {
            guard item.pathExtension == "jsonl" else { continue }
            let stem = item.deletingPathExtension().lastPathComponent
            guard isUUIDFilename(stem) else { continue }

            if let session = parser.parse(
                fileURL: item,
                projectPath: projectPath,
                sessionId: stem,
                indexStartedAt: createdDates[stem]
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
                return SessionsIndex.Entry(
                    sessionId: sessionId,
                    created: created,
                    isSidechain: isSidechain,
                    projectPath: projectPath
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
    }
}
