@testable import Poirot
import Foundation
import Testing

@Suite("ClaudeConfigLoader MCP Servers")
struct ClaudeConfigLoaderMCPTests {
    // MARK: - ClaudeConfig Decoding

    @Test
    func decodeClaudeConfig_userScopeServers() throws {
        let json = """
        {
            "mcpServers": {
                "github": {
                    "type": "stdio",
                    "command": "npx",
                    "args": ["-y", "@modelcontextprotocol/server-github"]
                },
                "perplexity": {
                    "type": "http",
                    "url": "https://mcp.perplexity.ai",
                    "headers": { "Authorization": "Bearer token" }
                }
            }
        }
        """
        let data = Data(json.utf8)
        let config = try JSONDecoder().decode(ClaudeConfig.self, from: data)

        #expect(config.mcpServers?.count == 2)

        let github = try #require(config.mcpServers?["github"])
        #expect(github.type == "stdio")
        #expect(github.command == "npx")
        #expect(github.args == ["-y", "@modelcontextprotocol/server-github"])
        #expect(github.url == nil)

        let perplexity = try #require(config.mcpServers?["perplexity"])
        #expect(perplexity.type == "http")
        #expect(perplexity.url == "https://mcp.perplexity.ai")
        #expect(perplexity.command == nil)
        #expect(perplexity.headers?["Authorization"] == "Bearer token")
    }

    @Test
    func decodeClaudeConfig_localScopeServers() throws {
        let json = """
        {
            "projects": {
                "/Users/dev/my-project": {
                    "mcpServers": {
                        "local-db": {
                            "type": "stdio",
                            "command": "node",
                            "args": ["db-server.js"],
                            "env": { "DB_PATH": "/tmp/dev.db" }
                        }
                    }
                }
            }
        }
        """
        let data = Data(json.utf8)
        let config = try JSONDecoder().decode(ClaudeConfig.self, from: data)

        let project = try #require(config.projects?["/Users/dev/my-project"])
        let server = try #require(project.mcpServers?["local-db"])
        #expect(server.type == "stdio")
        #expect(server.command == "node")
        #expect(server.env?["DB_PATH"] == "/tmp/dev.db")
    }

    // MARK: - MCPProjectConfig Decoding

    @Test
    func decodeMCPProjectConfig() throws {
        let json = """
        {
            "mcpServers": {
                "team-tool": {
                    "type": "http",
                    "url": "http://localhost:3000/mcp"
                }
            }
        }
        """
        let data = Data(json.utf8)
        let config = try JSONDecoder().decode(MCPProjectConfig.self, from: data)

        let server = try #require(config.mcpServers?["team-tool"])
        #expect(server.type == "http")
        #expect(server.url == "http://localhost:3000/mcp")
    }

    // MARK: - Graceful Handling

    @Test
    func decodeClaudeConfig_emptyObject() throws {
        let json = "{}"
        let data = Data(json.utf8)
        let config = try JSONDecoder().decode(ClaudeConfig.self, from: data)
        #expect(config.mcpServers == nil)
        #expect(config.projects == nil)
    }

    @Test
    func decodeMCPServerDefinition_minimalFields() throws {
        let json = """
        { "type": "stdio" }
        """
        let data = Data(json.utf8)
        let def = try JSONDecoder().decode(MCPServerDefinition.self, from: data)
        #expect(def.type == "stdio")
        #expect(def.command == nil)
        #expect(def.args == nil)
        #expect(def.env == nil)
        #expect(def.url == nil)
        #expect(def.headers == nil)
    }

    @Test
    func decodeMCPServerDefinition_allFields() throws {
        let json = """
        {
            "type": "stdio",
            "command": "/usr/bin/python3",
            "args": ["-m", "server"],
            "env": { "API_KEY": "secret" },
            "url": "http://fallback.local",
            "headers": { "X-Custom": "value" }
        }
        """
        let data = Data(json.utf8)
        let def = try JSONDecoder().decode(MCPServerDefinition.self, from: data)
        #expect(def.type == "stdio")
        #expect(def.command == "/usr/bin/python3")
        #expect(def.args == ["-m", "server"])
        #expect(def.env?["API_KEY"] == "secret")
        #expect(def.url == "http://fallback.local")
        #expect(def.headers?["X-Custom"] == "value")
    }

    // MARK: - MCPServer Model

    @Test
    func mcpServerModel_newFields() {
        let server = MCPServer(
            id: "global-test",
            name: "Test Server",
            rawName: "test",
            tools: ["read", "write"],
            isWildcard: false,
            scope: .global,
            source: .user,
            type: "stdio",
            command: "node",
            args: ["server.js", "--port", "3000"],
            env: ["NODE_ENV": "production"],
            url: nil
        )

        #expect(server.type == "stdio")
        #expect(server.command == "node")
        #expect(server.args == ["server.js", "--port", "3000"])
        #expect(server.env["NODE_ENV"] == "production")
        #expect(server.url == nil)
    }

    @Test
    func mcpServerModel_httpType() {
        let server = MCPServer(
            id: "global-api",
            name: "API Server",
            rawName: "api",
            tools: [],
            isWildcard: true,
            scope: .project,
            source: .user,
            type: "http",
            command: nil,
            args: [],
            env: [:],
            url: "https://api.example.com/mcp"
        )

        #expect(server.type == "http")
        #expect(server.command == nil)
        #expect(server.url == "https://api.example.com/mcp")
        #expect(server.scope == .project)
    }
}
