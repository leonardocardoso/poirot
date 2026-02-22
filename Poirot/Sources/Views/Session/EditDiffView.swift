import SwiftUI

struct EditDiffView: View {
    let oldString: String
    let newString: String
    let filePath: String?

    @State
    private var copied = false
    @State
    private var isContentHovered = false
    @State
    private var isButtonsHovered = false

    private var buttonOpacity: Double {
        isButtonsHovered ? 1.0 : (isContentHovered ? 0.15 : 0.5)
    }

    private var diffLines: [DiffLine] {
        LineDiff.diff(old: oldString, new: newString)
    }

    private var gutterWidth: CGFloat {
        let maxNum = max(
            diffLines.compactMap(\.oldLineNumber).max() ?? 0,
            diffLines.compactMap(\.newLineNumber).max() ?? 0
        )
        let digits = max(String(maxNum).count, 2)
        return CGFloat(digits) * 8 + 6
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                ScrollView(.horizontal, showsIndicators: false) {
                    ForEach(diffLines) { line in
                        diffLineRow(line)
                    }
                }
                .padding(.vertical, PoirotTheme.Spacing.sm)

                copyButton
                    .opacity(buttonOpacity)
                    .onHover { isButtonsHovered = $0 }
                    .animation(.easeInOut(duration: 0.15), value: buttonOpacity)
                    .padding(PoirotTheme.Spacing.sm)
            }
            .onHover { isContentHovered = $0 }
        }
        .background(PoirotTheme.Colors.bgCode)
    }

    private func diffLineRow(_ line: DiffLine) -> some View {
        HStack(spacing: 0) {
            // Old line number gutter
            Text(line.oldLineNumber.map(String.init) ?? "")
                .font(PoirotTheme.Typography.codeSmall)
                .foregroundStyle(PoirotTheme.Colors.textTertiary.opacity(0.6))
                .frame(width: gutterWidth, alignment: .trailing)

            // New line number gutter
            Text(line.newLineNumber.map(String.init) ?? "")
                .font(PoirotTheme.Typography.codeSmall)
                .foregroundStyle(PoirotTheme.Colors.textTertiary.opacity(0.6))
                .frame(width: gutterWidth, alignment: .trailing)

            // +/- indicator
            Text(indicator(for: line.kind))
                .font(PoirotTheme.Typography.code)
                .foregroundStyle(indicatorColor(for: line.kind))
                .frame(width: 20, alignment: .center)

            // Code text
            Text(line.text)
                .font(PoirotTheme.Typography.code)
                .foregroundStyle(textColor(for: line.kind))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, PoirotTheme.Spacing.xs)
        .padding(.vertical, 1)
        .background(backgroundColor(for: line.kind))
    }

    private func indicator(for kind: DiffLine.Kind) -> String {
        switch kind {
        case .context: " "
        case .added: "+"
        case .removed: "-"
        }
    }

    private func indicatorColor(for kind: DiffLine.Kind) -> Color {
        switch kind {
        case .context: PoirotTheme.Colors.textTertiary
        case .added: PoirotTheme.Colors.diffAddText
        case .removed: PoirotTheme.Colors.diffRemoveText
        }
    }

    private func textColor(for kind: DiffLine.Kind) -> Color {
        switch kind {
        case .context: PoirotTheme.Colors.textSecondary
        case .added: PoirotTheme.Colors.diffAddText
        case .removed: PoirotTheme.Colors.diffRemoveText
        }
    }

    private func backgroundColor(for kind: DiffLine.Kind) -> Color {
        switch kind {
        case .context: .clear
        case .added: PoirotTheme.Colors.diffAddBg
        case .removed: PoirotTheme.Colors.diffRemoveBg
        }
    }

    // MARK: - Buttons

    private var copyButton: some View {
        Button {
            let text = LineDiff.unifiedText(from: diffLines)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
            copied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                copied = false
            }
        } label: {
            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .font(PoirotTheme.Typography.tiny)
                .foregroundStyle(copied ? PoirotTheme.Colors.green : PoirotTheme.Colors.textTertiary)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                        .fill(PoirotTheme.Colors.bgElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                                .stroke(copied ? PoirotTheme.Colors.green.opacity(0.3) : PoirotTheme.Colors.border)
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: copied)
    }
}
