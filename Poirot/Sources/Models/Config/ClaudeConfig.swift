import Foundation

/// Represents the top-level `~/.claude.json` configuration file.
nonisolated struct ClaudeConfig: Codable, Sendable {
    let mcpServers: [String: MCPServerDefinition]?
    let projects: [String: ProjectConfig]?

    nonisolated struct ProjectConfig: Codable, Sendable {
        let mcpServers: [String: MCPServerDefinition]?
    }
}

/// Represents a `<project>/.mcp.json` file (project-scope, checked into git).
nonisolated struct MCPProjectConfig: Codable, Sendable {
    let mcpServers: [String: MCPServerDefinition]?
}

/// A single MCP server definition with transport and connection details.
nonisolated struct MCPServerDefinition: Codable, Sendable {
    let type: String?
    let command: String?
    let args: [String]?
    let env: [String: String]?
    let url: String?
    let headers: [String: String]?
}
