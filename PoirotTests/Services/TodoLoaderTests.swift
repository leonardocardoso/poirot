@testable import Poirot
import Foundation
import Testing

@Suite("TodoLoader")
struct TodoLoaderTests {
    // MARK: - Helpers

    private func makeTempTodosDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("poirot-todo-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func writeTodoFile(
        in dir: URL,
        filename: String,
        content: String
    ) throws {
        let fileURL = dir.appendingPathComponent(filename)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    // MARK: - Tests

    @Test
    func loadTodos_nonExistentPath_returnsEmpty() {
        let loader = TodoLoader(claudeTodosPath: "/nonexistent/path/\(UUID().uuidString)")
        let todos = loader.loadTodos(for: "some-session-id")
        #expect(todos.isEmpty)
    }

    @Test
    func loadTodos_emptyDirectory_returnsEmpty() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let loader = TodoLoader(claudeTodosPath: dir.path)
        let todos = loader.loadTodos(for: "some-session-id")
        #expect(todos.isEmpty)
    }

    @Test
    func loadTodos_matchesAgentFile() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let sessionId = "abc-1234"
        let json = """
        [{"content": "Build feature", "status": "in_progress", "activeForm": "Building feature"}]
        """
        try writeTodoFile(in: dir, filename: "\(sessionId)-agent-def-5678.json", content: json)

