import AppKit
import Foundation
import UniformTypeIdentifiers

// MARK: - Export Options

struct ExportOptions {
    var includeThinking: Bool = false
    var includeToolResults: Bool = true
    var includeTimestamps: Bool = true
    var includeTokenUsage: Bool = false
}

// MARK: - Session Exporter

enum SessionExporter {
    // MARK: - Markdown

    nonisolated static func toMarkdown(_ session: Session, options: ExportOptions = ExportOptions()) -> String {
        var lines: [String] = []

        // Header
        lines.append("# \(session.title)")
        lines.append("")
        lines.append("**Project:** \(session.projectName)")
        if let model = session.model {
            lines.append("**Model:** \(model)")
        }
        lines.append("**Date:** \(formattedDate(session.startedAt))")
        lines.append("**Turns:** \(session.turnCount)")
        if session.totalTokens > 0 {
            lines.append("**Tokens:** \(formatTokenCount(session.totalTokens))")
        }
        lines.append("")
        lines.append("---")
        lines.append("")

        // Messages
        var turnNumber = 0
        for message in session.messages {
            if message.role == .user { turnNumber += 1 }
            let md = messageToMarkdown(message, turnNumber: turnNumber, options: options)
            if !md.isEmpty {
                lines.append(md)
                lines.append("")
                lines.append("---")
                lines.append("")
            }
        }

        return lines.joined(separator: "\n")
    }

    nonisolated static func messageToMarkdown(
        _ message: Message,
        turnNumber: Int = 0,
        options: ExportOptions = ExportOptions()
    ) -> String {
        var lines: [String] = []

        let roleLabel = message.role == .user ? "User" : "Assistant"
        let turnTag = turnNumber > 0 ? " \(turnNumber)" : ""
        lines.append("## Turn\(turnTag) \u{2014} \(roleLabel)")

        if options.includeTimestamps {
            lines.append("*\(formattedTime(message.timestamp))*")
        }

        if options.includeTokenUsage, let usage = message.tokenUsage {
            lines.append("*Tokens: \(usage.formatted)*")
        }

        lines.append("")

        for block in message.content {
            switch block {
            case let .text(text):
                lines.append(text)
                lines.append("")

            case let .toolUse(tool):
                if tool.isBash, let command = tool.command {
                    lines.append("### Tool: Bash")
                    lines.append("```bash")
                    lines.append(command)
                    lines.append("```")
                    lines.append("")
                } else if tool.isEdit, let filePath = tool.filePath {
                    lines.append("### Tool: Edit \u{2014} `\(filePath)`")
                    if tool.hasDiffData {
                        lines.append("```diff")
                        if let old = tool.oldString {
                            for line in old.components(separatedBy: "\n") {
                                lines.append("- \(line)")
                            }
                        }
                        if let new = tool.newString {
                            for line in new.components(separatedBy: "\n") {
                                lines.append("+ \(line)")
                            }
                        }
                        lines.append("```")
                    }
                    lines.append("")
                } else {
                    lines.append("### Tool: \(tool.name)")
                    if let path = tool.filePath {
                        lines.append("`\(path)`")
                    }
                    for (key, value) in tool.input where key != "file_path" && key != "path" {
                        let truncated = value.count > 500 ? String(value.prefix(500)) + "..." : value
                        lines.append("**\(key):** `\(truncated)`")
                    }
                    lines.append("")
                }

            case let .toolResult(result):
                guard options.includeToolResults else { continue }
                let label = result.isError ? "Error" : "Output"
                lines.append("**\(label):**")
                let content = result.content.count > 2000
                    ? String(result.content.prefix(2000)) + "\n... (truncated)"
                    : result.content
                lines.append("```")
                lines.append(content)
                lines.append("```")
                lines.append("")

            case let .thinking(text):
                guard options.includeThinking else { continue }
                lines.append("<details>")
                lines.append("<summary>Thinking</summary>")
                lines.append("")
                lines.append(text)
                lines.append("")
                lines.append("</details>")
                lines.append("")
            }
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Save Panel

    @MainActor
    static func presentMarkdownSavePanel(content: String, sessionTitle: String) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.plainText]
        panel.nameFieldStringValue = sanitizeFilename(sessionTitle) + ".md"
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return }
        try? content.write(to: url, atomically: true, encoding: .utf8)
    }

    // MARK: - Helpers

    nonisolated private static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    nonisolated private static func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    nonisolated private static func formatTokenCount(_ count: Int) -> String {
        let value = Double(count)
        if value >= 1000 {
            return String(format: "%.1fk", value / 1000)
        }
        return "\(count)"
    }

    nonisolated private static func sanitizeFilename(_ name: String) -> String {
        let cleaned = name
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
        return String(cleaned.prefix(80))
    }
}

