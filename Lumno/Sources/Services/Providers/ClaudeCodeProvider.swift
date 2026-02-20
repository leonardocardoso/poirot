import SwiftUI

struct ClaudeCodeProvider: ProviderDescribing {
    let name = String(localized: "Claude Code")
    let assistantName = String(localized: "Claude")
    let assistantAvatarLetter = "L"
    let statusActiveText = String(localized: "Claude Code active")
    let companionTagline = String(localized: "Your Claude Code companion")
    let capabilities: Set<ProviderCapability> = Set(ProviderCapability.allCases)
    let projectsPath = "~/.claude/projects"
    let cliPath = "/usr/local/bin/claude"
    let cliLabel = String(localized: "Claude Code Path")
    let defaultModelName = "Opus 4"
    let supportedModels = ["Opus 4", "Sonnet 4", "Haiku 3.5"]

    let toolDefinitions: [String: ToolDefinition] = [
        "Read": ToolDefinition(displayName: String(localized: "Read"), icon: "doc.text"),
        "Write": ToolDefinition(displayName: String(localized: "Write"), icon: "doc.text.fill"),
        "Edit": ToolDefinition(displayName: String(localized: "Edit"), icon: "pencil"),
        "Bash": ToolDefinition(displayName: String(localized: "Bash"), icon: "terminal"),
        "Glob": ToolDefinition(displayName: String(localized: "Glob"), icon: "magnifyingglass"),
        "Grep": ToolDefinition(displayName: String(localized: "Grep"), icon: "text.magnifyingglass"),
        "Task": ToolDefinition(displayName: String(localized: "Task"), icon: "checklist"),
    ]

    let configurationItems: [ConfigurationItem] = [
        ConfigurationItem(
            id: "skills",
            icon: "bolt.fill",
            iconColor: LumnoTheme.Colors.accent,
            title: String(localized: "Skills"),
            count: String(localized: "8 active"),
            description: String(localized: "Custom skills and automation workflows for Claude Code sessions"),
            requiredCapability: .skills
        ),
        ConfigurationItem(
            id: "commands",
            icon: "slash.circle",
            iconColor: LumnoTheme.Colors.blue,
            title: String(localized: "Slash Commands"),
            count: String(localized: "12 available"),
            description: String(localized: "Quick commands for common operations like worktrees, PRs, and tasks"),
            requiredCapability: .commands
        ),
        ConfigurationItem(
            id: "mcpServers",
            icon: "powerplug.fill",
            iconColor: LumnoTheme.Colors.green,
            title: String(localized: "MCP Servers"),
            count: String(localized: "5 connected"),
            description: String(localized: "Connected services — GitHub, Notion, Figma, Sentry, Perplexity"),
            requiredCapability: .mcpServers
        ),
        ConfigurationItem(
            id: "models",
            icon: "brain",
            iconColor: LumnoTheme.Colors.purple,
            title: String(localized: "Models"),
            count: "Opus 4",
            description: String(localized: "Select default model, configure per-project preferences"),
            requiredCapability: .models
        ),
        ConfigurationItem(
            id: "subAgents",
            icon: "person.2.fill",
            iconColor: LumnoTheme.Colors.orange,
            title: String(localized: "Sub-agents"),
            count: String(localized: "4 types"),
            description: String(localized: "Configure Explore, Plan, Bash, and General-purpose agents"),
            requiredCapability: .subAgents
        ),
        ConfigurationItem(
            id: "outputStyles",
            icon: "speaker.wave.3.fill",
            iconColor: LumnoTheme.Colors.red,
            title: String(localized: "Output Styles"),
            count: String(localized: "TTS ready"),
            description: String(localized: "Text-to-speech with ElevenLabs, output formatting, and display options"),
            requiredCapability: .outputStyles
        ),
    ]
}
