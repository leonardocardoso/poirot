import Foundation

extension Bundle {
    nonisolated var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    nonisolated var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
