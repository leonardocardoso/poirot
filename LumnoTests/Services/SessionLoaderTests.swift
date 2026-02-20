@testable import Lumno
import Foundation
import Testing

@Suite("SessionLoader")
struct SessionLoaderTests {
    // MARK: - Helpers

    private func makeTempProjectDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("lumno-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func makeProjectWithJSONL(
        in baseDir: URL,
        projectDirName: String,
        sessionId: String,
        jsonlContent: String,
        indexJSON: String? = nil
    ) throws {
        let projectDir = baseDir.appendingPathComponent(projectDirName)
        try FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)

        let jsonlFile = projectDir.appendingPathComponent("\(sessionId).jsonl")
        try jsonlContent.write(to: jsonlFile, atomically: true, encoding: .utf8)

        if let indexJSON {
            let indexFile = projectDir.appendingPathComponent("sessions-index.json")
            try indexJSON.write(to: indexFile, atomically: true, encoding: .utf8)
        }
    }

    private func userRecord(
        content: String,
        timestamp: String = "2026-01-28T10:00:00.000Z"
    ) -> String {
        let record: [String: Any] = [
            "type": "user",
            "uuid": UUID().uuidString,
            "timestamp": timestamp,
            "isSidechain": false,
            "message": ["role": "user", "content": content],
        ]
        let data = try! JSONSerialization.data(withJSONObject: record) // swiftlint:disable:this force_try
        return String(data: data, encoding: .utf8)!
    }

    private func assistantRecord(
        text: String,
        msgId: String = "msg_test",
        model: String = "claude-opus-4-6",
        timestamp: String = "2026-01-28T10:01:00.000Z",
        inputTokens: Int = 100,
        outputTokens: Int = 50
    ) -> String {
        let record: [String: Any] = [
            "type": "assistant",
            "uuid": UUID().uuidString,
            "timestamp": timestamp,
            "isSidechain": false,
            "message": [
                "id": msgId,
                "role": "assistant",
                "model": model,
                "content": [["type": "text", "text": text]],
                "usage": ["input_tokens": inputTokens, "output_tokens": outputTokens],
            ] as [String: Any],
        ]
        let data = try! JSONSerialization.data(withJSONObject: record) // swiftlint:disable:this force_try
        return String(data: data, encoding: .utf8)!
    }

    private func simpleJSONL(
        userText: String = "Hello",
        assistantText: String = "Hi there",
        userTimestamp: String = "2026-01-28T10:00:00.000Z",
        assistantTimestamp: String = "2026-01-28T10:01:00.000Z"
    ) -> String {
        [
            userRecord(content: userText, timestamp: userTimestamp),
            assistantRecord(text: assistantText, timestamp: assistantTimestamp),
        ].joined(separator: "\n")
    }

    // MARK: - Original Tests

    @Test
    func discoverProjects_nonExistentPath_returnsEmpty() throws {
        let loader = SessionLoader(claudeProjectsPath: "/nonexistent/path/\(UUID().uuidString)")
        let projects = try loader.discoverProjects()
        #expect(projects.isEmpty)
    }

    @Test
    func discoverProjects_emptyDirectory_returnsEmpty() throws {
        let tmpDir = try makeTempProjectDir()
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects.isEmpty)
    }

    @Test
    func discoverProjects_withSubdirectories_returnsProjects() throws {
        let tmpDir = try makeTempProjectDir()
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        try FileManager.default.createDirectory(
            at: tmpDir.appendingPathComponent("project-alpha"),
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: tmpDir.appendingPathComponent("project-beta"),
            withIntermediateDirectories: true
        )

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects.count == 2)

        let names = Set(projects.map(\.name))
        #expect(names.contains("alpha"))
        #expect(names.contains("beta"))
    }

    @Test
    func discoverProjects_skipsFiles_onlyIncludesDirectories() throws {
        let tmpDir = try makeTempProjectDir()
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        try FileManager.default.createDirectory(
            at: tmpDir.appendingPathComponent("real-project"),
            withIntermediateDirectories: true
        )
        FileManager.default.createFile(
            atPath: tmpDir.appendingPathComponent("not-a-project.txt").path,
            contents: Data("hello".utf8)
        )

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects.count == 1)
        #expect(projects[0].name == "project")
    }

    // MARK: - JSONL Parsing Integration

    @Test
    func discoverProjects_withJSONLFiles_parsesSessions() throws {
        let tmpDir = try makeTempProjectDir()
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let sessionId = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        try makeProjectWithJSONL(
            in: tmpDir,
            projectDirName: "test-project",
            sessionId: sessionId,
            jsonlContent: simpleJSONL()
        )

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects.count == 1)
        #expect(projects[0].sessions.count == 1)

        let session = projects[0].sessions[0]
        #expect(session.id == sessionId)
        // Lazy loading: messages are empty, title comes from cachedTitle
        #expect(session.messages.isEmpty)
        #expect(session.title == "Hello")
        #expect(session.fileURL != nil)
    }

    @Test
    func discoverProjects_skipsAgentFiles() throws {
        let tmpDir = try makeTempProjectDir()
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let projectDir = tmpDir.appendingPathComponent("test-project")
        try FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)

        let validId = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        let validFile = projectDir.appendingPathComponent("\(validId).jsonl")
        try simpleJSONL().write(to: validFile, atomically: true, encoding: .utf8)

        let agentFile = projectDir.appendingPathComponent("agent-a1b2c3d4-e5f6-7890-abcd-ef1234567890.jsonl")
        try simpleJSONL().write(to: agentFile, atomically: true, encoding: .utf8)

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects[0].sessions.count == 1)
        #expect(projects[0].sessions[0].id == validId)
    }

    @Test
    func discoverProjects_sessionsSortedDescending() throws {
        let tmpDir = try makeTempProjectDir()
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let projectDir = tmpDir.appendingPathComponent("test-project")
        try FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)

        let oldId = "00000000-0000-0000-0000-000000000001"
        let oldFile = projectDir.appendingPathComponent("\(oldId).jsonl")
        try simpleJSONL(userTimestamp: "2026-01-01T10:00:00.000Z", assistantTimestamp: "2026-01-01T10:01:00.000Z")
            .write(to: oldFile, atomically: true, encoding: .utf8)

        let newId = "00000000-0000-0000-0000-000000000002"
        let newFile = projectDir.appendingPathComponent("\(newId).jsonl")
        try simpleJSONL(userTimestamp: "2026-02-01T10:00:00.000Z", assistantTimestamp: "2026-02-01T10:01:00.000Z")
            .write(to: newFile, atomically: true, encoding: .utf8)

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        let sessions = projects[0].sessions
        #expect(sessions.count == 2)
        #expect(sessions[0].id == newId)
        #expect(sessions[1].id == oldId)
    }

    @Test
    func discoverProjects_usesOriginalPathFromIndex() throws {
        let tmpDir = try makeTempProjectDir()
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let sessionId = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        let indexJSON = """
        {
            "version": 1,
            "entries": [
                {
                    "sessionId": "\(sessionId)",
                    "created": "2026-01-28T10:00:00.000Z",
                    "isSidechain": false,
                    "projectPath": "/Users/dev/projects/my-cool-app",
                    "firstPrompt": "Hello from index"
                }
            ]
        }
        """

        try makeProjectWithJSONL(
            in: tmpDir,
            projectDirName: "-Users-dev-projects-my-cool-app",
            sessionId: sessionId,
            jsonlContent: simpleJSONL(),
            indexJSON: indexJSON
        )

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects[0].name == "my-cool-app")
        #expect(projects[0].path == "/Users/dev/projects/my-cool-app")

        // Index fast path: session has cached title from firstPrompt, no messages parsed
        let session = projects[0].sessions[0]
        #expect(session.messages.isEmpty)
        #expect(session.title == "Hello from index")
        #expect(session.fileURL != nil)
    }

    @Test
    func discoverProjects_withMissingIndex_usesFallback() throws {
        let tmpDir = try makeTempProjectDir()
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let sessionId = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        try makeProjectWithJSONL(
            in: tmpDir,
            projectDirName: "-Users-dev-projects-my-app",
            sessionId: sessionId,
            jsonlContent: simpleJSONL()
        )

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects[0].name == "app")
    }

    @Test
    func discoverProjects_emptyJSONLFile_producesNoSession() throws {
        let tmpDir = try makeTempProjectDir()
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let projectDir = tmpDir.appendingPathComponent("test-project")
        try FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)

        let sessionId = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        let emptyFile = projectDir.appendingPathComponent("\(sessionId).jsonl")
        try "".write(to: emptyFile, atomically: true, encoding: .utf8)

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects[0].sessions.isEmpty)
    }

    // MARK: - Index Fast Path

    @Test
    func discoverProjects_indexPath_skipsSidechainEntries() throws {
        let tmpDir = try makeTempProjectDir()
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let mainId = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        let sidechainId = "b2c3d4e5-f6a7-8901-bcde-f12345678901"
        let indexJSON = """
        {
            "version": 1,
            "entries": [
                {
                    "sessionId": "\(mainId)",
                    "created": "2026-01-28T10:00:00.000Z",
                    "isSidechain": false,
                    "projectPath": "/test/project",
                    "firstPrompt": "Main session"
                },
                {
                    "sessionId": "\(sidechainId)",
                    "created": "2026-01-28T11:00:00.000Z",
                    "isSidechain": true,
                    "projectPath": "/test/project"
                }
            ]
        }
        """

        let projectDir = tmpDir.appendingPathComponent("test-project")
        try FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)

        // Create both JSONL files
        try simpleJSONL().write(
            to: projectDir.appendingPathComponent("\(mainId).jsonl"),
            atomically: true, encoding: .utf8
        )
        try simpleJSONL().write(
            to: projectDir.appendingPathComponent("\(sidechainId).jsonl"),
            atomically: true, encoding: .utf8
        )

        let indexFile = projectDir.appendingPathComponent("sessions-index.json")
        try indexJSON.write(to: indexFile, atomically: true, encoding: .utf8)

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects[0].sessions.count == 1)
        #expect(projects[0].sessions[0].id == mainId)
    }

    @Test
    func discoverProjects_indexPath_limitsTo20Sessions() throws {
        let tmpDir = try makeTempProjectDir()
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let projectDir = tmpDir.appendingPathComponent("test-project")
        try FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)

        // Create 25 sessions via index
        var entries: [[String: Any]] = []
        for i in 0 ..< 25 {
            let sessionId = String(format: "00000000-0000-0000-0000-%012d", i)
            let created = String(format: "2026-01-%02dT10:00:00.000Z", i + 1)
            entries.append([
                "sessionId": sessionId,
                "created": created,
                "isSidechain": false,
                "projectPath": "/test/project",
            ])
            let jsonlFile = projectDir.appendingPathComponent("\(sessionId).jsonl")
            try simpleJSONL(userTimestamp: created).write(to: jsonlFile, atomically: true, encoding: .utf8)
        }

        let index: [String: Any] = ["version": 1, "entries": entries]
        let indexData = try JSONSerialization.data(withJSONObject: index)
        try indexData.write(to: projectDir.appendingPathComponent("sessions-index.json"))

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects[0].sessions.count == 20)
    }

    @Test
    func discoverProjects_fallbackPath_usesHeaderParse() throws {
        let tmpDir = try makeTempProjectDir()
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let sessionId = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        // No index — forces fallback path (header-only parse)
        try makeProjectWithJSONL(
            in: tmpDir,
            projectDirName: "test-project",
            sessionId: sessionId,
            jsonlContent: simpleJSONL(userText: "Fallback title")
        )

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        let session = projects[0].sessions[0]
        #expect(session.messages.isEmpty)
        #expect(session.title == "Fallback title")
        #expect(session.fileURL != nil)
    }
}
