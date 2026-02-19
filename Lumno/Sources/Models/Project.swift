import Foundation

struct Project: Identifiable, Hashable {
    let id: String
    let name: String
    let path: String
    let sessions: [Session]

    var recentSession: Session? {
        sessions.max(by: { $0.startedAt < $1.startedAt })
    }
}
