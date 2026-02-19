import SwiftUI
import SwiftMockKit

@Mockable
protocol ProviderDescribing {
    var name: String { get }
    var assistantName: String { get }
    var assistantAvatarLetter: String { get }
    var statusActiveText: String { get }
    var companionTagline: String { get }
    var capabilities: Set<ProviderCapability> { get }
    var projectsPath: String { get }
    var cliPath: String { get }
    var cliLabel: String { get }
    var defaultModelName: String { get }
    var supportedModels: [String] { get }
    var toolDefinitions: [String: ToolDefinition] { get }
    var configurationItems: [ConfigurationItem] { get }

    func supports(_ capability: ProviderCapability) -> Bool
    func toolDisplayName(for toolName: String) -> String
    func toolIcon(for toolName: String) -> String

    var navigationItems: [NavigationItem] { get }
}
