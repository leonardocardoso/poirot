extension ProviderDescribing {
    func supports(_ capability: ProviderCapability) -> Bool {
        capabilities.contains(capability)
    }

    func toolDisplayName(for toolName: String) -> String {
        toolDefinitions[toolName]?.displayName ?? toolName
    }

    func toolIcon(for toolName: String) -> String {
        toolDefinitions[toolName]?.icon ?? "wrench"
    }

    var navigationItems: [NavigationItem] {
        NavigationItem.allItems.filter { item in
            guard let capability = item.requiredCapability else { return true }
            return supports(capability)
        }
    }
}
