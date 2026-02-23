@testable import Poirot

final class ProviderDescribingMock: ProviderDescribing {
    var name: String = ""
    var assistantName: String = ""
    var assistantAvatarLetter: String = ""
    var statusActiveText: String = ""
    var companionTagline: String = ""
    var capabilities: Set<ProviderCapability> = []
    var projectsPath: String = ""
    var cliPath: String = ""
    var cliLabel: String = ""
    var defaultModelName: String = ""
    var supportedModels: [String] = []
    var toolDefinitions: [String: ToolDefinition] = [:]
    var configurationItems: [ConfigurationItem] = []

    // MARK: - supports

    var supportsCallsCount = 0
    var supportsCalled: Bool { supportsCallsCount > 0 }
    var supportsReturnValue: Bool?
    var supportsClosure: ((ProviderCapability) -> Bool)?

    func supports(_ capability: ProviderCapability) -> Bool {
        supportsCallsCount += 1
        if let closure = supportsClosure { return closure(capability) }
        if let returnValue = supportsReturnValue { return returnValue }
        return capabilities.contains(capability)
    }

    // MARK: - toolDisplayName

    var toolDisplayNameCallsCount = 0
    var toolDisplayNameCalled: Bool { toolDisplayNameCallsCount > 0 }
    var toolDisplayNameReturnValue: String?
    var toolDisplayNameClosure: ((String) -> String)?

    func toolDisplayName(for toolName: String) -> String {
        toolDisplayNameCallsCount += 1
        if let closure = toolDisplayNameClosure { return closure(toolName) }
        if let returnValue = toolDisplayNameReturnValue { return returnValue }
        return toolDefinitions[toolName]?.displayName ?? toolName
    }

    // MARK: - toolIcon

    var toolIconCallsCount = 0
    var toolIconCalled: Bool { toolIconCallsCount > 0 }
    var toolIconReturnValue: String?
    var toolIconClosure: ((String) -> String)?

    func toolIcon(for toolName: String) -> String {
        toolIconCallsCount += 1
        if let closure = toolIconClosure { return closure(toolName) }
        if let returnValue = toolIconReturnValue { return returnValue }
        return toolDefinitions[toolName]?.icon ?? "wrench"
    }
}
