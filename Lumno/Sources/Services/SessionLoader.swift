import Foundation

/// Loads Claude Code session transcripts from ~/.claude/projects/
struct SessionLoader {
    static let claudeProjectsPath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.claude/projects"
    }()

    /// Discovers all projects with JSONL transcript files
    static func discoverProjects() throws -> [Project] {
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

            let name = url.lastPathComponent
            // TODO: Parse JSONL files within each project directory
            return Project(
                id: name,
                name: name,
                path: url.path,
                sessions: []
            )
        }
    }
}
