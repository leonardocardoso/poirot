import SwiftUI

struct ConfigurationView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Configuration")
                    .font(LumnoTheme.Typography.heading)
                    .foregroundStyle(LumnoTheme.Colors.textPrimary)

                Text("Manage your Claude Code skills, commands, MCPs, and preferences")
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
                    ForEach(ConfigItem.allItems) { item in
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

// MARK: - Config Item

private struct ConfigItem: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let count: String
    let description: String

    static let allItems: [ConfigItem] = [
        ConfigItem(
            icon: "bolt.fill",
            iconColor: LumnoTheme.Colors.accent,
            title: "Skills",
            count: "8 active",
            description: "Custom skills and automation workflows for Claude Code sessions"
        ),
        ConfigItem(
            icon: "slash.circle",
            iconColor: LumnoTheme.Colors.blue,
            title: "Slash Commands",
            count: "12 available",
            description: "Quick commands for common operations like worktrees, PRs, and tasks"
        ),
        ConfigItem(
            icon: "powerplug.fill",
            iconColor: LumnoTheme.Colors.green,
            title: "MCP Servers",
            count: "5 connected",
            description: "Connected services — GitHub, Notion, Figma, Sentry, Perplexity"
        ),
        ConfigItem(
            icon: "brain",
            iconColor: LumnoTheme.Colors.purple,
            title: "Models",
            count: "Opus 4",
            description: "Select default model, configure per-project preferences"
        ),
        ConfigItem(
            icon: "person.2.fill",
            iconColor: LumnoTheme.Colors.orange,
            title: "Sub-agents",
            count: "4 types",
            description: "Configure Explore, Plan, Bash, and General-purpose agents"
        ),
        ConfigItem(
            icon: "speaker.wave.3.fill",
            iconColor: LumnoTheme.Colors.red,
            title: "Output Styles",
            count: "TTS ready",
            description: "Text-to-speech with ElevenLabs, output formatting, and display options"
        ),
    ]
}

// MARK: - Config Card

private struct ConfigCard: View {
    let item: ConfigItem
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
