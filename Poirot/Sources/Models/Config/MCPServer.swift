import Foundation

struct MCPServer: Identifiable, Sendable {
    let id: String
    let name: String
    let tools: [String]
    let isWildcard: Bool
}
