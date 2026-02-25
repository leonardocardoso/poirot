import Foundation

struct MCPServer: Identifiable, Sendable {
    let id: String
    let name: String
    let rawName: String
    let tools: [String]
    let isWildcard: Bool
    let scope: ConfigScope
    let type: String?
    let command: String?
    let args: [String]
    let env: [String: String]
    let url: String?
}
