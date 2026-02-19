import Foundation

struct Session: Identifiable, Hashable {
    let id: String
    let projectPath: String
    let messages: [Message]
    let startedAt: Date
    let model: String?
    let totalTokens: Int

    var projectName: String {
        (projectPath as NSString).lastPathComponent
    }

    var title: String {
        messages.first(where: { $0.role == .user })?.textContent ?? "Untitled session"
    }

    var turnCount: Int {
        messages.filter { $0.role == .user }.count
    }

    var timeAgo: String {
        RelativeDateTimeFormatter().localizedString(for: startedAt, relativeTo: .now)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.id == rhs.id
    }
}
