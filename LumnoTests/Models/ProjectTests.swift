import Foundation
import Testing
@testable import Lumno

@Suite("Project Model")
struct ProjectTests {

    @Test func recentSession_returnsMostRecent() {
        let older = Session(
            id: "1", projectPath: "/path", messages: [],
            startedAt: Date(timeIntervalSince1970: 1000),
            model: nil, totalTokens: 0
        )
        let newer = Session(
            id: "2", projectPath: "/path", messages: [],
            startedAt: Date(timeIntervalSince1970: 2000),
            model: nil, totalTokens: 0
        )
        let project = Project(id: "p1", name: "test", path: "/path", sessions: [older, newer])
        #expect(project.recentSession?.id == "2")
    }

    @Test func recentSession_withNoSessions_returnsNil() {
        let project = Project(id: "p1", name: "test", path: "/path", sessions: [])
        #expect(project.recentSession == nil)
    }

    @Test func recentSession_withSingleSession_returnsThatSession() {
        let session = Session(
            id: "only", projectPath: "/path", messages: [],
            startedAt: .now, model: nil, totalTokens: 0
        )
        let project = Project(id: "p1", name: "test", path: "/path", sessions: [session])
        #expect(project.recentSession?.id == "only")
    }
}
