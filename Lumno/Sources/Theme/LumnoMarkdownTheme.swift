import HighlightSwift
@preconcurrency import MarkdownUI
import SwiftUI

extension Theme {
    static let lumno = Theme()
        .text {
            ForegroundColor(LumnoTheme.Colors.textPrimary)
            FontSize(14 * LumnoTheme.Typography.scale)
        }
        .code {
            FontFamilyVariant(.monospaced)
            FontSize(12 * LumnoTheme.Typography.scale)
            ForegroundColor(LumnoTheme.Colors.accent)
            BackgroundColor(LumnoTheme.Colors.bgCode)
        }
        .strong {
            FontWeight(.semibold)
        }
        .link {
            ForegroundColor(LumnoTheme.Colors.accent)
        }
        .heading1 { configuration in
            configuration.label
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(18 * LumnoTheme.Typography.scale)
                    ForegroundColor(LumnoTheme.Colors.textPrimary)
                }
                .markdownMargin(top: 16, bottom: 8)
        }
        .heading2 { configuration in
            configuration.label
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(16 * LumnoTheme.Typography.scale)
                    ForegroundColor(LumnoTheme.Colors.textPrimary)
                }
                .markdownMargin(top: 12, bottom: 6)
        }
        .heading3 { configuration in
            configuration.label
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(14 * LumnoTheme.Typography.scale)
                    ForegroundColor(LumnoTheme.Colors.textPrimary)
                }
                .markdownMargin(top: 10, bottom: 4)
        }
        .blockquote { configuration in
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(LumnoTheme.Colors.accent)
                    .frame(width: 3)

                configuration.label
                    .markdownTextStyle {
                        ForegroundColor(LumnoTheme.Colors.textSecondary)
                        FontStyle(.italic)
                    }
                    .padding(.leading, 12)
            }
            .markdownMargin(top: 8, bottom: 8)
        }
        .codeBlock { configuration in
            LumnoCodeBlockView(configuration: configuration)
        }
        .listItem { configuration in
            configuration.label
                .markdownMargin(top: 2, bottom: 2)
        }
        .paragraph { configuration in
            configuration.label
                .markdownMargin(top: 0, bottom: 8)
                .lineSpacing(4)
        }
}

// MARK: - Code Block with Syntax Highlighting

struct LumnoCodeBlockView: View {
    let configuration: CodeBlockConfiguration

    @State
    private var attributedCode: AttributedString?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let language = configuration.language {
                HStack {
                    Text(language)
                        .font(LumnoTheme.Typography.tiny)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(LumnoTheme.Colors.bgElevated)
            }

            Group {
                if let attributedCode {
                    Text(attributedCode)
                } else {
                    Text(configuration.content)
                        .foregroundStyle(LumnoTheme.Colors.textPrimary)
                }
            }
            .font(LumnoTheme.Typography.code)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
        }
        .background(LumnoTheme.Colors.bgCode)
        .clipShape(RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                .stroke(LumnoTheme.Colors.border)
        )
        .task(id: configuration.content) {
            await highlight(
                code: configuration.content,
                language: configuration.language
            )
        }
    }

    private func highlight(code: String, language: String?) async {
        guard let lang = language else { return }

        do {
            let result = try await LumnoHighlight.shared.request(
                code,
                mode: .languageAlias(lang),
                colors: .dark(.xcode)
            )
            attributedCode = result.attributedText
        } catch {
            // Fall back to plain text on error
        }
    }
}

// MARK: - Highlight Singleton

private enum LumnoHighlight {
    static let shared = HighlightSwift.Highlight()
}
