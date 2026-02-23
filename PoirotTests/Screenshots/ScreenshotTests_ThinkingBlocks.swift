@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("Thinking Block Screenshots")
struct ScreenshotTests_ThinkingBlocks {
    private let isRecording = false

    // MARK: - Collapsed

    @Test
    func testThinkingCollapsed() {
        snapshotView(
            ThinkingBlockView(text: "Analyzing the user's request for performance optimization..."),
            size: ScreenshotSize.componentCollapsed,
            named: "testThinkingCollapsed",
            record: isRecording
        )
    }

    // MARK: - Expanded

    @Test
    func testThinkingExpanded() {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        let thinkingText = """
        The user is asking about performance optimization for session loading. Let me think about this carefully.

        Current flow:
        1. SessionLoader scans ~/.claude/projects/ directories
        2. For each project, it reads ALL session JSONL files
        3. Each file is fully parsed into Session/Message models
        4. All sessions are loaded into memory

        Bottlenecks:
        - Full JSONL parsing is expensive — each file can be several MB
        - Sequential loading — no parallelism
        - No caching — reloads everything on each app launch

        I think lazy loading combined with batch loading would be the biggest win.
        """

        snapshotView(
            ThinkingBlockView(text: thinkingText),
            size: CGSize(width: 600, height: 500),
            named: "testThinkingExpanded",
            record: isRecording
        )
    }

    // MARK: - Long Content (Truncated)

    @Test
    func testThinkingLongContent() {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        var lines = ["Analyzing the codebase structure:\n"]
        for i in 1 ... 80 {
            lines.append("\(i). Checking module dependency_\(String(format: "%03d", i)): resolved")
        }

        snapshotView(
            ThinkingBlockView(text: lines.joined(separator: "\n")),
            size: CGSize(width: 600, height: 500),
            named: "testThinkingLongContent",
            record: isRecording
        )
    }

    // MARK: - Short Content

    @Test
    func testThinkingShort() {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        snapshotView(
            ThinkingBlockView(text: "Quick check — yes, this is correct."),
            size: CGSize(width: 600, height: 160),
            named: "testThinkingShort",
            record: isRecording
        )
    }
}