        let loader = TodoLoader(claudeTodosPath: dir.path)
        let todos = loader.loadTodos(for: sessionId)
        #expect(todos.count == 1)
        #expect(todos[0].content == "Build feature")
        #expect(todos[0].status == .inProgress)
    }

    @Test
    func loadTodos_matchesExactSessionIdFile() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let sessionId = "abc-1234"
        let json = """
        [{"content": "Deploy", "status": "pending", "activeForm": "Deploying"}]
        """
        try writeTodoFile(in: dir, filename: "\(sessionId).json", content: json)

        let loader = TodoLoader(claudeTodosPath: dir.path)
        let todos = loader.loadTodos(for: sessionId)
        #expect(todos.count == 1)
        #expect(todos[0].content == "Deploy")
    }

    @Test
    func loadTodos_mergesMultipleAgentFiles() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let sessionId = "abc-1234"
        let json1 = """
        [{"content": "Task A", "status": "completed", "activeForm": "Completing A"}]
        """
        let json2 = """
        [{"content": "Task B", "status": "pending", "activeForm": "Starting B"}]
        """
        try writeTodoFile(in: dir, filename: "\(sessionId)-agent-agent1.json", content: json1)
        try writeTodoFile(in: dir, filename: "\(sessionId)-agent-agent2.json", content: json2)

        let loader = TodoLoader(claudeTodosPath: dir.path)
        let todos = loader.loadTodos(for: sessionId)
        #expect(todos.count == 2)
        let contents = Set(todos.map(\.content))
        #expect(contents.contains("Task A"))
        #expect(contents.contains("Task B"))
    }

    @Test
    func loadTodos_doesNotMatchUnrelatedFiles() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let json = """
        [{"content": "Unrelated", "status": "pending", "activeForm": "Starting"}]
        """
        try writeTodoFile(in: dir, filename: "other-session-agent-xyz.json", content: json)

        let loader = TodoLoader(claudeTodosPath: dir.path)
        let todos = loader.loadTodos(for: "abc-1234")
        #expect(todos.isEmpty)
    }

    @Test
    func loadTodos_handlesEmptyArrayFile() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        try writeTodoFile(in: dir, filename: "abc-1234-agent-def.json", content: "[]")

        let loader = TodoLoader(claudeTodosPath: dir.path)
        let todos = loader.loadTodos(for: "abc-1234")
        #expect(todos.isEmpty)
    }

    @Test
    func loadTodos_skipsInvalidJSON() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let sessionId = "abc-1234"
        // Invalid JSON file
        try writeTodoFile(in: dir, filename: "\(sessionId)-agent-bad.json", content: "not valid json")
        // Valid file
        let validJSON = """
        [{"content": "Valid", "status": "completed", "activeForm": "Done"}]
        """
        try writeTodoFile(in: dir, filename: "\(sessionId)-agent-good.json", content: validJSON)

        let loader = TodoLoader(claudeTodosPath: dir.path)
        let todos = loader.loadTodos(for: sessionId)
        #expect(todos.count == 1)
        #expect(todos[0].content == "Valid")
    }

    @Test
    func loadTodos_uuidSessionId_matchesAgentFile() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let sessionId = "00163b58-3b30-49fa-af28-052f06724f50"
        let agentId = "f57e3842-efed-43d9-a4c9-1e644a82141e"
        let json = """
        [
            {"content": "Create diagnostic script", "status": "in_progress", "activeForm": "Creating script"},
            {"content": "Check collection count", "status": "pending", "activeForm": "Checking count"}
        ]
        """
        try writeTodoFile(in: dir, filename: "\(sessionId)-agent-\(agentId).json", content: json)

        let loader = TodoLoader(claudeTodosPath: dir.path)
        let todos = loader.loadTodos(for: sessionId)
        #expect(todos.count == 2)
        #expect(todos[0].content == "Create diagnostic script")
        #expect(todos[1].status == .pending)
    }

    // MARK: - loadAllTodos

    @Test
    func loadAllTodos_nonExistentPath_returnsEmpty() {
        let loader = TodoLoader(claudeTodosPath: "/nonexistent/path/\(UUID().uuidString)")
        let result = loader.loadAllTodos()
        #expect(result.isEmpty)
    }

    @Test
    func loadAllTodos_groupsBySessionId() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let json1 = """
        [{"content": "Task A", "status": "completed", "activeForm": "Done A"}]
        """
        let json2 = """
        [{"content": "Task B", "status": "pending", "activeForm": "Starting B"}]
        """
        try writeTodoFile(in: dir, filename: "session-1.json", content: json1)
        try writeTodoFile(in: dir, filename: "session-2.json", content: json2)

        let loader = TodoLoader(claudeTodosPath: dir.path)
        let result = loader.loadAllTodos()
        #expect(result.count == 2)
        #expect(result["session-1"]?.count == 1)
        #expect(result["session-2"]?.count == 1)
    }

    @Test
    func loadAllTodos_mergesAgentFilesUnderSameSession() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let json1 = """
        [{"content": "Task A", "status": "completed", "activeForm": "Done A"}]
        """
        let json2 = """
        [{"content": "Task B", "status": "pending", "activeForm": "Starting B"}]
        """
        try writeTodoFile(in: dir, filename: "session-1-agent-a1.json", content: json1)
        try writeTodoFile(in: dir, filename: "session-1-agent-a2.json", content: json2)

        let loader = TodoLoader(claudeTodosPath: dir.path)
        let result = loader.loadAllTodos()
        #expect(result.count == 1)
        #expect(result["session-1"]?.count == 2)
    }

    @Test
    func loadAllTodos_skipsEmptyArrayFiles() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        try writeTodoFile(in: dir, filename: "session-empty.json", content: "[]")
        let json = """
        [{"content": "Real task", "status": "pending", "activeForm": "Starting"}]
        """
        try writeTodoFile(in: dir, filename: "session-real.json", content: json)

        let loader = TodoLoader(claudeTodosPath: dir.path)
        let result = loader.loadAllTodos()
        #expect(result.count == 1)
        #expect(result["session-empty"] == nil)
        #expect(result["session-real"]?.count == 1)
    }

    // MARK: - deleteTodos

    @Test
    func deleteTodos_removesMatchingFiles() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let sessionId = "abc-1234"
        let json = """
        [{"content": "Task", "status": "pending", "activeForm": "Starting"}]
        """
        try writeTodoFile(in: dir, filename: "\(sessionId).json", content: json)
        try writeTodoFile(in: dir, filename: "\(sessionId)-agent-xyz.json", content: json)

        let loader = TodoLoader(claudeTodosPath: dir.path)
        loader.deleteTodos(for: sessionId)

        let remaining = try FileManager.default.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: nil
        )
        #expect(remaining.isEmpty)
    }

    @Test
    func deleteTodos_leavesUnrelatedFiles() throws {
        let dir = try makeTempTodosDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let json = """
        [{"content": "Task", "status": "pending", "activeForm": "Starting"}]
        """
        try writeTodoFile(in: dir, filename: "abc-1234.json", content: json)
        try writeTodoFile(in: dir, filename: "other-session.json", content: json)

        let loader = TodoLoader(claudeTodosPath: dir.path)
        loader.deleteTodos(for: "abc-1234")

        let remaining = try FileManager.default.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: nil
        )
        #expect(remaining.count == 1)
        #expect(remaining[0].lastPathComponent == "other-session.json")
    }

    @Test
    func deleteTodos_nonExistentPath_doesNotCrash() {
        let loader = TodoLoader(claudeTodosPath: "/nonexistent/path/\(UUID().uuidString)")
        loader.deleteTodos(for: "some-session")
    }
}
