import Foundation

struct ClaudePlugin: Identifiable, Sendable {
    let id: String
    let name: String
    let author: String
    let version: String
    let installedAt: String
    let isEnabled: Bool
}
