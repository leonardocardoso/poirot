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
    var sidebarSearchQuery: String = ""
    var refreshID: UUID = .init()
    private(set) var sessionCache: [String: Session] = [:]

    var filteredSortedProjects: [Project] {
        let nonEmpty = projects.filter { !$0.sessions.isEmpty }
        let searched: [Project]
        let trimmed = sidebarSearchQuery.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            searched = nonEmpty
        } else {
            let query = trimmed.lowercased()
            searched = nonEmpty.compactMap { project in
                if project.name.lowercased().contains(query) { return project }
                let matchingSessions = project.sessions.filter {
                    $0.title.lowercased().contains(query)
                }
                if matchingSessions.isEmpty { return nil }
                return Project(id: project.id, name: project.name, path: project.path, sessions: matchingSessions)
            }
        }
        switch projectSortOption {
        case .recentActivity:
            return searched.sorted {
                ($0.recentSession?.startedAt ?? .distantPast) > ($1.recentSession?.startedAt ?? .distantPast)
            }
        case .name:
            return searched.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .sessionCount:
            return searched.sorted { $0.sessions.count > $1.sessions.count }
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

    func deleteSession(_ session: Session) {
        // Remove the file
        if let url = session.fileURL {
            try? FileManager.default.removeItem(at: url)
        }

        // Clear selection if needed
        if selectedSession == session {
            selectedSession = nil
        }

        // Remove from cache
        sessionCache.removeValue(forKey: session.id)

        // Remove from projects
        projects = projects.compactMap { project in
            let remaining = project.sessions.filter { $0.id != session.id }
            if remaining.isEmpty { return nil }
            if remaining.count == project.sessions.count { return project }
            return Project(id: project.id, name: project.name, path: project.path, sessions: remaining)
        }
    }
}
