import SwiftUI

struct ExportOptionsView: View {
    let session: Session

    @State
    private var format: ExportFormat = .markdown

    @State
    private var options = ExportOptions()

    @State
    private var isExporting = false

    @Environment(AppState.self)
    private var appState

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.lg) {
            // Header
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .font(PoirotTheme.Typography.body)
                    .foregroundStyle(PoirotTheme.Colors.accent)

                Text("Export Session")
                    .font(PoirotTheme.Typography.headingSmall)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)
            }

            // Format picker
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
                Text("Format")
                    .font(PoirotTheme.Typography.captionMedium)
                    .foregroundStyle(PoirotTheme.Colors.textSecondary)

                Picker("Format", selection: $format) {
                    ForEach(ExportFormat.allCases) { fmt in
                        Label(fmt.rawValue, systemImage: fmt.icon)
                            .tag(fmt)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            // Options
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
                Text("Options")
                    .font(PoirotTheme.Typography.captionMedium)
                    .foregroundStyle(PoirotTheme.Colors.textSecondary)

                Toggle("Include timestamps", isOn: $options.includeTimestamps)
                Toggle("Include tool results", isOn: $options.includeToolResults)
                Toggle("Include thinking blocks", isOn: $options.includeThinking)
                Toggle("Include token usage", isOn: $options.includeTokenUsage)
            }
            .font(PoirotTheme.Typography.caption)
            .foregroundStyle(PoirotTheme.Colors.textPrimary)
            .toggleStyle(.checkbox)

            Divider()

            // Actions
            HStack(spacing: PoirotTheme.Spacing.sm) {
                Button("Copy Markdown") {
                    copyMarkdown()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Export\u{2026}") {
                    Task { await exportSession() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isExporting)
            }
        }
        .padding(PoirotTheme.Spacing.lg)
        .frame(width: 300)
    }

    // MARK: - Actions

    private func copyMarkdown() {
        let markdown = SessionExporter.toMarkdown(session, options: options)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(markdown, forType: .string)
        appState.showToast("Copied session as Markdown")
        dismiss()
    }

    private func exportSession() async {
        isExporting = true
        defer { isExporting = false }

        switch format {
        case .markdown:
            let content = SessionExporter.toMarkdown(session, options: options)
            SessionExporter.presentMarkdownSavePanel(
                content: content,
                sessionTitle: session.title
            )

        case .pdf:
            guard let data = await SessionExporter.toPDF(session, options: options) else {
                appState.showToast("Failed to generate PDF")
                return
            }
            SessionExporter.presentPDFSavePanel(
                data: data,
                sessionTitle: session.title
            )
        }

        dismiss()
    }
}
