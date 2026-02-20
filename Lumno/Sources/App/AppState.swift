import Observation
import SwiftUI

enum ProjectSortOption: String, CaseIterable {
    case recentActivity
    case name
    case sessionCount

    var label: String {
        switch self {
        case .recentActivity: "Recent Activity"
        case .name: "Name"
        case .sessionCount: "Session Count"
        }
    }
}

@Observable
final class AppState {
    var selectedNav: NavigationItem = .sessions
    var selectedSession: Session?
    var selectedProject: String?
    var isSearchPresented: Bool = false
    var projects: [Project] = []
    var isLoadingProjects: Bool = true
    var isLoadingMoreProjects: Bool = true
    var isLoadingSession: Bool = false
    var projectSortOption: ProjectSortOption = .recentActivity
    private(set) var sessionCache: [String: Session] = [:]

    var sortedProjects: [Project] {
        let filtered = projects.filter { !$0.sessions.isEmpty }
        switch projectSortOption {
        case .recentActivity:
            return filtered.sorted {
                ($0.recentSession?.startedAt ?? .distantPast) > ($1.recentSession?.startedAt ?? .distantPast)
            }
        case .name:
            return filtered.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .sessionCount:
            return filtered.sorted { $0.sessions.count > $1.sessions.count }
        }
    }

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
