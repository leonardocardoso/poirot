import Foundation

enum FrontmatterParser {
    struct Result: Sendable {
        let metadata: [String: String]
        let body: String
    }

    nonisolated static func parse(_ content: String) -> Result {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("---") else {
            return Result(metadata: [:], body: content)
        }

        let afterOpening = trimmed.dropFirst(3)
        guard let closeRange = afterOpening.range(of: "\n---") else {
            return Result(metadata: [:], body: content)
        }

        let yamlBlock = String(afterOpening[afterOpening.startIndex ..< closeRange.lowerBound])
        let body = String(afterOpening[closeRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)

        var metadata: [String: String] = [:]
        for line in yamlBlock.components(separatedBy: .newlines) {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            guard !trimmedLine.isEmpty else { continue }
            guard let colonIndex = trimmedLine.firstIndex(of: ":") else { continue }
            let key = String(trimmedLine[trimmedLine.startIndex ..< colonIndex])
                .trimmingCharacters(in: .whitespaces)
            let value = String(trimmedLine[trimmedLine.index(after: colonIndex)...])
                .trimmingCharacters(in: .whitespaces)
            metadata[key] = value
        }

        return Result(metadata: metadata, body: body)
    }
}
