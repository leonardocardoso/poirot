import SwiftUI

struct ToolBlockView: View {
    let tool: ToolUse
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: LumnoTheme.Spacing.sm) {
                    Image(systemName: tool.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(LumnoTheme.Colors.textSecondary)

                    Text(tool.displayName)
                        .font(LumnoTheme.Typography.smallBold)
                        .foregroundStyle(LumnoTheme.Colors.textSecondary)

                    if let path = tool.filePath {
                        Text(path)
                            .font(LumnoTheme.Typography.codeSmall)
                            .foregroundStyle(LumnoTheme.Colors.textTertiary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text("Done")
                        .font(.system(size: 10, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(LumnoTheme.Colors.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LumnoTheme.Colors.green.opacity(0.1))
                        )

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(LumnoTheme.Colors.bgElevated)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().opacity(0.3)

                // Placeholder for tool content (diffs, command output, etc.)
                Text("Tool output content")
                    .font(LumnoTheme.Typography.code)
                    .foregroundStyle(LumnoTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(LumnoTheme.Colors.bgCode)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: LumnoTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: LumnoTheme.Radius.md)
                .stroke(LumnoTheme.Colors.border)
        )
    }
}
