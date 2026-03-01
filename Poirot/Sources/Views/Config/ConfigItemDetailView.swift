@preconcurrency import MarkdownUI
import SwiftUI

struct ConfigItemDetailView<Badges: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let markdownBody: String
    let filePath: String?
    let scope: ConfigScope?
    @ViewBuilder
    let badges: () -> Badges

    init(
        title: String,
        icon: String,
        iconColor: Color,
        markdownBody: String,
        filePath: String?,
        scope: ConfigScope? = nil,
        @ViewBuilder badges: @escaping () -> Badges
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.markdownBody = markdownBody
        self.filePath = filePath
        self.scope = scope
        self.badges = badges
    }

    @Environment(AppState.self)
    private var appState

    @State
    private var isRevealed = false

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .background(PoirotTheme.Colors.bgApp)
        .task {
            isRevealed = false
            try? await Task.sleep(for: .milliseconds(50))
            withAnimation(.easeOut(duration: 0.4)) {
                isRevealed = true
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            HStack(spacing: PoirotTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(PoirotTheme.Typography.headingSmall)
                    .foregroundStyle(iconColor)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                            .fill(iconColor.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                    Text(title)
                        .font(PoirotTheme.Typography.heading)
                        .foregroundStyle(PoirotTheme.Colors.textPrimary)

                    HStack(spacing: PoirotTheme.Spacing.sm) {
                        if let scope {
                            ConfigScopeBadge(scope: scope)
                        }
                        badges()
                    }
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, PoirotTheme.Spacing.xxxl)
        .padding(.vertical, PoirotTheme.Spacing.xl)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.3)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if markdownBody.isEmpty {
            VStack(spacing: PoirotTheme.Spacing.md) {
                Image(systemName: "doc.text")
                    .font(PoirotTheme.Typography.heroTitle)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
                Text("No content")
                    .font(PoirotTheme.Typography.body)
                    .foregroundStyle(PoirotTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                Group {
                    if appState.configDetailFormatted {
                        Markdown(markdownBody)
                            .markdownTheme(.poirot)
                    } else {
                        Text(markdownBody)
                            .font(PoirotTheme.Typography.code)
                            .foregroundStyle(PoirotTheme.Colors.textSecondary)
                    }
                }
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, PoirotTheme.Spacing.xxxl)
                .padding(.vertical, PoirotTheme.Spacing.xl)
                .opacity(isRevealed ? 1 : 0)
                .animation(.easeOut(duration: 0.35), value: isRevealed)
            }
        }
    }
}
