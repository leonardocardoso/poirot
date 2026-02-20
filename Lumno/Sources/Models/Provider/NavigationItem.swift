import Foundation

struct NavigationItem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let systemImage: String
    let requiredCapability: ProviderCapability?

    static let sessions = NavigationItem(
        id: "sessions",
        title: String(localized: "Sessions"),
        systemImage: "rectangle.stack",
        requiredCapability: nil
    )
    static let commands = NavigationItem(
        id: "commands",
        title: String(localized: "Commands"),
        systemImage: "terminal",
        requiredCapability: .commands
    )
    static let skills = NavigationItem(
        id: "skills",
        title: String(localized: "Skills"),
        systemImage: "bolt.circle",
        requiredCapability: .skills
    )
    static let configuration = NavigationItem(
        id: "configuration",
        title: String(localized: "Configuration"),
        systemImage: "gearshape",
        requiredCapability: .configuration
    )

    static let allItems: [NavigationItem] = [.sessions, .commands, .skills, .configuration]
}
