@testable import Poirot
import Testing

@Suite("Message Model")
struct MessageTests {
    @Test
    func textContent_withTextBlocks_joinsWithNewline() {
        let message = Message(
            id: "1", role: .user,
            content: [.text("Hello"), .text("World")],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        #expect(message.textContent == "Hello\nWorld")
    }

    @Test
    func textContent_withNoTextBlocks_returnsEmpty() {
        let message = Message(
            id: "2", role: .assistant,
            content: [
                .toolUse(ToolUse(id: "t1", name: "Read", input: ["file_path": "/test.swift"])),
            ],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        #expect(message.textContent.isEmpty)
    }

    @Test
    func textContent_withMixedBlocks_extractsTextOnly() {
        let message = Message(
            id: "3", role: .assistant,
            content: [
                .text("Before"),
                .toolUse(ToolUse(id: "t1", name: "Bash", input: ["command": "ls"])),
                .text("After"),
            ],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        #expect(message.textContent == "Before\nAfter")
    }

    @Test
    func toolBlocks_extractsToolUseOnly() {
        let tool1 = ToolUse(id: "t1", name: "Read", input: ["file_path": "/a.swift"])
        let tool2 = ToolUse(id: "t2", name: "Edit", input: ["file_path": "/b.swift"])
        let message = Message(
            id: "4", role: .assistant,
            content: [
                .text("Let me read the file"),
                .toolUse(tool1),
                .toolResult(ToolResult(id: "r1", toolUseId: "t1", content: "file contents", isError: false)),
                .toolUse(tool2),
            ],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        #expect(message.toolBlocks.count == 2)
        #expect(message.toolBlocks[0].name == "Read")
        #expect(message.toolBlocks[1].name == "Edit")
    }

    @Test
    func toolBlocks_withNoTools_returnsEmpty() {
        let message = Message(
            id: "5", role: .user,
            content: [.text("Just text")],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        #expect(message.toolBlocks.isEmpty)
    }

    // MARK: - textAndToolSegments

    @Test
    func segments_textOnly_producesSingleTextSegment() {
        let message = Message(
            id: "s1", role: .assistant,
            content: [.text("Hello"), .text("World")],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        let segments = message.textAndToolSegments
        #expect(segments == [.text("Hello\nWorld")])
    }

    @Test
    func segments_toolsOnly_producesSingleToolsSegment() {
        let tool1 = ToolUse(id: "t1", name: "Read", input: [:])
        let tool2 = ToolUse(id: "t2", name: "Edit", input: [:])
        let message = Message(
            id: "s2", role: .assistant,
            content: [.toolUse(tool1), .toolUse(tool2)],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        let segments = message.textAndToolSegments
        #expect(segments == [.tools([tool1, tool2])])
    }

    @Test
    func segments_textThenTools_producesTwoSegments() {
        let tool = ToolUse(id: "t1", name: "Bash", input: [:])
        let message = Message(
            id: "s3", role: .assistant,
            content: [.text("Let me check"), .toolUse(tool)],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        let segments = message.textAndToolSegments
        #expect(segments == [.text("Let me check"), .tools([tool])])
    }

    @Test
    func segments_thinkingProducesThinkingSegment() {
        let message = Message(
            id: "s4", role: .assistant,
            content: [.thinking("reasoning here")],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        let segments = message.textAndToolSegments
        #expect(segments == [.thinking("reasoning here")])
    }

    @Test
    func segments_thinkingFlushesAccumulatedText() {
        let message = Message(
            id: "s5", role: .assistant,
            content: [.text("Before"), .thinking("reasoning"), .text("After")],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        let segments = message.textAndToolSegments
        #expect(segments == [
            .text("Before"),
            .thinking("reasoning"),
            .text("After"),
        ])
    }

    @Test
    func segments_thinkingFlushesAccumulatedTools() {
        let tool = ToolUse(id: "t1", name: "Read", input: [:])
        let message = Message(
            id: "s6", role: .assistant,
            content: [.toolUse(tool), .thinking("reasoning"), .text("Done")],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        let segments = message.textAndToolSegments
        #expect(segments == [
            .tools([tool]),
            .thinking("reasoning"),
            .text("Done"),
        ])
    }

    @Test
    func segments_multipleThinkingBlocksInterleave() {
        let tool = ToolUse(id: "t1", name: "Bash", input: [:])
        let message = Message(
            id: "s7", role: .assistant,
            content: [
                .thinking("first thought"),
                .text("Response"),
                .thinking("second thought"),
                .toolUse(tool),
            ],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        let segments = message.textAndToolSegments
        #expect(segments == [
            .thinking("first thought"),
            .text("Response"),
            .thinking("second thought"),
            .tools([tool]),
        ])
    }

    @Test
    func segments_toolResultsAreIgnored() {
        let tool = ToolUse(id: "t1", name: "Read", input: [:])
        let message = Message(
            id: "s8", role: .assistant,
            content: [
                .text("Check"),
                .toolUse(tool),
                .toolResult(ToolResult(id: "r1", toolUseId: "t1", content: "output", isError: false)),
            ],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        let segments = message.textAndToolSegments
        #expect(segments == [.text("Check"), .tools([tool])])
    }

    // MARK: - ToolUse Edit Detection

    @Test
    func isEdit_trueForEditTool() {
        let tool = ToolUse(id: "e1", name: "Edit", input: ["file_path": "/a.swift"])
        #expect(tool.isEdit)
    }

    @Test
    func isEdit_falseForOtherTools() {
        let read = ToolUse(id: "r1", name: "Read", input: [:])
        let bash = ToolUse(id: "b1", name: "Bash", input: [:])
        #expect(!read.isEdit)
        #expect(!bash.isEdit)
    }

    @Test
    func hasDiffData_trueWhenBothStringsPresent() {
        let tool = ToolUse(
            id: "e1", name: "Edit",
            input: ["file_path": "/a.swift", "old_string": "old", "new_string": "new"]
        )
        #expect(tool.hasDiffData)
        #expect(tool.oldString == "old")
        #expect(tool.newString == "new")
    }

    @Test
    func hasDiffData_falseWhenMissingStrings() {
        let noOld = ToolUse(id: "e1", name: "Edit", input: ["new_string": "new"])
        let noNew = ToolUse(id: "e2", name: "Edit", input: ["old_string": "old"])
        let neither = ToolUse(id: "e3", name: "Edit", input: [:])
        #expect(!noOld.hasDiffData)
        #expect(!noNew.hasDiffData)
        #expect(!neither.hasDiffData)
    }

    @Test
    func hasDiffData_falseForNonEditTool() {
        let tool = ToolUse(
            id: "r1", name: "Read",
            input: ["old_string": "old", "new_string": "new"]
        )
        #expect(!tool.hasDiffData)
    }
}
