import Foundation

enum SettingsWriter {
    nonisolated static func settingsFileURL() -> URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude")
            .appendingPathComponent("settings.json")
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
        let url = settingsFileURL()
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        let lines = content.components(separatedBy: .newlines)
        // Look for `"serverKey":` inside the mcpServers block
        let needle = "\"\(serverKey)\""
        var inMCPServers = false
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("\"mcpServers\"") {
                inMCPServers = true
            }
            if inMCPServers, trimmed.hasPrefix(needle) {
                return index + 1 // 1-based line number
            }
        }
        return nil
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
