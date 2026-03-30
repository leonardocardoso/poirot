import Foundation

nonisolated struct SessionGroup: Identifiable {
    let id: String
    let parent: Session
    let agents: [Session]

    var agentCount: Int { agents.count }
    var allSessions: [Session] { [parent] + agents }

    /// Groups a flat array of sessions into parent-child hierarchies.
    /// Agent sessions are matched to parents by `parentSessionId`.
    /// Orphan agents (no matching parent) become standalone groups.
    static func group(sessions: [Session]) -> [SessionGroup] {
        var parents: [Session] = []
        var childrenByParent: [String: [Session]] = [:]
        var orphans: [Session] = []

        for session in sessions {
            if let parentId = session.parentSessionId {
                childrenByParent[parentId, default: []].append(session)
            } else if !session.isSidechain {
                parents.append(session)
            } else {
                orphans.append(session)
            }
        }

        var groups: [SessionGroup] = parents.map { parent in
            let agents = (childrenByParent[parent.id] ?? [])
                .sorted { $0.startedAt < $1.startedAt }
            return SessionGroup(id: parent.id, parent: parent, agents: agents)
        }

        // Orphan sidechains without a parent become standalone groups
        for orphan in orphans {
            groups.append(SessionGroup(id: orphan.id, parent: orphan, agents: []))
        }

        return groups.sorted { $0.parent.startedAt > $1.parent.startedAt }
    }
}
