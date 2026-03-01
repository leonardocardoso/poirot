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
    /// Uses a heuristic: if any STDIO server is connected, Claude Code has
    /// an active session, so any STDIO server that isn't running has failed.
    nonisolated static func resolveStatuses(
        for servers: [MCPServer]
    ) -> [MCPServer] {
        let authServers = loadAuthCache()
        var resolved = servers.map { server in
            var updated = server
            updated.status = status(
                for: server, authServers: authServers
            )
            return updated
        }

        // If any STDIO user server is connected, Claude Code started them all.
        // Any STDIO server still showing .unknown likely failed to start.
        let hasActiveSession = resolved.contains {
            $0.source == .user && $0.command != nil && $0.status == .connected
        }
        if hasActiveSession {
            resolved = resolved.map { server in
                guard server.source == .user,
                      server.command != nil,
                      server.status == .unknown
                else { return server }
                var updated = server
                updated.status = .failed
                return updated
            }
        }

        return resolved
    }

    // MARK: - Single Server Status

    /// Determines the status for a single MCP server.
    nonisolated static func status(
        for server: MCPServer,
        authServers: Set<String>? = nil
    ) -> MCPServerStatus {
        // Cloud integration servers already have their status set during loading
        if server.source == .cloudIntegration {
            return server.status
        }

        let authSet = authServers ?? loadAuthCache()

        // 1. Check auth-needed cache first
        if authSet.contains(server.rawName) {
            return .needsAuth
        }

        // 2. Plugin servers: check if process is running via tool name
        if server.source == .plugin {
            return statusForPluginServer(server)
        }

        // 3. Determine transport-specific status
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

    /// For plugin servers, checks if the plugin's MCP process is running
    /// by searching for the plugin name in the process table.
    nonisolated private static func statusForPluginServer(
        _ server: MCPServer
    ) -> MCPServerStatus {
        // Plugin raw names are like "plugin:context-mode:context-mode"
        // Search for the plugin name in running processes
        let parts = server.rawName.split(separator: ":")
        guard parts.count >= 2 else { return .unknown }
        let pluginName = String(parts[1])

        if isProcessRunning(pattern: pluginName) {
            return .connected
        }
        return .unknown
    }

    /// For STDIO servers, checks if the command process is currently
    /// running by searching the process table.
    nonisolated private static func statusForStdioServer(
        _ server: MCPServer
    ) -> MCPServerStatus {
        guard let command = server.command else {
            return .unknown
        }

        // Build the full command line pattern for precise matching.
        // e.g. "npx" + ["-y", "perplexity-mcp"] → "npx.*-y.*perplexity-mcp"
        let pattern = buildProcessPattern(command: command, args: server.args)

        if isProcessRunning(pattern: pattern) {
            return .connected
        }

        // The server has a valid command but isn't running;
        // it may be waiting to be started by a Claude session.
        return .unknown
    }

    /// Builds a regex pattern for pgrep -f that matches the specific
    /// command with its arguments, avoiding false positives from
    /// other processes using the same executable.
    ///
    /// For package runners (npx/uvx), the actual process often appears
    /// as `node /path/.npm/_npx/.../node_modules/.bin/<binary>` rather
    /// than `npx @scope/package`. We extract the package's binary name
    /// to match against the resolved process.
    nonisolated private static func buildProcessPattern(
        command: String,
        args: [String]
    ) -> String {
        let executable = URL(fileURLWithPath: command).lastPathComponent
        let isPackageRunner = executable == "npx" || executable == "uvx"

        guard !args.isEmpty else { return executable }

        // Find the main package/binary argument (not a flag)
        let packageArg = args.first { !$0.hasPrefix("-") }

        guard let package = packageArg else {
            return executable
        }

        if isPackageRunner {
            // For npx/uvx, extract the binary name from the package reference.
            // "@modelcontextprotocol/server-filesystem" → "server-filesystem"
            // "@playwright/mcp@latest" → "playwright-mcp" (via pgrep for scope/name)
            // "@railway/mcp-server" → "railway-mcp-server"
            // "perplexity-mcp" → "perplexity-mcp"

            // Strip version suffix: "@playwright/mcp@latest" → "@playwright/mcp"
            var cleaned = package
            if let scopeEnd = package.firstIndex(of: "/") {
                // Scoped package: only strip @ after the scope
                let afterScope = package[package.index(after: scopeEnd)...]
                if let versionAt = afterScope.firstIndex(of: "@") {
                    cleaned = String(package[...package.index(before: versionAt)])
                }
            } else if let versionAt = package.firstIndex(of: "@") {
                cleaned = String(package[..<versionAt])
            }

            // For scoped packages (@scope/name), combine scope+name for unique matching.
            // The resolved npx binary path includes the scope:
            //   node /.../_npx/.../node_modules/.bin/mcp-server-filesystem
            // And pgrep also matches against the full path which includes the scope.
            if cleaned.hasPrefix("@"), let slashIndex = cleaned.firstIndex(of: "/") {
                let scope = cleaned[cleaned.index(after: cleaned.startIndex) ..< slashIndex]
                let name = cleaned[cleaned.index(after: slashIndex)...]
                return "\(scope).*\(name)"
            }

            // For non-scoped packages, include the runner to avoid cross-matching.
            // e.g. npx's "perplexity-mcp" vs uvx's "perplexity-mcp"
            return "\(executable).*\(cleaned)"
        }

        // For other commands, match executable + significant args
        let significantArgs = args.filter { !$0.hasPrefix("-") }
        let parts = [executable] + (significantArgs.isEmpty ? args : significantArgs)
        return parts.joined(separator: ".*")
    }

    /// Checks if a process matching the given pattern is running.
    nonisolated private static func isProcessRunning(
        pattern: String
    ) -> Bool {
        let pipe = Pipe()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
        process.arguments = ["-f", pattern]
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
