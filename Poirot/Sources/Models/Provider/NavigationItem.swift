import Foundation

struct NavigationItem: Identifiable, Hashable, Sendable {
    enum Section: Hashable, Sendable {
        case main
        case config
    }

    let id: String
    let title: String
    let systemImage: String
    let requiredCapability: ProviderCapability?
    let section: Section

    static let sessions = NavigationItem(
        id: "sessions",
        title: String(localized: "Sessions"),
        systemImage: "rectangle.stack.fill",
        requiredCapability: nil,
        section: .main
    )
    static let todos = NavigationItem(
        id: "todos",
        title: String(localized: "TODOs"),
        systemImage: "checklist",
        requiredCapability: nil,
        section: .config
    )
    static let commands = NavigationItem(
        id: "commands",
        title: String(localized: "Commands"),
        systemImage: "apple.terminal.fill",
        requiredCapability: .commands,
        section: .config
    )
    static let skills = NavigationItem(
        id: "skills",
        title: String(localized: "Skills"),
        systemImage: "bolt.fill",
        requiredCapability: .skills,
        section: .config
    )
    static let plans = NavigationItem(
        id: "plans",
        title: String(localized: "Plans"),
        systemImage: "list.bullet.clipboard.fill",
        requiredCapability: .plans,
        section: .config
    )
    static let mcpServers = NavigationItem(
        id: "mcpServers",
        title: String(localized: "MCP Servers"),
        systemImage: "powerplug.fill",
        requiredCapability: .mcpServers,
        section: .config
    )
    static let models = NavigationItem(
        id: "models",
        title: String(localized: "Models"),
        systemImage: "brain.fill",
        requiredCapability: .models,
        section: .config
    )
    static let subAgents = NavigationItem(
        id: "subAgents",
        title: String(localized: "Sub-agents"),
        systemImage: "person.2.fill",
        requiredCapability: .subAgents,
        section: .config
    )
    static let hooks = NavigationItem(
        id: "hooks",
        title: String(localized: "Hooks"),
        systemImage: "arrow.triangle.branch",
        requiredCapability: .hooks,
        section: .config
    )
    static let plugins = NavigationItem(
        id: "plugins",
        title: String(localized: "Plugins"),
        systemImage: "puzzlepiece.fill",
        requiredCapability: .plugins,
        section: .config
    )
    static let outputStyles = NavigationItem(
        id: "outputStyles",
        title: String(localized: "Output Styles"),
        systemImage: "speaker.wave.3.fill",
        requiredCapability: .outputStyles,
        section: .config
    )
    static let memory = NavigationItem(
        id: "memory",
        title: String(localized: "Memory"),
        systemImage: "brain.head.profile.fill",
        requiredCapability: .memory,
        section: .config
    )
    static let analytics = NavigationItem(
        id: "analytics",
        title: String(localized: "Analytics"),
        systemImage: "chart.xyaxis.line",
        requiredCapability: nil,
        section: .config
    )
    static let history = NavigationItem(
        id: "history",
        title: String(localized: "History"),
        systemImage: "clock.arrow.circlepath",
        requiredCapability: nil,
        section: .config
    )

    static let allItems: [NavigationItem] = [
        .sessions,
        .analytics,
        .todos,
        .history,
        .commands,
        .skills,
        .plans,
        .memory,
        .hooks,
        .mcpServers,
        .plugins,
        .outputStyles,
        .models,
        .subAgents,
    ]
}
