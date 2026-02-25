import Foundation

enum ClaudeConfigLoader {
    nonisolated private static var claudeDir: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude")
    }

    // MARK: - Commands

    nonisolated static func loadCommands(projectPath: String? = nil) -> [ClaudeCommand] {
        var results = loadCommandsFrom(dir: claudeDir.appendingPathComponent("commands"), scope: .global)

        if let projectPath {
            let projectDir = URL(fileURLWithPath: projectPath)
                .appendingPathComponent(".claude")
                .appendingPathComponent("commands")
            results += loadCommandsFrom(dir: projectDir, scope: .project)
        }

        return results.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    nonisolated private static func loadCommandsFrom(dir: URL, scope: ConfigScope) -> [ClaudeCommand] {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: nil
        ) else { return [] }

        return files
            .filter { $0.pathExtension == "md" }
            .compactMap { url -> ClaudeCommand? in
                guard let content = try? String(contentsOf: url, encoding: .utf8) else { return nil }
                let parsed = FrontmatterParser.parse(content)
                let filename = url.deletingPathExtension().lastPathComponent
                return ClaudeCommand(
                    id: "\(scope.rawValue)-\(filename)",
                    name: "/\(filename)",
                    description: parsed.metadata["description"] ?? "",
                    model: parsed.metadata["model"],
                    argumentHint: parsed.metadata["argument-hint"],
                    allowedTools: parsed.metadata["allowed-tools"],
                    outputStyle: parsed.metadata["output-style"],
                    body: parsed.body,
                    filePath: url.path,
                    scope: scope
                )
            }
    }

    // MARK: - Skills

    nonisolated static func loadSkills(projectPath: String? = nil) -> [ClaudeSkill] {
        var results = loadSkillsFrom(dir: claudeDir.appendingPathComponent("skills"), scope: .global)

        if let projectPath {
            let projectDir = URL(fileURLWithPath: projectPath)
                .appendingPathComponent(".claude")
                .appendingPathComponent("skills")
            results += loadSkillsFrom(dir: projectDir, scope: .project)
        }

        return results.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    nonisolated private static func loadSkillsFrom(dir: URL, scope: ConfigScope) -> [ClaudeSkill] {
        guard let entries = try? FileManager.default.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: [.isDirectoryKey]
        ) else { return [] }

        return entries.compactMap { folder -> ClaudeSkill? in
            let skillFile = folder.appendingPathComponent("SKILL.md")
            guard let content = try? String(contentsOf: skillFile, encoding: .utf8) else { return nil }
            let parsed = FrontmatterParser.parse(content)
            let folderName = folder.lastPathComponent
            return ClaudeSkill(
                id: "\(scope.rawValue)-\(folderName)",
                name: parsed.metadata["name"] ?? folderName,
                description: parsed.metadata["description"] ?? "",
                model: parsed.metadata["model"],
                allowedTools: parsed.metadata["allowed-tools"],
                body: parsed.body,
                filePath: skillFile.path,
                scope: scope
            )
        }
    }

    // MARK: - MCP Servers

    nonisolated private static var claudeConfigURL: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude.json")
    }

    nonisolated static func loadClaudeConfig() -> ClaudeConfig? {
        guard let data = try? Data(contentsOf: claudeConfigURL) else { return nil }
        return try? JSONDecoder().decode(ClaudeConfig.self, from: data)
    }

    nonisolated static func loadMCPServers(projectPath: String? = nil) -> [MCPServer] {
        let config = loadClaudeConfig()
        let toolPermissions = collectToolPermissions()
        var serversByName: [String: MCPServer] = [:]

        // 1. User-scope servers from top-level mcpServers in ~/.claude.json
        if let userServers = config?.mcpServers {
            for (name, definition) in userServers {
                let server = makeServer(
                    name: name,
                    definition: definition,
                    scope: .global,
                    tools: toolPermissions[name]
                )
                serversByName[name] = server
            }
        }

        if let projectPath {
            // 2. Local-scope servers from projects[path].mcpServers in ~/.claude.json
            if let localServers = config?.projects?[projectPath]?.mcpServers {
                for (name, definition) in localServers {
                    let server = makeServer(
                        name: name,
                        definition: definition,
                        scope: .project,
                        tools: toolPermissions[name]
                    )
                    serversByName[name] = server // local overrides user
                }
            }

            // 3. Project-scope servers from <project>/.mcp.json
            let mcpJsonURL = URL(fileURLWithPath: projectPath).appendingPathComponent(".mcp.json")
            if let data = try? Data(contentsOf: mcpJsonURL),
               let mcpConfig = try? JSONDecoder().decode(MCPProjectConfig.self, from: data),
               let projectServers = mcpConfig.mcpServers {
                for (name, definition) in projectServers where serversByName[name] == nil {
                    let server = makeServer(
                        name: name,
                        definition: definition,
                        scope: .project,
                        tools: toolPermissions[name]
                    )
                    serversByName[name] = server
                }
            }
        }

        return serversByName.values
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    nonisolated private static func makeServer(
        name: String,
        definition: MCPServerDefinition,
        scope: ConfigScope,
        tools: [String]?
    ) -> MCPServer {
        MCPServer(
            id: "\(scope.rawValue)-\(name)",
            name: formatServerName(name),
            rawName: name,
            tools: (tools ?? []).sorted(),
            isWildcard: tools == nil,
            scope: scope,
            type: definition.type,
            command: definition.command,
            args: definition.args ?? [],
            env: definition.env ?? [:],
            url: definition.url
        )
    }

    /// Collects tool permissions from settings.json keyed by server name.
    nonisolated private static func collectToolPermissions() -> [String: [String]] {
        guard let allowed = loadSettings()?.permissions?.allow else { return [:] }
        var serverTools: [String: [String]] = [:]
        for entry in allowed {
            guard entry.hasPrefix("mcp__") else { continue }
            let parts = entry.dropFirst(5)
            guard let separatorRange = parts.range(of: "__") else { continue }
            let serverName = String(parts[parts.startIndex ..< separatorRange.lowerBound])
            let toolName = String(parts[separatorRange.upperBound...])
            serverTools[serverName, default: []].append(toolName)
        }
        return serverTools
    }

    // MARK: - Plugins

    nonisolated static func loadPlugins() -> [ClaudePlugin] {
        let installedURL = claudeDir
            .appendingPathComponent("plugins")
            .appendingPathComponent("installed_plugins.json")

        guard let data = try? Data(contentsOf: installedURL),
              let installed = try? JSONDecoder().decode(InstalledPlugins.self, from: data)
        else { return [] }

        let settings = loadSettings()
        let enabled = settings?.enabledPlugins ?? [:]

        return installed.plugins.flatMap { key, versions -> [ClaudePlugin] in
            versions.map { info in
                let parts = key.split(separator: "@", maxSplits: 1)
                let pluginName = parts.first.map(String.init) ?? key
                let author = parts.count > 1 ? String(parts[1]) : ""

                return ClaudePlugin(
                    id: key,
                    name: pluginName,
                    author: author,
                    version: info.version,
                    installedAt: info.installedAt,
                    isEnabled: enabled[key] == true
                )
            }
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    // MARK: - Output Styles

    nonisolated static func loadOutputStyles(projectPath: String? = nil) -> [OutputStyle] {
        var results = loadOutputStylesFrom(dir: claudeDir.appendingPathComponent("output-styles"), scope: .global)

        if let projectPath {
            let projectDir = URL(fileURLWithPath: projectPath)
                .appendingPathComponent(".claude")
                .appendingPathComponent("output-styles")
            results += loadOutputStylesFrom(dir: projectDir, scope: .project)
        }

        return results.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    nonisolated private static func loadOutputStylesFrom(dir: URL, scope: ConfigScope) -> [OutputStyle] {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: nil
        ) else { return [] }

        return files
            .filter { $0.pathExtension == "md" && $0.lastPathComponent != "README.md" }
            .compactMap { url -> OutputStyle? in
                guard let content = try? String(contentsOf: url, encoding: .utf8) else { return nil }
                let parsed = FrontmatterParser.parse(content)
                let filename = url.lastPathComponent
                return OutputStyle(
                    id: "\(scope.rawValue)-\(filename)",
                    name: parsed.metadata["name"] ?? url.deletingPathExtension().lastPathComponent,
                    description: parsed.metadata["description"] ?? "",
                    filename: filename,
                    body: parsed.body,
                    filePath: url.path,
                    scope: scope
                )
            }
    }

    // MARK: - Settings

    nonisolated static func loadSettings() -> ClaudeSettings? {
        let url = claudeDir.appendingPathComponent("settings.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(ClaudeSettings.self, from: data)
    }

    // MARK: - Project Model

    nonisolated static func loadProjectModel(projectPath: String) -> String? {
        let url = URL(fileURLWithPath: projectPath)
            .appendingPathComponent(".claude")
            .appendingPathComponent("settings.json")
        guard let data = try? Data(contentsOf: url),
              let settings = try? JSONDecoder().decode(ClaudeSettings.self, from: data)
        else { return nil }
        return settings.model
    }

    // MARK: - Template Creation

    nonisolated static func createCommandTemplate() -> String? {
        let dir = claudeDir.appendingPathComponent("commands")
        ensureDirectory(dir)
        let url = uniqueFile(in: dir, baseName: "new-command", ext: "md")
        let template = """
        ---
        description: Describe what this command does
        # model: claude-sonnet-4-6
        # allowed-tools: Bash, Read, Write
        # argument-hint: <arg>
        ---

        Your command instructions go here.
        """
        guard (try? template.write(to: url, atomically: true, encoding: .utf8)) != nil else { return nil }
        return url.path
    }

    nonisolated static func createSkillTemplate() -> String? {
        let dir = claudeDir.appendingPathComponent("skills").appendingPathComponent("new-skill")

        // Handle uniqueness by varying the folder name
        var finalDir = dir
        var counter = 2
        while FileManager.default.fileExists(atPath: finalDir.appendingPathComponent("SKILL.md").path) {
            finalDir = claudeDir.appendingPathComponent("skills").appendingPathComponent("new-skill-\(counter)")
            counter += 1
        }
        ensureDirectory(finalDir)

        let url = finalDir.appendingPathComponent("SKILL.md")
        let template = """
        ---
        name: New Skill
        description: Describe what this skill does
        # model: claude-sonnet-4-6
        # allowed-tools: Bash, Read, Write, Edit
        ---

        Your skill instructions go here.
        """
        guard (try? template.write(to: url, atomically: true, encoding: .utf8)) != nil else { return nil }
        return url.path
    }

    nonisolated static func createOutputStyleTemplate() -> String? {
        let dir = claudeDir.appendingPathComponent("output-styles")
        ensureDirectory(dir)
        let url = uniqueFile(in: dir, baseName: "new-style", ext: "md")
        let template = """
        ---
        name: New Style
        description: Describe this output style
        ---

        Define your output formatting instructions here.
        """
        guard (try? template.write(to: url, atomically: true, encoding: .utf8)) != nil else { return nil }
        return url.path
    }

    nonisolated static func deleteConfigFile(at path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        // For skills, remove the parent directory if it's a SKILL.md
        if url.lastPathComponent == "SKILL.md" {
            return (try? FileManager.default.removeItem(at: url.deletingLastPathComponent())) != nil
        }
        return (try? FileManager.default.removeItem(at: url)) != nil
    }

    // MARK: - Helpers

    nonisolated private static func ensureDirectory(_ url: URL) {
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    nonisolated private static func uniqueFile(in dir: URL, baseName: String, ext: String) -> URL {
        var url = dir.appendingPathComponent("\(baseName).\(ext)")
        var counter = 2
        while FileManager.default.fileExists(atPath: url.path) {
            url = dir.appendingPathComponent("\(baseName)-\(counter).\(ext)")
            counter += 1
        }
        return url
    }

    nonisolated private static func formatServerName(_ raw: String) -> String {
        raw.replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}

// MARK: - Installed Plugins JSON Model

nonisolated private struct InstalledPlugins: Codable, Sendable {
    let plugins: [String: [PluginInfo]]

    nonisolated struct PluginInfo: Codable, Sendable {
        let version: String
        let installedAt: String
    }
}
