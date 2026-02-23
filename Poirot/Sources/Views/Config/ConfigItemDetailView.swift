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
                    .font(PoirotTheme.Typography.large)
                    .foregroundStyle(iconColor)
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                            .fill(iconColor.opacity(0.15))
                    )

                Text(title)
                    .font(PoirotTheme.Typography.subheading)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                Spacer()
            }

            HStack(spacing: PoirotTheme.Spacing.sm) {
                if let scope {
                    ConfigScopeBadge(scope: scope)
                }
                badges()
            }
        }
        .padding(.horizontal, PoirotTheme.Spacing.lg)
        .padding(.vertical, PoirotTheme.Spacing.md)
        .background {
            GlassBackground(in: .rect(cornerRadius: PoirotTheme.Radius.md))
        }
        .overlay {
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .stroke(PoirotTheme.Colors.border.opacity(0.3), lineWidth: 0.5)
        }
        .padding(.horizontal, PoirotTheme.Spacing.md)
        .padding(.top, PoirotTheme.Spacing.sm)
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
                Markdown(markdownBody)
                    .markdownTheme(.poirot)
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
