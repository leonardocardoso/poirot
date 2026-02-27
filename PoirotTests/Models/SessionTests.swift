@testable import Poirot
import Foundation
import Testing

@Suite("Session Model")
struct SessionTests {
    @Test
    func title_withUserMessage_returnsFirstUserMessageText() {
        let session = Session(
            id: "1",
            projectPath: "/Users/dev/my-project",
            messages: [
                Message(
                    id: "m1", role: .user,
                    content: [.text("Hello world")],
                    timestamp: .now, model: nil, tokenUsage: nil
                ),
            ],
            startedAt: .now,
            model: "claude-sonnet-4-6",
            totalTokens: 100
        )
        #expect(session.title == "Hello world")
    }

    @Test
    func title_withNoUserMessage_returnsUntitled() {
        let session = Session(
            id: "2",
            projectPath: "/path",
            messages: [
                Message(
                    id: "m1", role: .assistant,
                    content: [.text("Hi there")],
                    timestamp: .now, model: nil, tokenUsage: nil
                ),
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0
        )
        #expect(session.title == "Untitled session")
    }

    @Test
    func title_withEmptyMessages_returnsUntitled() {
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

    @Test
    func projectName_returnsLastPathComponent() {
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

    @Test
    func turnCount_countsOnlyUserMessages() {
        let session = Session(
            id: "5",
            projectPath: "/path",
            messages: [
                Message(id: "m1", role: .user, content: [.text("a")], timestamp: .now, model: nil, tokenUsage: nil),
                Message(
                    id: "m2",
                    role: .assistant,
                    content: [.text("b")],
                    timestamp: .now,
                    model: nil,
                    tokenUsage: nil
                ),
                Message(id: "m3", role: .user, content: [.text("c")], timestamp: .now, model: nil, tokenUsage: nil),
                Message(id: "m4", role: .system, content: [.text("d")], timestamp: .now, model: nil, tokenUsage: nil),
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0
        )
        #expect(session.turnCount == 2)
    }

    @Test
    func equality_basedOnId() {
        let session1 = Session(id: "same", projectPath: "/a", messages: [], startedAt: .now, model: nil, totalTokens: 0)
        let session2 = Session(
            id: "same",
            projectPath: "/b",
            messages: [],
            startedAt: .now,
            model: nil,
            totalTokens: 100
        )
        #expect(session1 == session2)
    }

    // MARK: - Cached Properties

    @Test
    func title_withCachedTitle_prefersCached() {
        let session = Session(
            id: "c1",
            projectPath: "/path",
            messages: [
                Message(
                    id: "m1",
                    role: .user,
                    content: [.text("From messages")],
                    timestamp: .now,
                    model: nil,
                    tokenUsage: nil
                ),
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            cachedTitle: "From cache"
        )
        #expect(session.title == "From cache")
    }

    @Test
    func title_withNilCachedTitle_fallsBackToMessages() {
        let session = Session(
            id: "c2",
            projectPath: "/path",
            messages: [
                Message(
                    id: "m1",
                    role: .user,
                    content: [.text("From messages")],
                    timestamp: .now,
                    model: nil,
                    tokenUsage: nil
                ),
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            cachedTitle: nil
        )
        #expect(session.title == "From messages")
    }

    @Test
    func turnCount_withCachedTurnCount_prefersCached() {
        let session = Session(
            id: "c3",
            projectPath: "/path",
            messages: [
                Message(id: "m1", role: .user, content: [.text("a")], timestamp: .now, model: nil, tokenUsage: nil),
                Message(id: "m2", role: .user, content: [.text("b")], timestamp: .now, model: nil, tokenUsage: nil),
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            cachedTurnCount: 5
        )
        #expect(session.turnCount == 5)
    }

    @Test
    func turnCount_withNilCachedTurnCount_fallsBackToMessages() {
        let session = Session(
            id: "c4",
            projectPath: "/path",
            messages: [
                Message(id: "m1", role: .user, content: [.text("a")], timestamp: .now, model: nil, tokenUsage: nil),
                Message(
                    id: "m2",
                    role: .assistant,
                    content: [.text("b")],
                    timestamp: .now,
                    model: nil,
                    tokenUsage: nil
                ),
                Message(id: "m3", role: .user, content: [.text("c")], timestamp: .now, model: nil, tokenUsage: nil),
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            cachedTurnCount: nil
        )
        #expect(session.turnCount == 2)
    }

    @Test
    func fileURL_defaultsToNil() {
        let session = Session(id: "c5", projectPath: "/path", messages: [], startedAt: .now, model: nil, totalTokens: 0)
        #expect(session.fileURL == nil)
    }

    @Test
    func fileURL_preservesValue() {
        let url = URL(fileURLWithPath: "/tmp/test.jsonl")
        let session = Session(
            id: "c6",
            projectPath: "/path",
            messages: [],
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            fileURL: url
        )
        #expect(session.fileURL == url)
    }

    // MARK: - First Prompt

    @Test
    func firstPrompt_defaultsToNil() {
        let session = Session(id: "fp1", projectPath: "/path", messages: [], startedAt: .now, model: nil, totalTokens: 0)
        #expect(session.firstPrompt == nil)
    }

    @Test
    func firstPrompt_preservesValue() {
        let session = Session(
            id: "fp2",
            projectPath: "/path",
            messages: [],
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            firstPrompt: "Fix the login bug"
        )
        #expect(session.firstPrompt == "Fix the login bug")
    }

    @Test
    func firstPrompt_preservesNilExplicitly() {
        let session = Session(
            id: "fp3",
            projectPath: "/path",
            messages: [],
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            firstPrompt: nil
        )
        #expect(session.firstPrompt == nil)
    }

    @Test
    func firstPrompt_preservesEmptyString() {
        let session = Session(
            id: "fp4",
            projectPath: "/path",
            messages: [],
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            firstPrompt: ""
        )
        #expect(session.firstPrompt == "")
    }
}
