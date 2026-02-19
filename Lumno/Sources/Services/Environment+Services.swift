import SwiftUI

private struct SessionLoaderKey: EnvironmentKey {
    static let defaultValue: any SessionLoading = SessionLoader()
}

private struct ProviderKey: EnvironmentKey {
    static let defaultValue: any ProviderDescribing = ClaudeCodeProvider()
}

extension EnvironmentValues {
    var sessionLoader: any SessionLoading {
        get { self[SessionLoaderKey.self] }
        set { self[SessionLoaderKey.self] = newValue }
    }

    var provider: any ProviderDescribing {
        get { self[ProviderKey.self] }
        set { self[ProviderKey.self] = newValue }
    }
}
