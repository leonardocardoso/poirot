import AppKit

enum PreferredTerminal: String, CaseIterable {
    case terminal
    case iterm2
    case warp
    case ghostty
    case kitty
    case alacritty

    var displayName: String {
        switch self {
        case .terminal: "Terminal"
        case .iterm2: "iTerm2"
        case .warp: "Warp"
        case .ghostty: "Ghostty"
        case .kitty: "Kitty"
        case .alacritty: "Alacritty"
        }
    }

    var bundleIdentifier: String {
        switch self {
        case .terminal: "com.apple.Terminal"
        case .iterm2: "com.googlecode.iterm2"
        case .warp: "dev.warp.Warp-Stable"
        case .ghostty: "com.mitchellh.ghostty"
        case .kitty: "net.kovidgoyal.kitty"
        case .alacritty: "org.alacritty"
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

    static var installedCases: [PreferredTerminal] {
        allCases.filter(\.isInstalled)
    }
}
