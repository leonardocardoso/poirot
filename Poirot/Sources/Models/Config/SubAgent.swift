import Foundation

struct SubAgent: Identifiable, Sendable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let tools: [String]

    static let builtIn: [SubAgent] = [
        SubAgent(
            id: "explore",
            name: "Explore",
            icon: "magnifyingglass",
            description: "Fast agent for codebase exploration — find files, search code, answer structural questions",
            tools: ["Glob", "Grep", "Read", "Bash"]
        ),
        SubAgent(
            id: "plan",
            name: "Plan",
            icon: "map",
            description: "Software architect for designing implementation plans and identifying critical files",
            tools: ["Glob", "Grep", "Read", "Bash"]
        ),
        SubAgent(
            id: "bash",
            name: "Bash",
            icon: "terminal",
            description: "Command execution specialist for running shell commands, git operations, and builds",
            tools: ["Bash"]
        ),
        SubAgent(
            id: "general",
            name: "General-purpose",
            icon: "person.fill",
            description: "General-purpose agent for researching questions, searching code, and multi-step tasks",
            tools: ["Glob", "Grep", "Read", "Write", "Edit", "Bash"]
        ),
    ]
}
