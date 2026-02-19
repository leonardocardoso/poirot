import Foundation

struct Message: Identifiable, Hashable {
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
        content.compactMap { block in
            if case .text(let text) = block {
                return text
            }
            return nil
        }.joined(separator: "\n")
    }

    var toolBlocks: [ToolUse] {
        content.compactMap { block in
            if case .toolUse(let tool) = block {
                return tool
            }
            return nil
        }
    }
}

enum ContentBlock: Hashable {
    case text(String)
    case toolUse(ToolUse)
    case toolResult(ToolResult)
    case thinking(String)
}

struct ToolUse: Identifiable, Hashable {
    let id: String
    let name: String
    let input: [String: String]

    var filePath: String? {
        input["file_path"] ?? input["path"] ?? input["command"]
    }
}

struct ToolResult: Identifiable, Hashable {
    let id: String
    let toolUseId: String
    let content: String
    let isError: Bool
}

struct TokenUsage: Hashable {
    let input: Int
    let output: Int

    var total: Int { input + output }

    var formatted: String {
        let total = Double(self.total)
        if total >= 1000 {
            return String(format: "%.1fk", total / 1000)
        }
        return "\(self.total)"
    }
}
