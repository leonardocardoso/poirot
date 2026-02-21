import AppKit

enum TerminalLauncher {
    /// Copies the command to the clipboard and opens Terminal.app after a delay.
    static func launch(command: String, clipboardText: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(clipboardText, forType: .string)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let escaped = command
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")

            let source = """
            tell application "Terminal"
                activate
                do script "\(escaped)"
            end tell
            """

            if let script = NSAppleScript(source: source) {
                var error: NSDictionary?
                script.executeAndReturnError(&error)
            }
        }
    }
}
