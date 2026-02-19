import Testing
@testable import Lumno

@Suite("Session Model")
struct SessionTests {

    @Test func title_withUserMessage_returnsFirstUserMessageText() {
        let session = Session(
            id: "1",
            projectPath: "/Users/dev/my-project",
            messages: [
                Message(
                    id: "m1", role: .user,
                    content: [.text("Hello world")],
                    timestamp: .now, model: nil, tokenUsage: nil
                )
            ],
            startedAt: .now,
            model: "claude-sonnet-4-6",
            totalTokens: 100
        )
        #expect(session.title == "Hello world")
    }

    @Test func title_withNoUserMessage_returnsUntitled() {
        let session = Session(
            id: "2",
            projectPath: "/path",
            messages: [
                Message(
                    id: "m1", role: .assistant,
                    content: [.text("Hi there")],
                    timestamp: .now, model: nil, tokenUsage: nil
                )
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0
        )
        #expect(session.title == "Untitled session")
    }

    @Test func title_withEmptyMessages_returnsUntitled() {
        let session = Session(
            id: "3",
            projectPath: "/path",
            messages: [],
            startedAt: .now,
            model: nil,
            totalTokens: 0
        )
        #expect(session.title == "Untitled session")
    }

    @Test func projectName_returnsLastPathComponent() {
        let session = Session(
            id: "4",
            projectPath: "/Users/dev/my-project",
            messages: [],
            startedAt: .now,
            model: nil,
            totalTokens: 0
        )
        #expect(session.projectName == "my-project")
    }

    @Test func turnCount_countsOnlyUserMessages() {
        let session = Session(
            id: "5",
            projectPath: "/path",
            messages: [
                Message(id: "m1", role: .user, content: [.text("a")], timestamp: .now, model: nil, tokenUsage: nil),
                Message(id: "m2", role: .assistant, content: [.text("b")], timestamp: .now, model: nil, tokenUsage: nil),
                Message(id: "m3", role: .user, content: [.text("c")], timestamp: .now, model: nil, tokenUsage: nil),
                Message(id: "m4", role: .system, content: [.text("d")], timestamp: .now, model: nil, tokenUsage: nil)
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0
        )
        #expect(session.turnCount == 2)
    }

    @Test func equality_basedOnId() {
        let session1 = Session(id: "same", projectPath: "/a", messages: [], startedAt: .now, model: nil, totalTokens: 0)
        let session2 = Session(id: "same", projectPath: "/b", messages: [], startedAt: .now, model: nil, totalTokens: 100)
        #expect(session1 == session2)
    }
}
