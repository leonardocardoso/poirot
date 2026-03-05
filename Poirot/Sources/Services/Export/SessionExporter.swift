import AppKit
import Foundation
import UniformTypeIdentifiers
import WebKit

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

    // MARK: - HTML (for PDF rendering)

    nonisolated static func toHTML(_ session: Session, options: ExportOptions = ExportOptions()) -> String {
        let markdown = toMarkdown(session, options: options)
        return wrapInHTML(markdown, title: session.title)
    }

    nonisolated private static func wrapInHTML(_ markdown: String, title: String) -> String {
        let escaped = markdown
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")

        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <title>\(title)</title>
        <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 40px 20px;
            color: #1a1a1a;
            line-height: 1.6;
            background: #ffffff;
        }
        h1 { font-size: 24px; border-bottom: 2px solid #e8a642; padding-bottom: 8px; }
        h2 { font-size: 18px; margin-top: 32px; color: #333; }
        h3 { font-size: 14px; color: #666; }
        hr { border: none; border-top: 1px solid #e0e0e0; margin: 24px 0; }
        pre {
            background: #f5f5f5;
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            padding: 12px;
            overflow-x: auto;
            font-size: 13px;
            line-height: 1.4;
        }
        code {
            background: #f0f0f0;
            padding: 2px 6px;
            border-radius: 3px;
            font-size: 13px;
        }
        pre code { background: none; padding: 0; }
        em { color: #888; }
        strong { color: #333; }
        details { margin: 8px 0; }
        summary { cursor: pointer; color: #888; font-style: italic; }
        </style>
        </head>
        <body>
        <pre style="white-space: pre-wrap; background: none; border: none; padding: 0; font-family: inherit;">\(escaped)</pre>
        </body>
        </html>
        """
    }

    // MARK: - PDF

    static func toPDF(_ session: Session, options: ExportOptions = ExportOptions()) async -> Data? {
        let html = toHTML(session, options: options)
        return await renderHTMLToPDF(html)
    }

    @MainActor
    private static func renderHTMLToPDF(_ html: String) async -> Data? {
        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        webView.loadHTMLString(html, baseURL: nil)

        // Wait for page to finish loading
        for _ in 0 ..< 100 {
            try? await Task.sleep(for: .milliseconds(50))
            if !webView.isLoading { break }
        }

        // Small delay for rendering
        try? await Task.sleep(for: .milliseconds(200))

        let config = WKPDFConfiguration()
        config.rect = NSRect(x: 0, y: 0, width: 612, height: 792) // US Letter

        return try? await webView.pdf(configuration: config)
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

    @MainActor
    static func presentPDFSavePanel(data: Data, sessionTitle: String) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.pdf]
        panel.nameFieldStringValue = sanitizeFilename(sessionTitle) + ".pdf"
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return }
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - Share

    @MainActor
    static func share(
        content: String,
        sessionTitle: String,
        format: ExportFormat,
        from view: NSView
    ) async {
        let tempDir = FileManager.default.temporaryDirectory
        let filename = sanitizeFilename(sessionTitle)

        let fileURL: URL
        switch format {
        case .markdown:
            fileURL = tempDir.appendingPathComponent("\(filename).md")
            try? content.write(to: fileURL, atomically: true, encoding: .utf8)
        case .pdf:
            fileURL = tempDir.appendingPathComponent("\(filename).pdf")
            // Content is already markdown; we need to convert
            guard let data = content.data(using: .utf8) else { return }
            try? data.write(to: fileURL, options: .atomic)
        }

        let picker = NSSharingServicePicker(items: [fileURL])
        picker.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
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

// MARK: - Export Format

enum ExportFormat: String, CaseIterable, Identifiable {
    case markdown = "Markdown"
    case pdf = "PDF"

    var id: String { rawValue }

    var fileExtension: String {
        switch self {
        case .markdown: "md"
        case .pdf: "pdf"
        }
    }

    var icon: String {
        switch self {
        case .markdown: "doc.text"
        case .pdf: "doc.richtext"
        }
    }
}
