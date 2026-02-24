import AppKit

enum EditorLauncher {
    static func open(filePath: String, line: Int, editor: PreferredEditor) {
        let expanded = expandTilde(filePath)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.environment = environmentWithPath()
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
            process.environment = environmentWithPath()
            process.arguments = [editor.cliCommand, filePath]
            try? process.run()
        }
    }

    private static func environmentWithPath() -> [String: String] {
        var env = ProcessInfo.processInfo.environment
        let extra = "/usr/local/bin:/opt/homebrew/bin"
        if let existing = env["PATH"] {
            env["PATH"] = "\(existing):\(extra)"
        } else {
            env["PATH"] = "/usr/bin:/bin:\(extra)"
        }
        return env
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
