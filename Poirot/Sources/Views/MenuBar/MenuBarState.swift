import Foundation
import Observation

enum ClaudeCodeStatus: Equatable {
    case running
    case idle
    case notInstalled
}

@Observable
final class MenuBarState {
    var recentSessions: [(project: Project, session: Session)] = []
    var searchQuery: String = ""
    var claudeCodeStatus: ClaudeCodeStatus = .idle

    var filteredSessions: [(project: Project, session: Session)] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return recentSessions }
        return recentSessions.filter { pair in
            HighlightedText.fuzzyMatch(pair.session.title, query: trimmed) != nil
                || HighlightedText.fuzzyMatch(pair.project.name, query: trimmed) != nil
        }
    }

    private static let maxRecentSessions = 10

    func loadRecentSessions(from projects: [Project]) {
        recentSessions = Array(
            projects
                .flatMap { project in project.sessions.map { (project: project, session: $0) } }
                .sorted { $0.session.startedAt > $1.session.startedAt }
                .prefix(Self.maxRecentSessions)
        )
    }

    nonisolated func detectClaudeCodeStatus(cliPath: String) -> ClaudeCodeStatus {
        let fm = FileManager.default

        guard fm.fileExists(atPath: cliPath) else {
            return .notInstalled
        }

        let pipe = Pipe()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
        process.arguments = ["-f", "claude"]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return .idle
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return output.isEmpty ? .idle : .running
    }

    func refreshStatus(cliPath: String) async {
        let status = await Task.detached { [self] in
            detectClaudeCodeStatus(cliPath: cliPath)
        }.value
        claudeCodeStatus = status
    }
}
