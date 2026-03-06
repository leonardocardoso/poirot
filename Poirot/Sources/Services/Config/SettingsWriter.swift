import Foundation

enum SettingsWriter {
    nonisolated static func settingsFileURL() -> URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude")
            .appendingPathComponent("settings.json")
    }

    nonisolated static func claudeConfigFileURL() -> URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude.json")
    }

    // MARK: - Plugin Toggle

    nonisolated static func togglePlugin(key: String, enabled: Bool) {
        var dict = loadSettingsDict()
        var plugins = dict["enabledPlugins"] as? [String: Bool] ?? [:]
        plugins[key] = enabled
        dict["enabledPlugins"] = plugins
        writeSettingsDict(dict)
    }

    // MARK: - Plugin Removal

    nonisolated static func removePlugin(key: String) {
        var dict = loadSettingsDict()
        var plugins = dict["enabledPlugins"] as? [String: Bool] ?? [:]
        plugins.removeValue(forKey: key)
        dict["enabledPlugins"] = plugins
        writeSettingsDict(dict)
    }

    // MARK: - MCP Permissions Removal

    nonisolated static func removeMCPPermissions(serverName: String) {
        var dict = loadSettingsDict()
        guard var permissions = dict["permissions"] as? [String: Any],
              var allow = permissions["allow"] as? [String]
        else { return }

        let prefix = "mcp__\(serverName)__"
        allow.removeAll { $0.hasPrefix(prefix) }
        permissions["allow"] = allow
        dict["permissions"] = permissions
        writeSettingsDict(dict)
    }

    // MARK: - Default Model

    nonisolated static func setDefaultModel(_ model: String) {
        var dict = loadSettingsDict()
        dict["model"] = model
        writeSettingsDict(dict)
    }

    // MARK: - Project Model

    nonisolated static func setProjectModel(_ model: String?, projectPath: String) {
        let url = URL(fileURLWithPath: projectPath)
            .appendingPathComponent(".claude")
            .appendingPathComponent("settings.json")
        var dict: [String: Any] = [:]
        if let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            dict = json
        }
        if let model {
            dict["model"] = model
        } else {
            dict.removeValue(forKey: "model")
        }
        let dir = URL(fileURLWithPath: projectPath).appendingPathComponent(".claude")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        guard let data = try? JSONSerialization.data(
            withJSONObject: dict,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        ) else { return }
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - Line Number Lookup

    nonisolated static func lineNumber(forMCPServer serverKey: String) -> Int? {
        let url = claudeConfigFileURL()
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        let lines = content.components(separatedBy: .newlines)
        let needle = "\"\(serverKey)\""
        var inTopLevelMCPServers = false
        var braceDepth = 0
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Top-level keys in ~/.claude.json are at indent <= 2
            let indent = line.prefix(while: { $0 == " " || $0 == "\t" }).count
            if trimmed.hasPrefix("\"mcpServers\""), indent <= 2 {
                inTopLevelMCPServers = true
                braceDepth = 0
            }
            if inTopLevelMCPServers {
                braceDepth += trimmed.filter { $0 == "{" }.count
                braceDepth -= trimmed.filter { $0 == "}" }.count
                if trimmed.hasPrefix(needle) {
                    return index + 1
                }
                // Exited the top-level mcpServers block
                if braceDepth <= 0, trimmed.contains("}") {
                    inTopLevelMCPServers = false
                }
            }
        }
        return nil
    }

    // MARK: - MCP Server Definition Removal

    nonisolated static func removeMCPServer(serverName: String) {
        let url = claudeConfigFileURL()
        guard let data = try? Data(contentsOf: url),
              var dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return }

        if var servers = dict["mcpServers"] as? [String: Any] {
            servers.removeValue(forKey: serverName)
            dict["mcpServers"] = servers
        }

        guard let updated = try? JSONSerialization.data(
            withJSONObject: dict,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        ) else { return }
        try? updated.write(to: url, options: .atomic)
    }

    // MARK: - Hook Save

    nonisolated static func saveHook(
        event: HookEvent,
        matcherGroup: HookMatcherGroup,
        existingIndex: Int?,
        scope: ConfigScope,
        projectPath: String? = nil
    ) {
        var dict = loadSettingsDictFor(scope: scope, projectPath: projectPath)
        var hooks = dict["hooks"] as? [String: Any] ?? [:]
        var groups = hooks[event.rawValue] as? [[String: Any]] ?? []

        let serialized = serializeMatcherGroup(matcherGroup)

        if let idx = existingIndex, idx < groups.count {
            groups[idx] = serialized
        } else {
            groups.append(serialized)
        }

        hooks[event.rawValue] = groups
        dict["hooks"] = hooks
        writeSettingsDictFor(dict, scope: scope, projectPath: projectPath)
    }

    // MARK: - Hook Delete

    nonisolated static func deleteHook(
        event: HookEvent,
        matcherIndex: Int,
        scope: ConfigScope,
        projectPath: String? = nil
    ) {
        var dict = loadSettingsDictFor(scope: scope, projectPath: projectPath)
        guard var hooks = dict["hooks"] as? [String: Any],
              var groups = hooks[event.rawValue] as? [[String: Any]],
              matcherIndex < groups.count
        else { return }

        groups.remove(at: matcherIndex)
        if groups.isEmpty {
            hooks.removeValue(forKey: event.rawValue)
        } else {
            hooks[event.rawValue] = groups
        }
        if hooks.isEmpty {
            dict.removeValue(forKey: "hooks")
        } else {
            dict["hooks"] = hooks
        }
        writeSettingsDictFor(dict, scope: scope, projectPath: projectPath)
    }

    // MARK: - Hook Export/Import

    nonisolated static func exportHooksAsJSON(_ entries: [HookEntry]) -> Data? {
        var hooks: [String: Any] = [:]
        for entry in entries {
            var groups = hooks[entry.event.rawValue] as? [[String: Any]] ?? []
            groups.append(serializeMatcherGroup(entry.matcherGroup))
            hooks[entry.event.rawValue] = groups
        }
        let wrapper: [String: Any] = ["hooks": hooks]
        return try? JSONSerialization.data(
            withJSONObject: wrapper,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
    }

    nonisolated static func importHooksFromJSON(
        _ data: Data,
        scope: ConfigScope,
        projectPath: String? = nil
    ) -> Int {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let hooks = json["hooks"] as? [String: [[String: Any]]]
        else { return 0 }

        var dict = loadSettingsDictFor(scope: scope, projectPath: projectPath)
        var existing = dict["hooks"] as? [String: Any] ?? [:]
        var count = 0

        for (eventKey, groups) in hooks {
            var eventGroups = existing[eventKey] as? [[String: Any]] ?? []
            eventGroups.append(contentsOf: groups)
            existing[eventKey] = eventGroups
            count += groups.count
        }

        dict["hooks"] = existing
        writeSettingsDictFor(dict, scope: scope, projectPath: projectPath)
        return count
    }

    // MARK: - Hook Helpers

    nonisolated private static func serializeMatcherGroup(_ group: HookMatcherGroup) -> [String: Any] {
        var result: [String: Any] = [:]
        if let matcher = group.matcher, !matcher.isEmpty {
            result["matcher"] = matcher
        }
        result["hooks"] = group.handlers.map { handler -> [String: Any] in
            var h: [String: Any] = ["type": handler.type.rawValue]
            switch handler.type {
            case .command:
                if let cmd = handler.command { h["command"] = cmd }
            case .http:
                if let url = handler.url { h["url"] = url }
            }
            if let timeout = handler.timeout { h["timeout"] = timeout }
            if let msg = handler.statusMessage { h["statusMessage"] = msg }
            return h
        }
        return result
    }

    nonisolated private static func settingsURL(
        scope: ConfigScope,
        projectPath: String?
    ) -> URL {
        switch scope {
        case .global:
            return settingsFileURL()
        case .project:
            guard let projectPath else { return settingsFileURL() }
            return URL(fileURLWithPath: projectPath)
                .appendingPathComponent(".claude")
                .appendingPathComponent("settings.json")
        }
    }

    nonisolated private static func loadSettingsDictFor(
        scope: ConfigScope,
        projectPath: String?
    ) -> [String: Any] {
        let url = settingsURL(scope: scope, projectPath: projectPath)
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return [:] }
        return json
    }

    nonisolated private static func writeSettingsDictFor(
        _ dict: [String: Any],
        scope: ConfigScope,
        projectPath: String?
    ) {
        let url = settingsURL(scope: scope, projectPath: projectPath)
        let dir = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        guard let data = try? JSONSerialization.data(
            withJSONObject: dict,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        ) else { return }
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - Internal

    nonisolated private static func loadSettingsDict() -> [String: Any] {
        let url = settingsFileURL()
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return [:] }
        return json
    }

    nonisolated private static func writeSettingsDict(_ dict: [String: Any]) {
        let url = settingsFileURL()
        guard let data = try? JSONSerialization.data(
            withJSONObject: dict,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        ) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
