import AppKit

enum EditorLauncher {
    static func open(filePath: String, line: Int, editor: PreferredEditor) {
        let expanded = expandTilde(filePath)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        switch editor {
        case .vscode, .cursor:
            process.arguments = [editor.cliCommand, "--goto", "\(expanded):\(line)"]
        case .xcode:
            process.arguments = ["xed", "--line", "\(line)", expanded]
        case .zed:
            process.arguments = [editor.cliCommand, "\(expanded):\(line)"]
        }
        try? process.run()
    }

    static func open(filePath: String, editor: PreferredEditor) {
        let url = URL(fileURLWithPath: expandTilde(filePath))

        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: editor.bundleIdentifier) {
            NSWorkspace.shared.open(
                [url],
                withApplicationAt: appURL,
                configuration: NSWorkspace.OpenConfiguration()
            )
        } else {
            // Fallback to CLI command
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = [editor.cliCommand, filePath]
            try? process.run()
        }
    }

    private static func expandTilde(_ path: String) -> String {
        if path.hasPrefix("~") {
            return path.replacingOccurrences(
                of: "~",
                with: FileManager.default.homeDirectoryForCurrentUser.path,
                range: path.startIndex ..< path.index(after: path.startIndex)
            )
        }
        return path
    }
}
