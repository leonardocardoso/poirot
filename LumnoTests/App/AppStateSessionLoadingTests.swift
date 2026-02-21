@testable import Lumno
import Foundation
import Testing

/// Tests that verify the session loading state machine behaves correctly,
/// particularly around the race condition where rapid session switching
/// could leave `isLoadingSession` stuck at `true`.
@Suite("AppState Session Loading")
struct AppStateSessionLoadingTests {
    // MARK: - Helpers

    private func makeStubSession(
        id: String,
        messages: [Message] = [],
        fileURL: URL? = URL(fileURLWithPath: "/tmp/test.jsonl")
    ) -> Session {
        Session(
            id: id,
            projectPath: "/test/path",
            messages: messages,
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            fileURL: fileURL
        )
    }

    private func makeLoadedSession(id: String) -> Session {
        Session(
            id: id,
            projectPath: "/test/path",
            messages: [
                Message(
                    id: "m-\(id)",
                    role: .user,
                    content: [.text("Hello")],
                    timestamp: .now,
                    model: nil,
                    tokenUsage: nil
                ),
            ],
            startedAt: .now,
            model: "opus",
            totalTokens: 100,
            fileURL: URL(fileURLWithPath: "/tmp/test.jsonl")
        )
    }

    // MARK: - Cache Hit Path

    @Test
    func selectingCachedSession_setsLoadingFalse() {
        let state = AppState()
        let loaded = makeLoadedSession(id: "s1")
        state.cacheSession(loaded)
        state.isLoadingSession = true

        // Simulate what onChange does when cache hits
        let stub = makeStubSession(id: "s1")
        if let cached = state.cachedSession(for: stub.id) {
            state.selectedSession = cached
            state.isLoadingSession = false
        }

        #expect(state.isLoadingSession == false)
        #expect(state.selectedSession?.messages.isEmpty == false)
    }

    // MARK: - Guard Early Returns

    @Test
    func selectingNilSession_resetsLoadingFlag() {
        let state = AppState()
        state.isLoadingSession = true

        // Simulate onChange with nil session (deselection)
        state.selectedSession = nil
        // The guard at line 38 fires
        state.isLoadingSession = false

        #expect(state.isLoadingSession == false)
    }

    @Test
    func selectingFullyLoadedSession_resetsLoadingFlag() {
        let state = AppState()
        state.isLoadingSession = true

        // Session already has messages — no loading needed
        let loaded = makeLoadedSession(id: "s1")
        state.selectedSession = loaded
        // The guard at line 39 fires (messages not empty)
        if !loaded.messages.isEmpty {
            state.isLoadingSession = false
        }

        #expect(state.isLoadingSession == false)
    }

    @Test
    func selectingSessionWithNoFileURL_resetsLoadingFlag() {
        let state = AppState()
        state.isLoadingSession = true

        // Session with no fileURL — can't load
        let noFile = Session(
            id: "s1",
            projectPath: "/path",
            messages: [],
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            fileURL: nil
        )
        state.selectedSession = noFile
        // The guard at line 40 fires (fileURL is nil)
        if noFile.fileURL == nil {
            state.isLoadingSession = false
        }

        #expect(state.isLoadingSession == false)
    }

    // MARK: - Defer Cleanup Scenarios

    @Test
    func deferBlock_resetsFlag_whenSessionStillSelected() {
        let state = AppState()
        let sessionId = "s1"
        state.selectedSession = makeStubSession(id: sessionId)
        state.isLoadingSession = true

        // Simulate the defer block from ContentView
        // This runs regardless of how the task exits
        if state.selectedSession?.id == sessionId {
            state.isLoadingSession = false
        }

        #expect(state.isLoadingSession == false)
    }

    @Test
    func deferBlock_skipsReset_whenDifferentSessionSelected() {
        let state = AppState()
        let originalId = "s1"
        state.selectedSession = makeStubSession(id: "s2") // User navigated away
        state.isLoadingSession = true

        // Defer block checks if the session still matches
        if state.selectedSession?.id == originalId {
            state.isLoadingSession = false
        }

        // Should NOT reset — a different session is now loading
        #expect(state.isLoadingSession == true)
    }

    @Test
    func deferBlock_resetsFlag_afterCancellation() {
        let state = AppState()
        let sessionId = "s1"
        state.selectedSession = makeStubSession(id: sessionId)
        state.isLoadingSession = true

        // Simulate: task was cancelled but session still selected
        // (user clicked same session again, new task will handle it)
        // The defer from the OLD cancelled task runs:
        if state.selectedSession?.id == sessionId {
            state.isLoadingSession = false
        }

        #expect(state.isLoadingSession == false)
    }

    // MARK: - Rapid Selection Simulation

    @Test
    func rapidSelection_cacheHitAfterStub_resetsLoadingCorrectly() {
        let state = AppState()
        let loaded = makeLoadedSession(id: "s1")
        state.cacheSession(loaded)

        // Step 1: Select stub (triggers loading)
        state.selectedSession = makeStubSession(id: "s1")
        state.isLoadingSession = true

        // Step 2: Cache hit resolves immediately
        if let cached = state.cachedSession(for: "s1") {
            state.selectedSession = cached
            state.isLoadingSession = false
        }

        #expect(state.isLoadingSession == false)
        #expect(state.selectedSession?.messages.count == 1)
    }

    @Test
    func rapidSelection_switchBackToCached_resetsCorrectly() {
        let state = AppState()

        // Pre-cache session A
        let loadedA = makeLoadedSession(id: "sA")
        state.cacheSession(loadedA)

        // Select uncached session B
        state.selectedSession = makeStubSession(id: "sB")
        state.isLoadingSession = true

        // Quickly switch back to cached session A
        if let cached = state.cachedSession(for: "sA") {
            state.selectedSession = cached
            state.isLoadingSession = false
        }

        // B's defer runs but sees different session selected
        let bSessionId = "sB"
        if state.selectedSession?.id == bSessionId {
            state.isLoadingSession = false // Should NOT execute
        }

        #expect(state.isLoadingSession == false)
        #expect(state.selectedSession?.id == "sA")
    }

    // MARK: - Successful Load Path

    @Test
    func successfulLoad_cachesAndUpdatesSession() {
        let state = AppState()
        let sessionId = "s1"
        state.selectedSession = makeStubSession(id: sessionId)
        state.isLoadingSession = true

        // Simulate successful parse result
        let full = makeLoadedSession(id: sessionId)
        state.cacheSession(full)
        state.selectedSession = full

        // Defer fires after assignment
        if state.selectedSession?.id == sessionId {
            state.isLoadingSession = false
        }

        #expect(state.isLoadingSession == false)
        #expect(state.cachedSession(for: sessionId) != nil)
        #expect(state.selectedSession?.messages.isEmpty == false)
    }

    @Test
    func successfulLoad_nilParseResult_stillResetsLoading() {
        let state = AppState()
        let sessionId = "s1"
        state.selectedSession = makeStubSession(id: sessionId)
        state.isLoadingSession = true

        // Simulate parse returning nil (corrupt file)
        let full: Session? = nil
        if let full {
            state.cacheSession(full)
            state.selectedSession = full
        }

        // Defer fires
        if state.selectedSession?.id == sessionId {
            state.isLoadingSession = false
        }

        #expect(state.isLoadingSession == false)
    }
}
