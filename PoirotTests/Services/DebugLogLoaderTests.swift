@testable import Poirot
import Foundation
import Testing

@Suite("DebugLogLoader")
struct DebugLogLoaderTests {
    // MARK: - Helpers

    private func makeTempDebugDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("poirot-debug-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(
            at: dir,
            withIntermediateDirectories: true
        )
        return dir
    }

    private func writeLogFile(
        in dir: URL,
        filename: String,
        content: String
    ) throws {
        let fileURL = dir.appendingPathComponent(filename)
        try content.write(
            to: fileURL,
            atomically: true,
            encoding: .utf8
        )
    }

    // MARK: - parse Tests

    @Test
    func parse_emptyString_returnsEmpty() {
        let loader = DebugLogLoader()
        let entries = loader.parse("")
        #expect(entries.isEmpty)
    }

    @Test
    func parse_singleDebugLine() {
        let loader = DebugLogLoader()
        let text = "2026-02-06T16:01:34.872Z [DEBUG] Loading MCP servers"
        let entries = loader.parse(text)
        #expect(entries.count == 1)
        #expect(entries[0].level == .debug)
        #expect(entries[0].message == "Loading MCP servers")
        #expect(entries[0].id == 0)
    }

    @Test
    func parse_errorLevel() {
        let loader = DebugLogLoader()
        let text = "2026-02-06T16:01:35.000Z [ERROR] MCP server failed"
        let entries = loader.parse(text)
        #expect(entries.count == 1)
        #expect(entries[0].level == .error)
        #expect(entries[0].message == "MCP server failed")
    }

    @Test
    func parse_warnLevel() {
        let loader = DebugLogLoader()
        let text = "2026-02-06T16:01:35.000Z [WARN] Deprecated config"
        let entries = loader.parse(text)
        #expect(entries.count == 1)
        #expect(entries[0].level == .warn)
        #expect(entries[0].message == "Deprecated config")
    }

    @Test
    func parse_multipleLines() {
        let loader = DebugLogLoader()
        let text = """
        2026-02-06T16:01:34.872Z [DEBUG] First message
        2026-02-06T16:01:35.000Z [ERROR] Error message
        2026-02-06T16:01:36.123Z [WARN] Warning message
        """
        let entries = loader.parse(text)
        #expect(entries.count == 3)
        #expect(entries[0].level == .debug)
        #expect(entries[1].level == .error)
        #expect(entries[2].level == .warn)
        #expect(entries[0].id == 0)
        #expect(entries[1].id == 1)
        #expect(entries[2].id == 2)
    }

    @Test
    func parse_skipsEmptyLines() {
        let loader = DebugLogLoader()
        let text = """
        2026-02-06T16:01:34.872Z [DEBUG] First

        2026-02-06T16:01:35.000Z [DEBUG] Second
        """
        let entries = loader.parse(text)
        #expect(entries.count == 2)
    }

    @Test
    func parse_skipsInvalidLines() {
        let loader = DebugLogLoader()
        let text = """
        2026-02-06T16:01:34.872Z [DEBUG] Valid line
        This line has no timestamp or brackets
        2026-02-06T16:01:35.000Z [ERROR] Another valid line
        """
        let entries = loader.parse(text)
        #expect(entries.count == 2)
    }

    @Test
    func parse_messageWithBrackets() {
        let loader = DebugLogLoader()
        let text = "2026-02-06T16:01:34.872Z [DEBUG] [init] configureGlobalMTLS starting"
        let entries = loader.parse(text)
        #expect(entries.count == 1)
        #expect(entries[0].message == "[init] configureGlobalMTLS starting")
    }

    @Test
    func parse_timestamp_isParsedCorrectly() {
        let loader = DebugLogLoader()
        let text = "2026-02-06T16:01:34.872Z [DEBUG] Test"
        let entries = loader.parse(text)
        #expect(entries.count == 1)

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(
            in: TimeZone(identifier: "UTC")!,
            from: entries[0].timestamp
        )
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 6)
        #expect(components.hour == 16)
        #expect(components.minute == 1)
        #expect(components.second == 34)
    }

    @Test
    func parse_unknownLevel_defaultsToDebug() {
        let loader = DebugLogLoader()
        let text = "2026-02-06T16:01:34.872Z [INFO] Some info"
        let entries = loader.parse(text)
        #expect(entries.count == 1)
        #expect(entries[0].level == .debug)
        #expect(entries[0].message == "Some info")
    }

    // MARK: - loadEntries Tests

    @Test
    func loadEntries_nonExistentSession_returnsEmpty() {
        let loader = DebugLogLoader(
            claudeDebugPath: "/nonexistent/\(UUID().uuidString)"
        )
        let entries = loader.loadEntries(for: "nonexistent-session")
        #expect(entries.isEmpty)
    }

    @Test
    func loadEntries_validFile_returnsEntries() throws {
        let dir = try makeTempDebugDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let sessionId = "test-session-123"
        let content = """
        2026-02-06T16:01:34.872Z [DEBUG] Loading MCP servers
        2026-02-06T16:01:35.000Z [ERROR] Server failed to start
        """
        try writeLogFile(
            in: dir,
            filename: "\(sessionId).txt",
            content: content
        )

        let loader = DebugLogLoader(claudeDebugPath: dir.path)
        let entries = loader.loadEntries(for: sessionId)
        #expect(entries.count == 2)
        #expect(entries[0].level == .debug)
        #expect(entries[1].level == .error)
    }

    // MARK: - hasLog Tests

    @Test
    func hasLog_noFile_returnsFalse() {
        let loader = DebugLogLoader(
            claudeDebugPath: "/nonexistent/\(UUID().uuidString)"
        )
        #expect(!loader.hasLog(for: "no-session"))
    }

    @Test
    func hasLog_fileExists_returnsTrue() throws {
        let dir = try makeTempDebugDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        try writeLogFile(
            in: dir,
            filename: "my-session.txt",
            content: "log content"
        )

        let loader = DebugLogLoader(claudeDebugPath: dir.path)
        #expect(loader.hasLog(for: "my-session"))
    }

    // MARK: - allSessionIds Tests

    @Test
    func allSessionIds_nonExistentPath_returnsEmpty() {
        let loader = DebugLogLoader(
            claudeDebugPath: "/nonexistent/\(UUID().uuidString)"
        )
        #expect(loader.allSessionIds().isEmpty)
    }

    @Test
    func allSessionIds_returnsFilenames() throws {
        let dir = try makeTempDebugDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        try writeLogFile(in: dir, filename: "sess-1.txt", content: "log")
        try writeLogFile(in: dir, filename: "sess-2.txt", content: "log")
        try writeLogFile(in: dir, filename: "not-a-log.json", content: "{}")

        let loader = DebugLogLoader(claudeDebugPath: dir.path)
        let ids = Set(loader.allSessionIds())
        #expect(ids.count == 2)
        #expect(ids.contains("sess-1"))
        #expect(ids.contains("sess-2"))
    }

    // MARK: - Paginated loadEntries Tests

    @Test
    func loadEntries_paginated_firstPage() throws {
        let dir = try makeTempDebugDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let content = (0 ..< 10).map {
            "2026-02-06T16:01:\(String(format: "%02d", $0)).000Z [DEBUG] Message \($0)"
        }.joined(separator: "\n")
        try writeLogFile(in: dir, filename: "paged-session.txt", content: content)

        let loader = DebugLogLoader(claudeDebugPath: dir.path)
        let page = loader.loadEntries(for: "paged-session", offset: 0, limit: 3)
        #expect(page.totalCount == 10)
        #expect(page.entries.count == 3)
        #expect(page.entries[0].id == 0)
        #expect(page.entries[2].id == 2)
    }

    @Test
    func loadEntries_paginated_secondPage() throws {
        let dir = try makeTempDebugDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let content = (0 ..< 10).map {
            "2026-02-06T16:01:\(String(format: "%02d", $0)).000Z [DEBUG] Message \($0)"
        }.joined(separator: "\n")
        try writeLogFile(in: dir, filename: "paged-session.txt", content: content)

        let loader = DebugLogLoader(claudeDebugPath: dir.path)
        let page = loader.loadEntries(for: "paged-session", offset: 3, limit: 3)
        #expect(page.totalCount == 10)
        #expect(page.entries.count == 3)
        #expect(page.entries[0].id == 3)
        #expect(page.entries[2].id == 5)
    }

    @Test
    func loadEntries_paginated_lastPage_partialResults() throws {
        let dir = try makeTempDebugDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let content = (0 ..< 5).map {
            "2026-02-06T16:01:\(String(format: "%02d", $0)).000Z [DEBUG] Message \($0)"
        }.joined(separator: "\n")
        try writeLogFile(in: dir, filename: "paged-session.txt", content: content)

        let loader = DebugLogLoader(claudeDebugPath: dir.path)
        let page = loader.loadEntries(for: "paged-session", offset: 3, limit: 10)
        #expect(page.totalCount == 5)
        #expect(page.entries.count == 2)
        #expect(page.entries[0].id == 3)
        #expect(page.entries[1].id == 4)
    }

    @Test
    func loadEntries_paginated_offsetBeyondEnd_returnsEmpty() throws {
        let dir = try makeTempDebugDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let content = "2026-02-06T16:01:00.000Z [DEBUG] Only one"
        try writeLogFile(in: dir, filename: "paged-session.txt", content: content)

        let loader = DebugLogLoader(claudeDebugPath: dir.path)
        let page = loader.loadEntries(for: "paged-session", offset: 10, limit: 5)
        #expect(page.totalCount == 1)
        #expect(page.entries.isEmpty)
    }

    @Test
    func loadEntries_paginated_nonExistentSession() {
        let loader = DebugLogLoader(
            claudeDebugPath: "/nonexistent/\(UUID().uuidString)"
        )
        let page = loader.loadEntries(for: "no-session", offset: 0, limit: 10)
        #expect(page.totalCount == 0)
        #expect(page.entries.isEmpty)
    }

    // MARK: - parsePaged Tests

    @Test
    func parsePaged_returnsCorrectTotalCount() {
        let loader = DebugLogLoader()
        let text = """
        2026-02-06T16:01:00.000Z [DEBUG] A
        2026-02-06T16:01:01.000Z [WARN] B
        2026-02-06T16:01:02.000Z [ERROR] C
        2026-02-06T16:01:03.000Z [DEBUG] D
        """
        let page = loader.parsePaged(text, offset: 0, limit: 2)
        #expect(page.totalCount == 4)
        #expect(page.entries.count == 2)
        #expect(page.entries[0].message == "A")
        #expect(page.entries[1].message == "B")
    }
}
