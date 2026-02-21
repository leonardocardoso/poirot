@testable import Lumno
import Foundation
import Testing

@Suite("AppState")
struct AppStateTests {
    // MARK: - Helpers

    private func makeSession(
        id: String,
        projectPath: String = "/test/path",
        messages: [Message] = [],
        startedAt: Date = .now,
        model: String? = nil,
        totalTokens: Int = 0,
        fileURL: URL? = nil
    ) -> Session {
        Session(
            id: id,
            projectPath: projectPath,
            messages: messages,
            startedAt: startedAt,
            model: model,
            totalTokens: totalTokens,
            fileURL: fileURL
        )
    }

    private func makeProject(
        id: String = "proj",
        name: String = "test-project",
        path: String = "/test/path",
        sessions: [Session] = []
    ) -> Project {
        Project(id: id, name: name, path: path, sessions: sessions)
    }

    // MARK: - Font Scale

    @Test
    func increaseFontScale_incrementsByPointZeroFive() {
        let state = AppState()
        state.fontScale = 1.0

        state.increaseFontScale()

        #expect(state.fontScale == 1.05)
    }

    @Test
    func increaseFontScale_clampsAtMaximum() {
        let state = AppState()
        state.fontScale = 1.5

        state.increaseFontScale()

        #expect(state.fontScale == 1.5)
    }

    @Test
    func decreaseFontScale_decrementsBy005() {
        let state = AppState()
        state.fontScale = 1.0

        state.decreaseFontScale()

        #expect(state.fontScale == 0.95)
    }

    @Test
    func decreaseFontScale_clampsAtMinimum() {
        let state = AppState()
        state.fontScale = 0.75

        state.decreaseFontScale()

        #expect(state.fontScale == 0.75)
    }

    @Test
    func resetFontScale_setsToOne() {
        let state = AppState()
        state.fontScale = 1.3

        state.resetFontScale()

        #expect(state.fontScale == 1.0)
    }

    // MARK: - Current Project

    @Test
    func currentProject_withMatchingId_returnsProject() {
        let state = AppState()
        let project = makeProject(id: "p1", name: "alpha")
        state.projects = [project]
        state.selectedProject = "p1"

        #expect(state.currentProject?.name == "alpha")
    }

    @Test
    func currentProject_withNilSelection_returnsNil() {
        let state = AppState()
        state.projects = [makeProject(id: "p1")]
        state.selectedProject = nil

        #expect(state.currentProject == nil)
    }

    @Test
    func currentProject_withNonMatchingId_returnsNil() {
        let state = AppState()
        state.projects = [makeProject(id: "p1")]
        state.selectedProject = "nonexistent"

        #expect(state.currentProject == nil)
    }

    // MARK: - Filtered & Sorted Projects

    @Test
    func filteredSortedProjects_excludesEmptyProjects() {
        let state = AppState()
        let empty = makeProject(id: "empty", name: "empty", sessions: [])
        let nonEmpty = makeProject(
            id: "full",
            name: "full",
            sessions: [makeSession(id: "s1")]
        )
        state.projects = [empty, nonEmpty]

        let result = state.filteredSortedProjects
        #expect(result.count == 1)
        #expect(result.first?.id == "full")
    }

    @Test
    func filteredSortedProjects_searchFiltersByProjectName() {
        let state = AppState()
        state.projects = [
            makeProject(id: "p1", name: "lumno", sessions: [makeSession(id: "s1")]),
            makeProject(id: "p2", name: "ignio", sessions: [makeSession(id: "s2")]),
        ]
        state.sidebarSearchQuery = "lum"

        let result = state.filteredSortedProjects
        #expect(result.count == 1)
        #expect(result.first?.id == "p1")
    }

