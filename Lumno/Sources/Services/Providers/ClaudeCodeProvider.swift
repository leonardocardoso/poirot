import SwiftUI

struct ClaudeCodeProvider: ProviderDescribing {
    let name = "Claude Code"
    let assistantName = "Claude"
    let assistantAvatarLetter = "L"
    let statusActiveText = "Claude Code active"
    let companionTagline = "Your Claude Code companion"
    let capabilities: Set<ProviderCapability> = Set(ProviderCapability.allCases)
    let projectsPath = "~/.claude/projects"
    let cliPath = "/usr/local/bin/claude"
    let cliLabel = "Claude Code Path"
    let defaultModelName = "Opus 4"
    let supportedModels = ["Opus 4", "Sonnet 4", "Haiku 3.5"]

    let toolDefinitions: [String: ToolDefinition] = [
        "Read": ToolDefinition(displayName: "Read", icon: "doc.text"),
        "Write": ToolDefinition(displayName: "Write", icon: "doc.text.fill"),
        "Edit": ToolDefinition(displayName: "Edit", icon: "pencil"),
        "Bash": ToolDefinition(displayName: "Bash", icon: "terminal"),
        "Glob": ToolDefinition(displayName: "Glob", icon: "magnifyingglass"),
        "Grep": ToolDefinition(displayName: "Grep", icon: "text.magnifyingglass"),
        "Task": ToolDefinition(displayName: "Task", icon: "checklist"),
    ]

    let configurationItems: [ConfigurationItem] = [
        ConfigurationItem(
            id: "skills",
            icon: "bolt.fill",
            iconColor: LumnoTheme.Colors.accent,
            title: "Skills",
            count: "8 active",
            description: "Custom skills and automation workflows for Claude Code sessions",
            requiredCapability: .skills
        ),
        ConfigurationItem(
            id: "commands",
            icon: "slash.circle",
            iconColor: LumnoTheme.Colors.blue,
            title: "Slash Commands",
            count: "12 available",
            description: "Quick commands for common operations like worktrees, PRs, and tasks",
            requiredCapability: .commands
        ),
        ConfigurationItem(
            id: "mcpServers",
            icon: "powerplug.fill",
            iconColor: LumnoTheme.Colors.green,
            title: "MCP Servers",
            count: "5 connected",
            description: "Connected services — GitHub, Notion, Figma, Sentry, Perplexity",
            requiredCapability: .mcpServers
        ),
        ConfigurationItem(
            id: "models",
            icon: "brain",
            iconColor: LumnoTheme.Colors.purple,
            title: "Models",
            count: "Opus 4",
            description: "Select default model, configure per-project preferences",
            requiredCapability: .models
        ),
        ConfigurationItem(
            id: "subAgents",
            icon: "person.2.fill",
            iconColor: LumnoTheme.Colors.orange,
            title: "Sub-agents",
            count: "4 types",
            description: "Configure Explore, Plan, Bash, and General-purpose agents",
            requiredCapability: .subAgents
        ),
        ConfigurationItem(
            id: "outputStyles",
            icon: "speaker.wave.3.fill",
            iconColor: LumnoTheme.Colors.red,
            title: "Output Styles",
            count: "TTS ready",
            description: "Text-to-speech with ElevenLabs, output formatting, and display options",
            requiredCapability: .outputStyles
        ),
    ]
}
