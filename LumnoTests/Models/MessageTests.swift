import Testing
@testable import Lumno

@Suite("Message Model")
struct MessageTests {

    @Test func textContent_withTextBlocks_joinsWithNewline() {
        let message = Message(
            id: "1", role: .user,
            content: [.text("Hello"), .text("World")],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        #expect(message.textContent == "Hello\nWorld")
    }

    @Test func textContent_withNoTextBlocks_returnsEmpty() {
        let message = Message(
            id: "2", role: .assistant,
            content: [
                .toolUse(ToolUse(id: "t1", name: "Read", input: ["file_path": "/test.swift"]))
            ],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        #expect(message.textContent.isEmpty)
    }

    @Test func textContent_withMixedBlocks_extractsTextOnly() {
        let message = Message(
            id: "3", role: .assistant,
            content: [
                .text("Before"),
                .toolUse(ToolUse(id: "t1", name: "Bash", input: ["command": "ls"])),
                .text("After")
            ],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        #expect(message.textContent == "Before\nAfter")
    }

    @Test func toolBlocks_extractsToolUseOnly() {
        let tool1 = ToolUse(id: "t1", name: "Read", input: ["file_path": "/a.swift"])
        let tool2 = ToolUse(id: "t2", name: "Edit", input: ["file_path": "/b.swift"])
        let message = Message(
            id: "4", role: .assistant,
            content: [
                .text("Let me read the file"),
                .toolUse(tool1),
                .toolResult(ToolResult(id: "r1", toolUseId: "t1", content: "file contents", isError: false)),
                .toolUse(tool2)
            ],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        #expect(message.toolBlocks.count == 2)
        #expect(message.toolBlocks[0].name == "Read")
        #expect(message.toolBlocks[1].name == "Edit")
    }

    @Test func toolBlocks_withNoTools_returnsEmpty() {
        let message = Message(
            id: "5", role: .user,
            content: [.text("Just text")],
            timestamp: .now, model: nil, tokenUsage: nil
        )
        #expect(message.toolBlocks.isEmpty)
    }
}
