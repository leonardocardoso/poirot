import Foundation

/// Loads the pre-computed stats cache from `~/.claude/stats-cache.json`.
nonisolated enum StatsCacheLoader {
    private static let defaultPath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.claude/stats-cache.json"
    }()

    /// Loads and decodes the stats cache. Returns `nil` when the file is missing or malformed.
    static func load(from path: String? = nil) -> StatsCache? {
        let filePath = path ?? defaultPath
        let url = URL(fileURLWithPath: filePath)

        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        return try? JSONDecoder().decode(StatsCache.self, from: data)
    }
}
