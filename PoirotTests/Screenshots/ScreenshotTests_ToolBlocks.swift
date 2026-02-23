import SnapshotTesting
import SwiftUI
import Testing

@testable import Poirot

@Suite("Tool Block Screenshots")
struct ScreenshotTests_ToolBlocks {
    private let isRecording = false

    // MARK: - Collapsed Tool Blocks

    @Test
    func testReadToolCollapsed() {
        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.readTool, result: ScreenshotData.readResult)
            ),
            size: ScreenshotSize.componentCollapsed,
            named: "testReadToolCollapsed",
            record: isRecording
        )
    }

    @Test
    func testWriteToolCollapsed() {
        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.writeTool, result: ScreenshotData.writeResult)
            ),
            size: ScreenshotSize.componentCollapsed,
            named: "testWriteToolCollapsed",
            record: isRecording
        )
    }

    @Test
    func testEditToolCollapsed() {
        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.editTool, result: ScreenshotData.editResult)
            ),
            size: ScreenshotSize.componentCollapsed,
            named: "testEditToolCollapsed",
            record: isRecording
        )
    }

    @Test
    func testBashToolCollapsed() {
        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.bashTool, result: ScreenshotData.bashResult)
            ),
            size: ScreenshotSize.componentCollapsed,
            named: "testBashToolCollapsed",
            record: isRecording
        )
    }

    @Test
    func testGlobToolCollapsed() {
        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.globTool, result: ScreenshotData.globResult)
            ),
            size: ScreenshotSize.componentCollapsed,
            named: "testGlobToolCollapsed",
            record: isRecording
        )
    }

    @Test
    func testGrepToolCollapsed() {
        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.grepTool, result: ScreenshotData.grepResult)
            ),
            size: ScreenshotSize.componentCollapsed,
            named: "testGrepToolCollapsed",
            record: isRecording
        )
    }

    @Test
    func testTaskToolCollapsed() {
        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.taskTool, result: ScreenshotData.taskResult)
            ),
            size: ScreenshotSize.componentCollapsed,
            named: "testTaskToolCollapsed",
            record: isRecording
        )
    }

    // MARK: - Expanded Tool Blocks

    @Test
    func testReadToolExpanded() {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.readTool, result: ScreenshotData.readResult)
            ),
            size: ScreenshotSize.component,
            named: "testReadToolExpanded",
            record: isRecording
        )
    }

    @Test
    func testBashToolExpanded() {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.bashTool, result: ScreenshotData.bashResult)
            ),
            size: ScreenshotSize.component,
            named: "testBashToolExpanded",
            record: isRecording
        )
    }

    // MARK: - Error States

    @Test
    func testBashErrorTool() {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.bashErrorTool, result: ScreenshotData.bashErrorResult)
            ),
            size: ScreenshotSize.component,
            named: "testBashErrorTool",
            record: isRecording
        )
    }

    // MARK: - Unknown Tool

    @Test
    func testUnknownTool() {
        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.unknownTool, result: ScreenshotData.unknownResult)
            ),
            size: ScreenshotSize.componentCollapsed,
            named: "testUnknownTool",
            record: isRecording
        )
    }

    // MARK: - Edit with Diff

    @Test
    func testEditDiffExpanded() {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        let tool = ToolUse(
            id: "edit-diff-test",
            name: "Edit",
            input: [
                "file_path": "Poirot/Sources/Services/SessionLoader.swift",
                "old_string": ScreenshotData.multiLineDiffOld,
                "new_string": ScreenshotData.multiLineDiffNew,
            ]
        )
        let result = ToolResult(
            id: "edit-diff-test-result",
            toolUseId: "edit-diff-test",
            content: "Successfully edited Poirot/Sources/Services/SessionLoader.swift",
            isError: false
        )

        snapshotView(
            withEnvironment(ToolBlockView(tool: tool, result: result)),
            size: ScreenshotSize.component,
            named: "testEditDiffExpanded",
            record: isRecording
        )
    }

    // MARK: - Long Content (Truncated)

    @Test
    func testLongContentTruncated() {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.longContentTool, result: ScreenshotData.longContentResult)
            ),
            size: ScreenshotSize.component,
            named: "testLongContentTruncated",
            record: isRecording
        )
    }

    // MARK: - No Output

    @Test
    func testNoOutputTool() {
        UserDefaults.standard.set(true, forKey: "autoExpandBlocks")
        defer { UserDefaults.standard.removeObject(forKey: "autoExpandBlocks") }

        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.noOutputTool, result: ScreenshotData.noOutputResult)
            ),
            size: CGSize(width: 600, height: 120),
            named: "testNoOutputTool",
            record: isRecording
        )
    }

    // MARK: - Bash Error Collapsed

    @Test
    func testBashErrorCollapsed() {
        snapshotView(
            withEnvironment(
                ToolBlockView(tool: ScreenshotData.bashErrorTool, result: ScreenshotData.bashErrorResult)
            ),
            size: ScreenshotSize.componentCollapsed,
            named: "testBashErrorCollapsed",
            record: isRecording
        )
    }
}
