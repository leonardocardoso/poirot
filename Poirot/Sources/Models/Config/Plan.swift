import Foundation

struct Plan: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let content: String
    let fileURL: URL

    /// Derives a human-readable name from a slug filename.
    /// e.g. "abstract-wobbling-mccarthy" → "Abstract Wobbling Mccarthy"
    nonisolated static func humanize(slug: String) -> String {
        slug.replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}
