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
        var currentBlockKey: String?
        var blockLines: [String] = []
        var blockIsFolded = true

        let lines = yamlBlock.components(separatedBy: .newlines)
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // Continuation line for a block scalar (indented under `>` or `|`)
            if currentBlockKey != nil, !trimmedLine.isEmpty,
               line.first?.isWhitespace == true, !trimmedLine.contains(":") || line.hasPrefix("  ") {
                blockLines.append(trimmedLine)
                continue
            }

            // Flush any pending block scalar
            if let key = currentBlockKey {
                let separator = blockIsFolded ? " " : "\n"
                metadata[key] = blockLines.joined(separator: separator)
                currentBlockKey = nil
                blockLines = []
            }

            guard !trimmedLine.isEmpty else { continue }
            guard let colonIndex = trimmedLine.firstIndex(of: ":") else { continue }
            let key = String(trimmedLine[trimmedLine.startIndex ..< colonIndex])
                .trimmingCharacters(in: .whitespaces)
            let value = String(trimmedLine[trimmedLine.index(after: colonIndex)...])
                .trimmingCharacters(in: .whitespaces)

            // Start a block scalar
            if value == ">" || value == "|" {
                currentBlockKey = key
                blockIsFolded = value == ">"
                blockLines = []
            } else {
                metadata[key] = value
            }
        }

        // Flush trailing block scalar
        if let key = currentBlockKey {
            let separator = blockIsFolded ? " " : "\n"
            metadata[key] = blockLines.joined(separator: separator)
        }

        return Result(metadata: metadata, body: body)
    }
}
