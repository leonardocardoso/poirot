import Foundation

struct ClaudeCommand: Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let model: String?
    let argumentHint: String?
    let allowedTools: String?
    let outputStyle: String?
    let body: String
    let filePath: String
    let scope: ConfigScope
}
