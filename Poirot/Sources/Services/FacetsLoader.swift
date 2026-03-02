import Foundation

/// Loads AI-generated session facets from `~/.claude/usage-data/facets/`.
///
/// Each file is named `<sessionId>.json` and contains a single `SessionFacets` object.
nonisolated struct FacetsLoader: FacetsLoading {
    let claudeFacetsPath: String

    init(claudeFacetsPath: String? = nil) {
        self.claudeFacetsPath = claudeFacetsPath ?? Self.defaultPath
    }

    /// Returns facets for the given session ID, or nil if not found.
    func loadFacets(for sessionId: String) -> SessionFacets? {
        let fileURL = URL(fileURLWithPath: claudeFacetsPath)
            .appendingPathComponent("\(sessionId).json")

        guard let data = try? Data(contentsOf: fileURL),
              let facets = try? JSONDecoder().decode(SessionFacets.self, from: data)
        else { return nil }

        return facets
    }

    /// Returns all facets keyed by session ID.
    func loadAllFacets() -> [String: SessionFacets] {
        let fm = FileManager.default
        let facetsURL = URL(fileURLWithPath: claudeFacetsPath)

        guard fm.fileExists(atPath: facetsURL.path) else { return [:] }

        guard let contents = try? fm.contentsOfDirectory(
            at: facetsURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return [:] }

        var result: [String: SessionFacets] = [:]
        let decoder = JSONDecoder()

        for fileURL in contents where fileURL.pathExtension == "json" {
            guard let data = try? Data(contentsOf: fileURL),
                  let facets = try? decoder.decode(SessionFacets.self, from: data)
            else { continue }
            result[facets.sessionId] = facets
        }

        return result
    }

    // MARK: - Private

    private static let defaultPath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.claude/usage-data/facets"
    }()
}
