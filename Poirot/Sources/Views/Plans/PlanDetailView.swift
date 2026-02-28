@preconcurrency import MarkdownUI
import SwiftUI

struct PlanDetailView: View {
    let plan: Plan

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
                Image(systemName: "list.bullet.clipboard.fill")
                    .font(PoirotTheme.Typography.large)
                    .foregroundStyle(PoirotTheme.Colors.teal)
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                            .fill(PoirotTheme.Colors.teal.opacity(0.15))
                    )

                Text(plan.name)
                    .font(PoirotTheme.Typography.subheading)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                Spacer()
            }

            HStack(spacing: PoirotTheme.Spacing.sm) {
                ConfigBadge(
                    text: plan.fileURL.lastPathComponent,
                    fg: PoirotTheme.Colors.teal,
                    bg: PoirotTheme.Colors.teal.opacity(0.15)
                )
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
        if plan.content.isEmpty {
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
                        Markdown(plan.content)
                            .markdownTheme(.poirot)
                    } else {
                        Text(plan.content)
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
