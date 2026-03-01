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
                    .font(PoirotTheme.Typography.headingSmall)
                    .foregroundStyle(PoirotTheme.Colors.teal)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                            .fill(PoirotTheme.Colors.teal.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                    Text(plan.name)
                        .font(PoirotTheme.Typography.heading)
                        .foregroundStyle(PoirotTheme.Colors.textPrimary)

                    Text(plan.fileURL.lastPathComponent)
                        .font(PoirotTheme.Typography.code)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .padding(.horizontal, PoirotTheme.Spacing.sm)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                                .fill(PoirotTheme.Colors.bgElevated)
                        )
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
