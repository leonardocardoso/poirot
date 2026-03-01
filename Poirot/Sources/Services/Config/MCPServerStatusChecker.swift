import Foundation

/// Determines runtime connection status for MCP servers by inspecting
/// local cache files and probing running processes / HTTP endpoints.
enum MCPServerStatusChecker {
    /// Path to Claude's auth-needed cache file.
    nonisolated static var authCacheURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude")
            .appendingPathComponent("mcp-needs-auth-cache.json")
    }

    // MARK: - Bulk Status Resolution

    /// Resolves status for a list of servers, reading the auth cache once.
    nonisolated static func resolveStatuses(
        for servers: [MCPServer]
    ) -> [MCPServer] {
        let authServers = loadAuthCache()
        return servers.map { server in
            var updated = server
            updated.status = status(
                for: server, authServers: authServers
            )
            return updated
        }
    }

    // MARK: - Single Server Status

    /// Determines the status for a single MCP server.
    nonisolated static func status(
        for server: MCPServer,
        authServers: Set<String>? = nil
    ) -> MCPServerStatus {
        let authSet = authServers ?? loadAuthCache()

        // 1. Check auth-needed cache first
        if authSet.contains(server.rawName) {
            return .needsAuth
        }

        // 2. Determine transport-specific status
        if server.url != nil || server.type == "http" || server.type == "sse" {
            return statusForHTTPServer(server)
        }

        if server.command != nil {
            return statusForStdioServer(server)
        }

        return .unknown
    }

    // MARK: - Auth Cache

    /// Loads the set of server names that need authentication.
    nonisolated static func loadAuthCache() -> Set<String> {
        guard let data = try? Data(contentsOf: authCacheURL),
              let dict = try? JSONSerialization.jsonObject(
                  with: data
              ) as? [String: Any]
        else { return [] }
        return Set(dict.keys)
    }

    // MARK: - Transport-Specific Checks

    /// For HTTP/SSE servers, we check if the endpoint URL is well-formed.
    /// A full reachability probe would require async networking, so we
    /// optimistically mark configured HTTP servers as connected when
    /// they have a valid URL and are not in the auth cache.
    nonisolated private static func statusForHTTPServer(
        _ server: MCPServer
    ) -> MCPServerStatus {
        guard let urlString = server.url,
              URL(string: urlString) != nil
        else { return .unreachable }
        return .connected
    }

    /// For STDIO servers, checks if the command process is currently
    /// running by searching the process table.
    nonisolated private static func statusForStdioServer(
        _ server: MCPServer
    ) -> MCPServerStatus {
        guard let command = server.command else {
            return .unknown
        }

        // Extract the executable basename for process matching
        let executable = extractExecutable(from: command)

        if isProcessRunning(named: executable, args: server.args) {
            return .connected
        }

        // The server has a valid command but isn't running;
        // it may be waiting to be started by a Claude session.
        return .unknown
    }

    /// Extracts the basename of the executable from a command string.
    nonisolated private static func extractExecutable(
        from command: String
    ) -> String {
        let url = URL(fileURLWithPath: command)
        return url.lastPathComponent
    }

    /// Checks if a process matching the given name is running.
    nonisolated private static func isProcessRunning(
        named executable: String,
        args: [String]
    ) -> Bool {
        let pipe = Pipe()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
        process.arguments = ["-f", executable]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } catch {
            return false
        }
    }
}
