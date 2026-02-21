import SwiftUI

struct ToolBlockView: View {
    let tool: ToolUse
    var result: ToolResult?

    @Environment(\.provider)
    private var provider
    @State
    private var isExpanded = false
    @State
    private var copied = false

    private var isError: Bool { result?.isError == true }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: LumnoTheme.Spacing.sm) {
                    Image(systemName: provider.toolIcon(for: tool.name))
                        .font(.system(size: 12))
                        .foregroundStyle(LumnoTheme.Colors.textSecondary)

                    Text(provider.toolDisplayName(for: tool.name))
                        .font(LumnoTheme.Typography.smallBold)
                        .foregroundStyle(LumnoTheme.Colors.textSecondary)

                    if let path = tool.filePath {
                        Text(path)
                            .font(LumnoTheme.Typography.codeSmall)
                            .foregroundStyle(LumnoTheme.Colors.textTertiary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text(isError ? "Error" : "Done")
                        .font(.system(size: 10, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(isError ? LumnoTheme.Colors.red : LumnoTheme.Colors.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill((isError ? LumnoTheme.Colors.red : LumnoTheme.Colors.green).opacity(0.1))
                        )

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(LumnoTheme.Colors.bgElevated)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().opacity(0.3)

                if let content = result?.content, !content.isEmpty {
                    ZStack(alignment: .topTrailing) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(content)
                                .font(LumnoTheme.Typography.code)
                                .foregroundStyle(
                                    isError
                                        ? LumnoTheme.Colors.red.opacity(0.8)
                                        : LumnoTheme.Colors.textSecondary
                                )
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(14)
                        .padding(.trailing, 30)

                        copyButton(content: content)
                            .padding(8)
                    }
                    .background(LumnoTheme.Colors.bgCode)
                } else {
                    Text("No output")
                        .font(LumnoTheme.Typography.code)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(LumnoTheme.Colors.bgCode)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: LumnoTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: LumnoTheme.Radius.md)
                .stroke(isError ? LumnoTheme.Colors.red.opacity(0.2) : LumnoTheme.Colors.border)
        )
    }

    private func copyButton(content: String) -> some View {
        Button {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(content, forType: .string)
            copied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                copied = false
            }
        } label: {
            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .font(.system(size: 11))
                .foregroundStyle(copied ? LumnoTheme.Colors.green : LumnoTheme.Colors.textTertiary)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                        .fill(LumnoTheme.Colors.bgElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                                .stroke(copied ? LumnoTheme.Colors.green.opacity(0.3) : LumnoTheme.Colors.border)
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: copied)
    }
}
