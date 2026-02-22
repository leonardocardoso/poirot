import Foundation

nonisolated struct ClaudeSettings: Codable, Sendable {
    let permissions: Permissions?
    let enabledPlugins: [String: Bool]?

    nonisolated struct Permissions: Codable, Sendable {
        let allow: [String]?
        let deny: [String]?
    }
}
