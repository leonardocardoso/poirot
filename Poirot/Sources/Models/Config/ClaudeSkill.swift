import Foundation

struct ClaudeSkill: Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let model: String?
    let allowedTools: String?
    let body: String
    let filePath: String
    let scope: ConfigScope
}
