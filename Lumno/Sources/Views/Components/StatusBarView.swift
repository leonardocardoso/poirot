import SwiftUI

struct StatusBarView: View {
    var isSessionEnded: Bool = false

    var body: some View {
        HStack {
            HStack(spacing: LumnoTheme.Spacing.md) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(isSessionEnded ? LumnoTheme.Colors.textTertiary : LumnoTheme.Colors.green)
                        .frame(width: 6, height: 6)

                    Text(isSessionEnded ? "Session ended" : "Claude Code active")
                        .font(LumnoTheme.Typography.tiny)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)
                }
            }

            Spacer()

            HStack(spacing: LumnoTheme.Spacing.md) {
                HStack(spacing: 4) {
                    Image(systemName: "folder")
                        .font(.system(size: 10))
                    Text("~/Dev/git/business/lumno")
                        .font(LumnoTheme.Typography.tiny)
                }
                .foregroundStyle(LumnoTheme.Colors.textTertiary)

                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 10))
                    Text("main")
                        .font(LumnoTheme.Typography.tiny)
                }
                .foregroundStyle(LumnoTheme.Colors.textTertiary)
            }
        }
        .padding(.horizontal, LumnoTheme.Spacing.lg)
        .frame(height: 32)
        .background(LumnoTheme.Colors.bgSidebar)
        .overlay(alignment: .top) {
            Divider().opacity(0.3)
        }
    }
}
