import Foundation

// MARK: - Agent Scope

enum AgentScope: String, Sendable {
    case builtIn
    case global
}

// MARK: - Agent Color

enum AgentColor: String, CaseIterable, Sendable {
    case orange
    case red
    case blue
    case green
    case purple
    case teal

    var label: String {
        rawValue.capitalized
    }
}

// MARK: - Agent Memory

enum AgentMemory: String, CaseIterable, Sendable {
    case user
    case none

    var label: String {
        switch self {
        case .user: "Enable (~/.claude/agent-memory/)"
        case .none: "None (no persistent memory)"
        }
    }
}

// MARK: - Tool Category

struct ToolCategory: Identifiable, Sendable {
    let id: String
    let name: String
    let tools: [String]
}

// MARK: - Sub-Agent

struct SubAgent: Identifiable, Sendable {
    let id: String
    var name: String
    var icon: String
    var description: String
    var tools: [String]
    var model: String?
    var color: AgentColor?
    var prompt: String?
    var filePath: String?
    var memory: AgentMemory?
    let scope: AgentScope

    var isBuiltIn: Bool { scope == .builtIn }

    nonisolated static let knownTools: [String] = [
        "Agent", "AskUserQuestion", "Bash", "Edit", "Glob", "Grep",
        "NotebookEdit", "Read", "TodoWrite", "WebFetch", "WebSearch", "Write",
    ]

    nonisolated static let toolCategories: [ToolCategory] = [
        ToolCategory(id: "readonly", name: "Read-only tools", tools: ["Glob", "Grep", "Read", "WebFetch", "WebSearch"]),
        ToolCategory(id: "edit", name: "Edit tools", tools: ["Edit", "Write", "NotebookEdit"]),
        ToolCategory(id: "execution", name: "Execution tools", tools: ["Bash", "Agent"]),
        ToolCategory(id: "other", name: "Other tools", tools: ["AskUserQuestion", "TodoWrite"]),
    ]

    nonisolated static let builtIn: [SubAgent] = [
        SubAgent(
            id: "explore",
            name: "Explore",
            icon: "magnifyingglass",
            description: "Fast agent for codebase exploration — find files, search code, answer structural questions",
            tools: ["Glob", "Grep", "Read", "Bash"],
            scope: .builtIn
        ),
        SubAgent(
            id: "plan",
            name: "Plan",
            icon: "map",
            description: "Software architect for designing implementation plans and identifying critical files",
            tools: ["Glob", "Grep", "Read", "Bash"],
            scope: .builtIn
        ),
        SubAgent(
            id: "bash",
            name: "Bash",
            icon: "terminal",
            description: "Command execution specialist for running shell commands, git operations, and builds",
            tools: ["Bash"],
            scope: .builtIn
        ),
        SubAgent(
            id: "general",
            name: "General-purpose",
            icon: "person.fill",
            description: "General-purpose agent for researching questions, searching code, and multi-step tasks",
            tools: ["Glob", "Grep", "Read", "Write", "Edit", "Bash"],
            scope: .builtIn
        ),
    ]
}
