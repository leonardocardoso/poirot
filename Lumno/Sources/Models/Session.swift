import Foundation

nonisolated struct Session: Identifiable, Hashable {
    let id: String
    let projectPath: String
    let messages: [Message]
    let startedAt: Date
    let model: String?
    let totalTokens: Int
    let fileURL: URL?
    let cachedTitle: String?
    let cachedPreview: String?
    let cachedTurnCount: Int?

    init(
        id: String,
        projectPath: String,
        messages: [Message],
        startedAt: Date,
        model: String?,
        totalTokens: Int,
        fileURL: URL? = nil,
        cachedTitle: String? = nil,
        cachedPreview: String? = nil,
        cachedTurnCount: Int? = nil
    ) {
        self.id = id
        self.projectPath = projectPath
        self.messages = messages
        self.startedAt = startedAt
        self.model = model
        self.totalTokens = totalTokens
        self.fileURL = fileURL
        self.cachedTitle = cachedTitle
        self.cachedPreview = cachedPreview
        self.cachedTurnCount = cachedTurnCount
    }

    var projectName: String {
        (projectPath as NSString).lastPathComponent
    }

    var title: String {
        cachedTitle ?? messages.first(where: { $0.role == .user })?.textContent ?? String(localized: "Untitled session")
    }

    var preview: String? {
        cachedPreview ?? messages.first(where: { $0.role == .assistant })?.textContent
    }

    var turnCount: Int {
        cachedTurnCount ?? messages.filter { $0.role == .user }.count
    }

    nonisolated(unsafe) private static let relativeDateFormatter = RelativeDateTimeFormatter()

    var timeAgo: String {
        Self.relativeDateFormatter.localizedString(for: startedAt, relativeTo: .now)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.id == rhs.id
    }
}
