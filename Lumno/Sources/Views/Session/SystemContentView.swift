import SwiftUI

struct SystemContentView: View {
    let blocks: [SystemContentParser.SystemBlock]

    @State
    private var isExpanded = false

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .opacity(0.3)
                .padding(.bottom, LumnoTheme.Spacing.sm)

            Button {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 10))

                    Text("System context (\(blocks.count))")
                        .font(LumnoTheme.Typography.tiny)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .semibold))
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }
                .foregroundStyle(LumnoTheme.Colors.textTertiary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(LumnoTheme.Colors.bgCode.opacity(0.5))
                        .overlay(
                            Capsule()
                                .stroke(LumnoTheme.Colors.borderSubtle)
                        )
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: LumnoTheme.Spacing.sm) {
                    ForEach(blocks) { block in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(block.tagName)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundStyle(LumnoTheme.Colors.accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(LumnoTheme.Colors.accentDim)
                                )

                            Text(block.content)
                                .font(LumnoTheme.Typography.tiny)
                                .foregroundStyle(LumnoTheme.Colors.textTertiary)
                                .lineSpacing(2)
                                .textSelection(.enabled)
                        }
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                        .fill(LumnoTheme.Colors.bgCode)
                        .overlay(
                            RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                                .stroke(LumnoTheme.Colors.borderSubtle)
                        )
                )
                .padding(.top, LumnoTheme.Spacing.sm)
            }
        }
        .padding(.top, 10)
    }
}
