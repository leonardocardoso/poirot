@testable import Lumno
import Foundation
import Testing

@Suite("AppState Cache")
struct AppStateCacheTests {
    private func makeSession(id: String) -> Session {
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
            model: "claude-sonnet-4-6",
            totalTokens: 100
        )
    }

    @Test
    func cacheSession_storesAndRetrieves() {
        let state = AppState()
        let session = makeSession(id: "abc-123")

        state.cacheSession(session)
        let cached = state.cachedSession(for: "abc-123")

        #expect(cached != nil)
        #expect(cached?.id == "abc-123")
    }

    @Test
    func cachedSession_returnsNilForUnknownId() {
        let state = AppState()

        let cached = state.cachedSession(for: "nonexistent")

        #expect(cached == nil)
    }

    @Test
    func clearCache_removesAllEntries() {
        let state = AppState()
        state.cacheSession(makeSession(id: "s1"))
        state.cacheSession(makeSession(id: "s2"))

        state.clearCache()

        #expect(state.cachedSession(for: "s1") == nil)
        #expect(state.cachedSession(for: "s2") == nil)
        #expect(state.sessionCache.isEmpty)
    }
}
