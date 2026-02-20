import Observation
import SwiftUI

@Observable
final class AppState {
    var selectedNav: NavigationItem = .sessions
    var selectedSession: Session?
    var selectedProject: String?
    var isSearchPresented: Bool = false
    var projects: [Project] = []
    var isLoadingProjects: Bool = true
    var isLoadingSession: Bool = false
    private(set) var sessionCache: [String: Session] = [:]

    func cacheSession(_ session: Session) {
        sessionCache[session.id] = session
    }

    func cachedSession(for id: String) -> Session? {
        sessionCache[id]
    }

    func clearCache() {
        sessionCache.removeAll()
    }
}
