import SwiftUI

struct ConfigBadge: View {
    let text: String
    let fg: Color
    let bg: Color

    var body: some View {
        Text(text)
            .font(PoirotTheme.Typography.tiny)
            .foregroundStyle(fg)
            .padding(.horizontal, PoirotTheme.Spacing.sm)
            .padding(.vertical, 3)
            .background(Capsule().fill(bg))
    }
}

struct ConfigScopeBadge: View {
    let scope: ConfigScope

    var body: some View {
        HStack(spacing: PoirotTheme.Spacing.xxs) {
            Image(systemName: scope == .project ? "folder.fill" : "globe")
                .font(PoirotTheme.Typography.pico)
            Text(scope == .project ? "Project" : "Global")
                .font(PoirotTheme.Typography.pico)
        }
        .foregroundStyle(scope == .project ? PoirotTheme.Colors.green : PoirotTheme.Colors.textTertiary)
        .padding(.horizontal, PoirotTheme.Spacing.sm)
        .padding(.vertical, 2)
        .background(
            Capsule().fill(
                scope == .project
                    ? PoirotTheme.Colors.green.opacity(0.12)
                    : PoirotTheme.Colors.textTertiary.opacity(0.08)
            )
        )
    }
}

struct MCPServerSourceBadge: View {
    let server: MCPServer

    var body: some View {
        switch server.source {
        case .user:
            ConfigScopeBadge(scope: server.scope)
        case .cloudIntegration:
            badgeView(
                icon: "cloud.fill",
                text: "claude.ai",
                fg: PoirotTheme.Colors.purple,
                bg: PoirotTheme.Colors.purple.opacity(0.12)
            )
        case .plugin:
            badgeView(
                icon: "puzzlepiece.fill",
                text: "Built-in",
                fg: PoirotTheme.Colors.blue,
                bg: PoirotTheme.Colors.blue.opacity(0.12)
            )
        }
    }

    private func badgeView(icon: String, text: String, fg: Color, bg: Color) -> some View {
        HStack(spacing: PoirotTheme.Spacing.xxs) {
            Image(systemName: icon)
                .font(PoirotTheme.Typography.pico)
            Text(text)
                .font(PoirotTheme.Typography.pico)
        }
        .foregroundStyle(fg)
        .padding(.horizontal, PoirotTheme.Spacing.sm)
        .padding(.vertical, 2)
        .background(Capsule().fill(bg))
    }
}

enum ConfigHelpers {
    static func formatModel(_ model: String) -> String {
        model.replacingOccurrences(of: "claude-", with: "")
            .split(separator: "-")
            .prefix(2)
            .joined(separator: " ")
            .capitalized
    }
}
