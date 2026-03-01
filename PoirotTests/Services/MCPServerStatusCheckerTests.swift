@testable import Poirot
import Foundation
import Testing

@Suite("MCPServerStatusChecker")
struct MCPServerStatusCheckerTests {
    // MARK: - Helpers

    private func makeServer(
        name: String = "test",
        type: String? = nil,
        command: String? = nil,
        args: [String] = [],
        url: String? = nil,
        source: MCPServerSource = .user,
        status: MCPServerStatus = .unknown
    ) -> MCPServer {
        MCPServer(
            id: "global-\(name)",
            name: name.capitalized,
            rawName: name,
            tools: [],
            isWildcard: false,
            scope: .global,
            source: source,
            type: type,
            command: command,
            args: args,
            env: [:],
            url: url,
            status: status
        )
    }

    // MARK: - Auth Cache Detection

    @Test("Server in auth cache returns needsAuth status")
    func authCacheDetection() {
        let server = makeServer(name: "sentry", type: "http", url: "https://sentry.io/mcp")
        let authServers: Set<String> = ["sentry", "github"]
        let result = MCPServerStatusChecker.status(
            for: server, authServers: authServers
        )
        #expect(result == .needsAuth)
    }

    @Test("Server not in auth cache is not marked needsAuth")
    func serverNotInAuthCache() {
        let server = makeServer(name: "myserver", type: "http", url: "https://example.com/mcp")
        let authServers: Set<String> = ["sentry", "github"]
        let result = MCPServerStatusChecker.status(
            for: server, authServers: authServers
        )
        #expect(result != .needsAuth)
    }

    // MARK: - HTTP Server Status

    @Test("HTTP server with valid URL shows connected")
    func httpServerConnected() {
        let server = makeServer(
            name: "api",
            type: "http",
            url: "https://api.example.com/mcp"
        )
        let result = MCPServerStatusChecker.status(
            for: server, authServers: []
        )
        #expect(result == .connected)
    }

    @Test("HTTP server with no URL shows unreachable")
    func httpServerNoURL() {
        let server = makeServer(name: "broken-http", type: "http")
        let result = MCPServerStatusChecker.status(
            for: server, authServers: []
        )
        #expect(result == .unreachable)
    }

    @Test("SSE server with valid URL shows connected")
    func sseServerConnected() {
        let server = makeServer(
            name: "stream",
            type: "sse",
            url: "https://stream.example.com/events"
        )
        let result = MCPServerStatusChecker.status(
            for: server, authServers: []
        )
        #expect(result == .connected)
    }

    @Test("Server with url field inferred as HTTP")
    func urlInferredHTTP() {
        let server = makeServer(
            name: "notion",
            url: "https://mcp.notion.com/mcp"
        )
        let result = MCPServerStatusChecker.status(
            for: server, authServers: []
        )
        #expect(result == .connected)
    }

    // MARK: - STDIO Server Status

    @Test("STDIO server with no command returns unknown")
    func stdioNoCommand() {
        let server = makeServer(name: "empty", type: "stdio")
        let result = MCPServerStatusChecker.status(
            for: server, authServers: []
        )
        #expect(result == .unknown)
    }

    // MARK: - No Transport Info

    @Test("Server with no type/command/url returns unknown")
    func noTransportInfo() {
        let server = makeServer(name: "mystery")
        let result = MCPServerStatusChecker.status(
            for: server, authServers: []
        )
        #expect(result == .unknown)
    }

    // MARK: - Bulk Resolution

    @Test("resolveStatuses updates all servers")
    func bulkResolution() {
        let servers = [
            makeServer(
                name: "http-ok",
                type: "http",
                url: "https://example.com/mcp"
            ),
            makeServer(name: "unknown-server"),
            makeServer(
                name: "auth-needed",
                type: "http",
                url: "https://auth.example.com/mcp"
            ),
        ]

        // Simulate auth cache containing "auth-needed"
        let resolved = servers.map { server -> MCPServer in
            var updated = server
            let authServers: Set<String> = ["auth-needed"]
            updated.status = MCPServerStatusChecker.status(
                for: server, authServers: authServers
            )
            return updated
        }

        #expect(resolved[0].status == .connected)
        #expect(resolved[1].status == .unknown)
        #expect(resolved[2].status == .needsAuth)
    }

    // MARK: - Auth Cache Precedence

    @Test("Auth cache takes precedence over HTTP connected")
    func authCachePrecedence() {
        let server = makeServer(
            name: "github",
            type: "http",
            url: "https://api.github.com/mcp"
        )
        let authServers: Set<String> = ["github"]
        let result = MCPServerStatusChecker.status(
            for: server, authServers: authServers
        )
        #expect(result == .needsAuth)
    }

    @Test("Auth cache takes precedence over STDIO")
    func authCachePrecedenceStdio() {
        let server = makeServer(
            name: "my-stdio",
            type: "stdio",
            command: "node",
            args: ["server.js"]
        )
        let authServers: Set<String> = ["my-stdio"]
        let result = MCPServerStatusChecker.status(
            for: server, authServers: authServers
        )
        #expect(result == .needsAuth)
    }

    // MARK: - Cloud Integration Status

    @Test("Cloud integration server preserves its pre-set status")
    func cloudIntegrationPreservesStatus() {
        let server = makeServer(
            name: "claude.ai Gmail",
            source: .cloudIntegration,
            status: .needsAuth
        )
        let result = MCPServerStatusChecker.status(
            for: server, authServers: []
        )
        #expect(result == .needsAuth)
    }

    @Test("Cloud integration server ignores auth cache lookup")
    func cloudIntegrationIgnoresAuthCache() {
        let server = makeServer(
            name: "claude.ai Gmail",
            source: .cloudIntegration,
            status: .needsAuth
        )
        // Even with a different auth cache, cloud servers keep their pre-set status
        let result = MCPServerStatusChecker.status(
            for: server, authServers: ["some-other-server"]
        )
        #expect(result == .needsAuth)
    }

    // MARK: - Plugin Server Status

    @Test("Plugin server with no running process returns unknown")
    func pluginServerNoProcess() {
        let server = makeServer(
            name: "plugin:nonexistent-plugin:nonexistent-plugin",
            source: .plugin
        )
        let result = MCPServerStatusChecker.status(
            for: server, authServers: []
        )
        #expect(result == .unknown)
    }
}
