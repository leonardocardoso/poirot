import Foundation

/// A single todo item from a Claude Code session todo list.
/// Files live at `~/.claude/todos/<sessionId>-agent-<agentId>.json`.
nonisolated struct SessionTodo: Codable, Identifiable, Hashable {
    /// Synthesized from content hash — the on-disk format has no `id`.
    var id: Int { content.hashValue }

    let content: String
    let status: Status
    let activeForm: String

    enum Status: String, Codable, Hashable {
        case completed
        case inProgress = "in_progress"
        case pending
    }
}
