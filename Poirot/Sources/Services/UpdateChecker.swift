import Foundation

/// Checks GitHub releases for newer versions of Poirot.
enum UpdateChecker {
    nonisolated private static let owner = "leonardocardoso"
    nonisolated private static let repo = "poirot"

    struct Release: Sendable {
        let tagName: String
        let htmlURL: String
    }

    /// Fetches the latest release from GitHub and compares it to the current app version.
    /// Returns the release info if a newer version is available, nil otherwise.
    nonisolated static func checkForUpdate() async -> Release? {
        guard let url = URL(
            string: "https://api.github.com/repos/\(owner)/\(repo)/releases/latest"
        ) else { return nil }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else { return nil }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tagName = json["tag_name"] as? String,
              let htmlURL = json["html_url"] as? String
        else { return nil }

        let remoteVersion = tagName.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
        let currentVersion = Bundle.main.appVersion

        guard isNewer(remote: remoteVersion, current: currentVersion) else { return nil }

        return Release(tagName: tagName, htmlURL: htmlURL)
    }

    /// Compares semantic version strings. Returns true if remote > current.
    nonisolated static func isNewer(remote: String, current: String) -> Bool {
        let remoteParts = remote.split(separator: ".").compactMap { Int($0) }
        let currentParts = current.split(separator: ".").compactMap { Int($0) }

        for i in 0 ..< max(remoteParts.count, currentParts.count) {
            let r = i < remoteParts.count ? remoteParts[i] : 0
            let c = i < currentParts.count ? currentParts[i] : 0
            if r > c { return true }
            if r < c { return false }
        }
        return false
    }
}
