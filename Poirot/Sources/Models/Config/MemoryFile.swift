import Foundation

nonisolated struct MemoryFile: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let filename: String
    let content: String
    let fileURL: URL
    let projectID: String

    /// Whether this is the main MEMORY.md entrypoint file.
    var isMain: Bool {
        filename.uppercased() == "MEMORY.MD"
    }

    /// A human-readable display name derived from the filename.
    /// e.g. "debugging.md" → "Debugging", "MEMORY.md" → "MEMORY"
    static func displayName(from filename: String) -> String {
        let stem = (filename as NSString).deletingPathExtension
        if stem.uppercased() == "MEMORY" { return "MEMORY" }
        return stem.replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}
