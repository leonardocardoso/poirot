import SwiftUI

private struct SessionLoaderKey: EnvironmentKey {
    static let defaultValue: any SessionLoading = SessionLoader()
}

extension EnvironmentValues {
    var sessionLoader: any SessionLoading {
        get { self[SessionLoaderKey.self] }
        set { self[SessionLoaderKey.self] = newValue }
    }
}
