@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("Debug Log Screenshots")
struct ScreenshotTests_DebugLog {
    private let isRecording = false

    private func makeTempDebugLog() throws -> (dir: URL, sessionId: String) {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("poirot-debug-screenshot-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let sessionId = "screenshot-session"
        let content = """
        2026-02-06T16:01:34.872Z [DEBUG] Loading MCP servers from ~/.claude.json
        2026-02-06T16:01:34.910Z [DEBUG] Starting MCP server: playwright
        2026-02-06T16:01:35.042Z [DEBUG] Starting MCP server: github
        2026-02-06T16:01:35.123Z [DEBUG] Starting MCP server: notion
        2026-02-06T16:01:35.456Z [WARN] MCP server "notion" slow to respond (> 500ms)
        2026-02-06T16:01:36.789Z [ERROR] MCP server "notion" failed to start: connection refused
        2026-02-06T16:01:36.800Z [DEBUG] Retrying MCP server "notion" (attempt 2/3)
        2026-02-06T16:01:37.012Z [DEBUG] Permission update: allow Bash for project /Users/dev/my-app
        2026-02-06T16:01:37.100Z [DEBUG] Permission update: allow Read for project /Users/dev/my-app
        2026-02-06T16:01:37.250Z [WARN] Deprecated config key "model" found in ~/.claude.json
        2026-02-06T16:01:37.400Z [DEBUG] Session initialized with model claude-sonnet-4-20250514
        2026-02-06T16:01:37.500Z [DEBUG] Loading conversation history (42 messages)
        2026-02-06T16:01:38.100Z [ERROR] Failed to parse message at index 38: invalid tool_use block
        2026-02-06T16:01:38.200Z [DEBUG] Skipped corrupted message, continuing with 41 messages
        2026-02-06T16:01:38.300Z [DEBUG] Conversation context ready (18,432 tokens)
        """

        let fileURL = dir.appendingPathComponent("\(sessionId).txt")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return (dir, sessionId)
    }

    @Test
    func testDebugLogView() async throws {
        let (dir, sessionId) = try makeTempDebugLog()
        defer { try? FileManager.default.removeItem(at: dir) }

        try await snapshotView(
            DebugLogView(sessionId: sessionId, claudeDebugPath: dir.path),
            size: CGSize(width: 800, height: 600),
            named: "testDebugLogView",
            record: isRecording,
            delay: 1
        )
    }
}
