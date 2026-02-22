import AppKit

enum TerminalLauncher {
    /// Copies the command to the clipboard and opens the preferred terminal.
    static func launch(command: String, clipboardText: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(clipboardText, forType: .string)

        let terminal = PreferredTerminal(
            rawValue: UserDefaults.standard.string(forKey: "preferredTerminal") ?? "terminal"
        ) ?? .terminal

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            run(command: command, in: terminal)
        }
    }

    /// Opens the preferred terminal without running any command.
    static func open(_ terminal: PreferredTerminal) {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId(for: terminal)) {
            NSWorkspace.shared.open(
                [],
                withApplicationAt: appURL,
                configuration: NSWorkspace.OpenConfiguration()
            )
        }
    }

    /// Runs a command in the preferred terminal immediately (no delay).
    static func run(command: String, in terminal: PreferredTerminal) {
        let escaped = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let source: String

        switch terminal {
        case .terminal:
            source = """
            tell application "Terminal"
                activate
                do script "\(escaped)"
            end tell
            """
        case .iterm2:
            source = """
            tell application "iTerm"
                activate
                create window with default profile command "\(escaped)"
            end tell
            """
        case .warp:
            source = """
            tell application "Warp"
                activate
            end tell
            """
            // Warp doesn't support AppleScript commands well; fall back to launch + paste
            runAppleScript(source)
            return
        case .ghostty, .kitty, .alacritty:
            // These terminals don't support AppleScript; open the app and rely on clipboard
            if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId(for: terminal)) {
                NSWorkspace.shared.open(
                    [],
                    withApplicationAt: appURL,
                    configuration: NSWorkspace.OpenConfiguration()
                )
            }
            return
        }

        runAppleScript(source)
    }

    private static func runAppleScript(_ source: String) {
        if let script = NSAppleScript(source: source) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
        }
    }

    private static func bundleId(for terminal: PreferredTerminal) -> String {
        switch terminal {
        case .terminal: "com.apple.Terminal"
        case .iterm2: "com.googlecode.iterm2"
        case .warp: "dev.warp.Warp-Stable"
        case .ghostty: "com.mitchellh.ghostty"
        case .kitty: "net.kovidgoyal.kitty"
        case .alacritty: "org.alacritty"
        }
    }
}
