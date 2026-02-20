import Foundation

nonisolated struct Message: Identifiable, Hashable {
    let id: String
    let role: Role
    let content: [ContentBlock]
    let timestamp: Date
    let model: String?
    let tokenUsage: TokenUsage?

    enum Role: String, Codable {
        case user
        case assistant
        case system
    }

    var textContent: String {
        content
            .compactMap { block in
                if case let .text(text) = block {
                    return text
                }
                return nil
            }
            .joined(separator: "\n")
    }

    var toolBlocks: [ToolUse] {
        content.compactMap { block in
            if case let .toolUse(tool) = block {
                return tool
            }
            return nil
        }
    }
}

nonisolated enum ContentBlock: Hashable {
    case text(String)
    case toolUse(ToolUse)
    case toolResult(ToolResult)
    case thinking(String)
}

nonisolated struct ToolUse: Identifiable, Hashable {
    let id: String
    let name: String
    let input: [String: String]

    var filePath: String? {
        input["file_path"] ?? input["path"] ?? input["command"]
    }
}

nonisolated struct ToolResult: Identifiable, Hashable {
    let id: String
    let toolUseId: String
    let content: String
    let isError: Bool
}

nonisolated struct TokenUsage: Hashable {
    let input: Int
    let output: Int

    var total: Int { input + output }

    var formatted: String {
        let total = Double(total)
        if total >= 1000 {
            return String(format: "%.1fk", total / 1000)
        }
        return "\(self.total)"
    }
}
