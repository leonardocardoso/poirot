import SnapshotTesting
import SwiftUI
import Testing

@testable import Poirot

@Suite("Edit Diff Screenshots")
struct ScreenshotTests_EditDiff {
    private let isRecording = false

    // MARK: - Simple Change

    @Test
    func testSimpleDiff() {
        snapshotView(
            EditDiffView(
                oldString: ScreenshotData.simpleDiffOld,
                newString: ScreenshotData.simpleDiffNew,
                filePath: "Poirot/Sources/Theme/PoirotTheme.swift"
            ),
            size: ScreenshotSize.diff,
            named: "testSimpleDiff",
            record: isRecording
        )
    }

    // MARK: - Multi-Line Change

    @Test
    func testMultiLineDiff() {
        snapshotView(
            EditDiffView(
                oldString: ScreenshotData.multiLineDiffOld,
                newString: ScreenshotData.multiLineDiffNew,
                filePath: "Poirot/Sources/Services/SessionLoader.swift"
            ),
            size: ScreenshotSize.diff,
            named: "testMultiLineDiff",
            record: isRecording
        )
    }

    // MARK: - Add Only

    @Test
    func testAddOnlyDiff() {
        snapshotView(
            EditDiffView(
                oldString: ScreenshotData.addOnlyDiffOld,
                newString: ScreenshotData.addOnlyDiffNew,
                filePath: "Poirot/Sources/Models/Config.swift"
            ),
            size: ScreenshotSize.diff,
            named: "testAddOnlyDiff",
            record: isRecording
        )
    }

    // MARK: - Remove Only

    @Test
    func testRemoveOnlyDiff() {
        snapshotView(
            EditDiffView(
                oldString: ScreenshotData.removeOnlyDiffOld,
                newString: ScreenshotData.removeOnlyDiffNew,
                filePath: "Poirot/Sources/Services/LegacyLoader.swift"
            ),
            size: ScreenshotSize.diff,
            named: "testRemoveOnlyDiff",
            record: isRecording
        )
    }
}
