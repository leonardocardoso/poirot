import Foundation

/// Loads Claude Code per-session todo lists from `~/.claude/todos/`.
///
/// Files follow the naming convention `<sessionId>-agent-<agentId>.json`
/// and may also use `<sessionId>.json`. A single session can have multiple
/// agent files; this loader merges all todos found for the given session ID.
nonisolated struct TodoLoader: TodoLoading {
    let claudeTodosPath: String

    init(claudeTodosPath: String? = nil) {
        self.claudeTodosPath = claudeTodosPath ?? Self.defaultPath
    }

    /// Returns all todos associated with the given session ID, merging
    /// across any agent-specific files.
    func loadTodos(for sessionId: String) -> [SessionTodo] {
        let fm = FileManager.default
        let todosURL = URL(fileURLWithPath: claudeTodosPath)

        guard fm.fileExists(atPath: todosURL.path) else { return [] }

        guard let contents = try? fm.contentsOfDirectory(
            at: todosURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return [] }

        // Match files whose name starts with "<sessionId>" and ends with ".json"
        // e.g. "abc-123.json" or "abc-123-agent-def-456.json"
        let prefix = sessionId
        let matchingFiles = contents.filter { url in
            let name = url.deletingPathExtension().lastPathComponent
            return url.pathExtension == "json"
                && (name == prefix || name.hasPrefix("\(prefix)-agent-"))
        }

        var allTodos: [SessionTodo] = []
        for fileURL in matchingFiles {
            guard let data = try? Data(contentsOf: fileURL),
                  let todos = try? JSONDecoder().decode([SessionTodo].self, from: data)
            else { continue }
            allTodos.append(contentsOf: todos)
        }

        return allTodos
    }

    // MARK: - Private

    private static let defaultPath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.claude/todos"
    }()
}
