import AppKit

enum PreferredEditor: String, CaseIterable {
    case vscode = "code"
    case cursor = "cursor"
    case xcode = "xcode"
    case zed = "zed"

    var displayName: String {
        switch self {
        case .vscode: "VS Code"
        case .cursor: "Cursor"
        case .xcode: "Xcode"
        case .zed: "Zed"
        }
    }

    var bundleIdentifier: String {
        switch self {
        case .vscode: "com.microsoft.VSCode"
        case .cursor: "com.todesktop.230313mzl4w4u92"
        case .xcode: "com.apple.dt.Xcode"
        case .zed: "dev.zed.Zed"
        }
    }

    var cliCommand: String {
        switch self {
        case .vscode: "code"
        case .cursor: "cursor"
        case .xcode: "xed"
        case .zed: "zed"
        }
    }

    var isInstalled: Bool {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) != nil
    }

    var appIcon: NSImage? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            return nil
        }
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        icon.size = NSSize(width: 16, height: 16)
        return icon
    }

    static var installedCases: [PreferredEditor] {
        allCases.filter(\.isInstalled)
    }
}
