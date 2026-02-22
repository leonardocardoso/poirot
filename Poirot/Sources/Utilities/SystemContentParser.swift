import Foundation

enum SystemContentParser {
    struct Result: Equatable {
        let userText: String
        let systemBlocks: [SystemBlock]
    }

    struct SystemBlock: Equatable, Identifiable {
        let id = UUID()
        let tagName: String
        let content: String

        static func == (lhs: SystemBlock, rhs: SystemBlock) -> Bool {
            lhs.tagName == rhs.tagName && lhs.content == rhs.content
        }
    }

    private static let tagPattern = try? NSRegularExpression(
        pattern: #"<([a-zA-Z][\w-]*)>([\s\S]*?)</\1>"#,
        options: []
    )

    static func parse(_ text: String) -> Result {
        guard let regex = tagPattern else {
            return Result(userText: text, systemBlocks: [])
        }

        let nsText = text as NSString
        let fullRange = NSRange(location: 0, length: nsText.length)
        let matches = regex.matches(in: text, range: fullRange)

        guard !matches.isEmpty else {
            return Result(userText: text, systemBlocks: [])
        }

        var blocks: [SystemBlock] = []
        var userParts: [String] = []
        var lastEnd = 0

        for match in matches {
            let matchRange = match.range
            if matchRange.location > lastEnd {
                let before = nsText.substring(
                    with: NSRange(location: lastEnd, length: matchRange.location - lastEnd)
                )
                let trimmed = before.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    userParts.append(trimmed)
                }
            }

            let tagName = nsText.substring(with: match.range(at: 1))
            let content = nsText.substring(with: match.range(at: 2))
                .trimmingCharacters(in: .whitespacesAndNewlines)

            blocks.append(SystemBlock(tagName: tagName, content: content))
            lastEnd = matchRange.location + matchRange.length
        }

        if lastEnd < nsText.length {
            let after = nsText
                .substring(from: lastEnd)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !after.isEmpty {
                userParts.append(after)
            }
        }

        return Result(
            userText: userParts.joined(separator: "\n\n"),
            systemBlocks: blocks
        )
    }
}