    @Test
    func filteredSortedProjects_searchFiltersBySessionTitle() {
        let state = AppState()
        let session = Session(
            id: "s1",
            projectPath: "/path",
            messages: [
                Message(
                    id: "m1", role: .user,
                    content: [.text("Fix auth bug")],
                    timestamp: .now, model: nil, tokenUsage: nil
                ),
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0
        )
        state.projects = [
            makeProject(id: "p1", name: "alpha", sessions: [session]),
            makeProject(id: "p2", name: "beta", sessions: [makeSession(id: "s2")]),
        ]
        state.sidebarSearchQuery = "auth"

        let result = state.filteredSortedProjects
        #expect(result.count == 1)
        #expect(result.first?.id == "p1")
        #expect(result.first?.sessions.count == 1)
    }

    @Test
    func filteredSortedProjects_searchIsCaseInsensitive() {
        let state = AppState()
        state.projects = [
            makeProject(id: "p1", name: "MyApp", sessions: [makeSession(id: "s1")]),
        ]
        state.sidebarSearchQuery = "myapp"

        #expect(state.filteredSortedProjects.count == 1)
    }

    @Test
    func filteredSortedProjects_emptySearchReturnsAll() {
        let state = AppState()
        state.projects = [
            makeProject(id: "p1", name: "a", sessions: [makeSession(id: "s1")]),
            makeProject(id: "p2", name: "b", sessions: [makeSession(id: "s2")]),
        ]
        state.sidebarSearchQuery = "   "

        #expect(state.filteredSortedProjects.count == 2)
    }

    @Test
    func filteredSortedProjects_sortByRecentActivity() {
        let state = AppState()
        state.projectSortOption = .recentActivity
        state.projects = [
            makeProject(
                id: "old",
                name: "old",
                sessions: [makeSession(id: "s1", startedAt: Date(timeIntervalSince1970: 1000))]
            ),
            makeProject(
                id: "new",
                name: "new",
                sessions: [makeSession(id: "s2", startedAt: Date(timeIntervalSince1970: 9000))]
            ),
        ]

        let result = state.filteredSortedProjects
        #expect(result.first?.id == "new")
        #expect(result.last?.id == "old")
    }

    @Test
    func filteredSortedProjects_sortByName() {
        let state = AppState()
        state.projectSortOption = .name
        state.projects = [
            makeProject(id: "z", name: "zebra", sessions: [makeSession(id: "s1")]),
            makeProject(id: "a", name: "alpha", sessions: [makeSession(id: "s2")]),
        ]

        let result = state.filteredSortedProjects
        #expect(result.first?.id == "a")
        #expect(result.last?.id == "z")
    }

    @Test
    func filteredSortedProjects_sortBySessionCount() {
        let state = AppState()
        state.projectSortOption = .sessionCount
        state.projects = [
            makeProject(
                id: "few",
                name: "few",
                sessions: [makeSession(id: "s1")]
            ),
            makeProject(
                id: "many",
                name: "many",
                sessions: [makeSession(id: "s2"), makeSession(id: "s3"), makeSession(id: "s4")]
            ),
        ]

        let result = state.filteredSortedProjects
        #expect(result.first?.id == "many")
        #expect(result.last?.id == "few")
    }

    // MARK: - Delete Session

    @Test
    func deleteSession_removesFromProject() {
        let state = AppState()
        let session = makeSession(id: "s1")
        state.projects = [makeProject(id: "p1", sessions: [session, makeSession(id: "s2")])]

        state.deleteSession(session)

        #expect(state.projects.first?.sessions.count == 1)
        #expect(state.projects.first?.sessions.first?.id == "s2")
    }

    @Test
    func deleteSession_removesEmptyProject() {
        let state = AppState()
        let session = makeSession(id: "s1")
        state.projects = [makeProject(id: "p1", sessions: [session])]

        state.deleteSession(session)

        #expect(state.projects.isEmpty)
    }

    @Test
    func deleteSession_clearsSelectionIfSelected() {
        let state = AppState()
        let session = makeSession(id: "s1")
        state.projects = [makeProject(id: "p1", sessions: [session])]
        state.selectedSession = session

        state.deleteSession(session)

        #expect(state.selectedSession == nil)
    }

    @Test
    func deleteSession_preservesSelectionIfDifferent() {
        let state = AppState()
        let s1 = makeSession(id: "s1")
        let s2 = makeSession(id: "s2")
        state.projects = [makeProject(id: "p1", sessions: [s1, s2])]
        state.selectedSession = s2

        state.deleteSession(s1)

        #expect(state.selectedSession?.id == "s2")
    }

    @Test
    func deleteSession_removesFromCache() {
        let state = AppState()
        let session = makeSession(id: "s1")
        state.cacheSession(session)
        state.projects = [makeProject(id: "p1", sessions: [session, makeSession(id: "s2")])]

        state.deleteSession(session)

        #expect(state.cachedSession(for: "s1") == nil)
    }

    @Test
    func deleteSession_leavesOtherProjectsUntouched() {
        let state = AppState()
        let session = makeSession(id: "s1")
        state.projects = [
            makeProject(id: "p1", sessions: [session]),
            makeProject(id: "p2", name: "other", sessions: [makeSession(id: "s2")]),
        ]

        state.deleteSession(session)

        #expect(state.projects.count == 1)
        #expect(state.projects.first?.id == "p2")
    }

    // MARK: - Delete Project

    @Test
    func deleteProject_removesFromProjects() {
        let state = AppState()
        let project = makeProject(id: "p1", sessions: [makeSession(id: "s1")])
        state.projects = [project]

        state.deleteProject(project)

        #expect(state.projects.isEmpty)
    }

    @Test
    func deleteProject_clearsSelectionIfSessionBelongsToProject() {
        let state = AppState()
        let session = makeSession(id: "s1")
        let project = makeProject(id: "p1", sessions: [session])
        state.projects = [project]
        state.selectedSession = session

        state.deleteProject(project)

        #expect(state.selectedSession == nil)
    }

    @Test
    func deleteProject_preservesSelectionIfDifferentProject() {
        let state = AppState()
        let s1 = makeSession(id: "s1")
        let s2 = makeSession(id: "s2")
        let p1 = makeProject(id: "p1", sessions: [s1])
        let p2 = makeProject(id: "p2", sessions: [s2])
        state.projects = [p1, p2]
        state.selectedSession = s2

        state.deleteProject(p1)

        #expect(state.selectedSession?.id == "s2")
    }

    @Test
    func deleteProject_removesCachedSessions() {
        let state = AppState()
        let s1 = makeSession(id: "s1")
        let s2 = makeSession(id: "s2")
        state.cacheSession(s1)
        state.cacheSession(s2)
        let project = makeProject(id: "p1", sessions: [s1, s2])
        state.projects = [project]

        state.deleteProject(project)

        #expect(state.cachedSession(for: "s1") == nil)
        #expect(state.cachedSession(for: "s2") == nil)
    }

    // MARK: - Session Loading State

    @Test
    func isLoadingSession_defaultsFalse() {
        let state = AppState()
        #expect(state.isLoadingSession == false)
    }

    // MARK: - Initial State

    @Test
    func initialState_hasCorrectDefaults() {
        let state = AppState()

        #expect(state.selectedNav == .sessions)
        #expect(state.selectedSession == nil)
        #expect(state.selectedProject == nil)
        #expect(state.isSearchPresented == false)
        #expect(state.projects.isEmpty)
        #expect(state.isLoadingProjects == true)
        #expect(state.isLoadingMoreProjects == true)
        #expect(state.isLoadingSession == false)
        #expect(state.projectSortOption == .recentActivity)
        #expect(state.sidebarSearchQuery.isEmpty)
        #expect(state.sessionCache.isEmpty)
    }

    // MARK: - Cache Overwrites

    @Test
    func cacheSession_overwritesExistingEntry() {
        let state = AppState()
        let original = Session(
            id: "s1",
            projectPath: "/path",
            messages: [],
            startedAt: .now,
            model: nil,
            totalTokens: 0
        )
        let updated = Session(
            id: "s1",
            projectPath: "/path",
            messages: [
                Message(
                    id: "m1", role: .user,
                    content: [.text("Hello")],
                    timestamp: .now, model: nil, tokenUsage: nil
                ),
            ],
            startedAt: .now,
            model: "opus",
            totalTokens: 500
        )
        state.cacheSession(original)
        state.cacheSession(updated)

        let cached = state.cachedSession(for: "s1")
        #expect(cached?.messages.count == 1)
        #expect(cached?.totalTokens == 500)
    }
}
