@testable import Poirot
import Foundation
import Testing

@Suite("MenuBarState")
struct MenuBarStateTests {
    // MARK: - Helpers

    private func makeSession(
        id: String,
        startedAt: Date = .now
    ) -> Session {
        Session(
            id: id,
            projectPath: "/test/path",
            messages: [],
            startedAt: startedAt,
            model: nil,
            totalTokens: 0
        )
    }

    private func makeProject(
        id: String = "proj",
        name: String = "test-project",
        sessions: [Session] = []
    ) -> Project {
        Project(id: id, name: name, path: "/test/path", sessions: sessions)
    }

    // MARK: - Initial State

    @Test
    func initialState_hasCorrectDefaults() {
        let state = MenuBarState()

        #expect(state.recentSessions.isEmpty)
        #expect(state.searchQuery.isEmpty)
        #expect(state.claudeCodeStatus == .idle)
    }

    // MARK: - Load Recent Sessions

    @Test
    func loadRecentSessions_sortsbyMostRecent() {
        let state = MenuBarState()
        let older = makeSession(id: "s1", startedAt: Date(timeIntervalSince1970: 1000))
        let newer = makeSession(id: "s2", startedAt: Date(timeIntervalSince1970: 9000))
        let projects = [
            makeProject(id: "p1", name: "alpha", sessions: [older]),
            makeProject(id: "p2", name: "beta", sessions: [newer]),
        ]

        state.loadRecentSessions(from: projects)

        #expect(state.recentSessions.count == 2)
        #expect(state.recentSessions.first?.session.id == "s2")
        #expect(state.recentSessions.last?.session.id == "s1")
    }

    @Test
    func loadRecentSessions_limitsToTen() {
        let state = MenuBarState()
        var sessions: [Session] = []
        for i in 0 ..< 15 {
            sessions.append(makeSession(
                id: "s\(i)",
                startedAt: Date(timeIntervalSince1970: Double(i * 1000))
            ))
        }
        let projects = [makeProject(id: "p1", name: "big-project", sessions: sessions)]

        state.loadRecentSessions(from: projects)

        #expect(state.recentSessions.count == 10)
    }

    @Test
    func loadRecentSessions_includesProjectInfo() {
        let state = MenuBarState()
        let session = makeSession(id: "s1")
        let projects = [makeProject(id: "p1", name: "my-app", sessions: [session])]

        state.loadRecentSessions(from: projects)

        #expect(state.recentSessions.first?.project.name == "my-app")
        #expect(state.recentSessions.first?.session.id == "s1")
    }

    @Test
    func loadRecentSessions_emptyProjects() {
        let state = MenuBarState()

        state.loadRecentSessions(from: [])

        #expect(state.recentSessions.isEmpty)
    }

    // MARK: - Filtered Sessions

    @Test
    func filteredSessions_emptyQueryReturnsAll() {
        let state = MenuBarState()
        let session = makeSession(id: "s1")
        let projects = [makeProject(id: "p1", name: "alpha", sessions: [session])]
        state.loadRecentSessions(from: projects)
        state.searchQuery = ""

        #expect(state.filteredSessions.count == 1)
    }

    @Test
    func filteredSessions_whitespaceQueryReturnsAll() {
        let state = MenuBarState()
        let session = makeSession(id: "s1")
        let projects = [makeProject(id: "p1", name: "alpha", sessions: [session])]
        state.loadRecentSessions(from: projects)
        state.searchQuery = "   "

        #expect(state.filteredSessions.count == 1)
    }

    // MARK: - Claude Code Status Detection

    @Test
    func detectClaudeCodeStatus_notInstalled() {
        let state = MenuBarState()

        let status = state.detectClaudeCodeStatus(cliPath: "/nonexistent/path/to/claude")

        #expect(status == .notInstalled)
    }

    @Test
    func detectClaudeCodeStatus_returnsIdleOrRunning() {
        let state = MenuBarState()

        // Using /bin/sh as a known existing path for testing
        let status = state.detectClaudeCodeStatus(cliPath: "/bin/sh")

        // It should return either .idle or .running (depending on whether claude is running)
        #expect(status == .idle || status == .running)
    }
}
