import Foundation

/// Runtime connection status for an MCP server.
enum MCPServerStatus: String, Sendable, CaseIterable {
    /// Server is running and responsive.
    case connected
    /// Server requires authentication or re-authentication.
    case needsAuth
    /// Server failed to start or crashed.
    case failed
    /// Server is configured but not responding.
    case unreachable
    /// Server is in the process of connecting.
    case starting
    /// Status cannot be determined.
    case unknown
}

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
    var status: MCPServerStatus = .unknown
}
