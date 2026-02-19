import SwiftUI

struct ConfigurationView: View {
    @Environment(\.provider) private var provider

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Configuration")
                    .font(LumnoTheme.Typography.heading)
                    .foregroundStyle(LumnoTheme.Colors.textPrimary)

                Text("Manage your \(provider.name) skills, commands, and preferences")
                    .font(LumnoTheme.Typography.caption)
                    .foregroundStyle(LumnoTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, LumnoTheme.Spacing.xxxl)
            .padding(.vertical, LumnoTheme.Spacing.xl)
            .overlay(alignment: .bottom) {
                Divider().opacity(0.3)
            }

            // Grid
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: LumnoTheme.Spacing.lg),
                        GridItem(.flexible(), spacing: LumnoTheme.Spacing.lg)
                    ],
                    spacing: LumnoTheme.Spacing.lg
                ) {
                    ForEach(provider.configurationItems) { item in
                        ConfigCard(item: item)
                    }
                }
                .padding(LumnoTheme.Spacing.xxxl)
            }

            StatusBarView()
        }
        .background(LumnoTheme.Colors.bgApp)
    }
}

// MARK: - Config Card

private struct ConfigCard: View {
    let item: ConfigurationItem
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: LumnoTheme.Spacing.sm) {
            HStack {
                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(item.iconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.iconColor.opacity(0.15))
                    )

                Text(item.title)
                    .font(LumnoTheme.Typography.bodyMedium)
                    .foregroundStyle(LumnoTheme.Colors.textPrimary)

                Spacer()

                Text(item.count)
                    .font(LumnoTheme.Typography.tiny)
                    .foregroundStyle(LumnoTheme.Colors.textTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(LumnoTheme.Colors.bgElevated)
                    )
            }

            Text(item.description)
                .font(LumnoTheme.Typography.caption)
                .foregroundStyle(LumnoTheme.Colors.textSecondary)
                .lineSpacing(2)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: LumnoTheme.Radius.md)
                .fill(isHovered ? LumnoTheme.Colors.bgCardHover : LumnoTheme.Colors.bgCard)
                .stroke(isHovered ? Color.white.opacity(0.1) : LumnoTheme.Colors.border)
        )
        .onHover { isHovered = $0 }
    }
}
