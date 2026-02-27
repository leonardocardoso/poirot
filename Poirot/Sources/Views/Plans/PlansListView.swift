@preconcurrency import MarkdownUI
import SwiftUI

struct PlansListView: View {
    let item: ConfigurationItem
    @State
    private var plans: [Plan] = []
    @State
    private var isRevealed = false
    @State
    private var isLoaded = false
    @State
    private var selectedPlan: Plan?

    @Environment(AppState.self)
    private var appState

    var body: some View {
        Group {
            if let plan = selectedPlan {
                PlanDetailView(plan: plan)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                listView
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .task(id: appState.activeConfigDetail?.filePath) {
            if plans.isEmpty { reloadPlans() }
            if let detail = appState.activeConfigDetail,
               selectedPlan?.fileURL.path != detail.filePath,
               let match = plans.first(where: { $0.fileURL.path == detail.filePath }) {
                selectedPlan = match
            }
        }
        .onChange(of: appState.activeConfigDetail) {
            if let detail = appState.activeConfigDetail {
                if selectedPlan?.fileURL.path != detail.filePath {
                    let match = plans.first(where: { $0.fileURL.path == detail.filePath })
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPlan = match
                    }
                }
            } else if selectedPlan != nil {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedPlan = nil
                }
                reloadPlans()
            }
        }
    }

    private var listView: some View {
        VStack(spacing: 0) {
            ConfigScreenHeader(
                item: item,
                dynamicCount: "\(plans.count) \(plans.count == 1 ? "plan" : "plans")",
                screenID: item.id,
                showLayoutToggle: true
            )

            if !isLoaded {
                ConfigSkeletonView(
                    layout: appState.configLayout(for: item.id)
                )
            } else if plans.isEmpty {
                ConfigEmptyState(
                    icon: "list.bullet.clipboard",
                    message: "No plans found",
                    hint: "~/.claude/plans/"
                )
            } else {
                configContent
            }
        }
        .background(PoirotTheme.Colors.bgApp)
        .task {
            reloadPlans()
            if !isLoaded {
                try? await Task.sleep(for: .milliseconds(400))
                withAnimation(.easeOut(duration: 0.35)) {
                    isLoaded = true
                }
            }
            isRevealed = false
            try? await Task.sleep(for: .milliseconds(50))
            withAnimation(.easeOut(duration: 0.4)) {
                isRevealed = true
            }
        }
    }

    @ViewBuilder
    private var configContent: some View {
        if appState.configLayout(for: item.id) == .grid {
            configGrid
        } else {
            configList
        }
    }

    private var configGrid: some View {
        ScrollView {
            HStack(alignment: .top, spacing: PoirotTheme.Spacing.lg) {
                ForEach(0 ..< 2, id: \.self) { column in
                    LazyVStack(spacing: PoirotTheme.Spacing.lg) {
                        ForEach(plansForColumn(column), id: \.element.id) { index, plan in
                            PlanCard(plan: plan) {
                                selectPlan(plan)
                            }
                            .shimmerReveal(
                                isRevealed: isRevealed,
                                delay: Double(min(index, 7)) * 0.04,
                                cornerRadius: PoirotTheme.Radius.md
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, PoirotTheme.Spacing.xxl)
            .padding(.top, PoirotTheme.Spacing.lg)
            .padding(.bottom, PoirotTheme.Spacing.xxl)
        }
    }

    private func plansForColumn(_ column: Int) -> [(offset: Int, element: Plan)] {
        Array(plans.enumerated()).filter { $0.offset % 2 == column }
    }

    private var configList: some View {
        ScrollView {
            LazyVStack(spacing: PoirotTheme.Spacing.md) {
                ForEach(Array(plans.enumerated()), id: \.element.id) { index, plan in
                    PlanCard(plan: plan) {
                        selectPlan(plan)
                    }
                    .shimmerReveal(
                        isRevealed: isRevealed,
                        delay: Double(min(index, 9)) * 0.03,
                        cornerRadius: PoirotTheme.Radius.md
                    )
                }
            }
            .padding(.horizontal, PoirotTheme.Spacing.xxl)
            .padding(.top, PoirotTheme.Spacing.lg)
            .padding(.bottom, PoirotTheme.Spacing.xxl)
        }
    }

    private func selectPlan(_ plan: Plan) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedPlan = plan
        }
        let detail = ConfigDetailInfo(
            name: plan.name,
            markdownContent: plan.content,
            filePath: plan.fileURL.path,
            scope: nil
        )
        appState.activeConfigDetail = detail
        appState.pushConfigDetail(navItemID: NavigationItem.plans.id, detail: detail)
    }

    private func reloadPlans() {
        plans = ClaudeConfigLoader.loadPlans()
    }
}

// MARK: - Plan Card

private struct PlanCard: View {
    let plan: Plan
    let onTap: () -> Void
    @State
    private var isHovered = false

    private var snippet: String {
        let lines = plan.content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return lines.prefix(3).joined(separator: " ")
    }

    var body: some View {
        Button { onTap() } label: {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
                Text(plan.name)
                    .font(PoirotTheme.Typography.bodyMedium)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                if !snippet.isEmpty {
                    Text(snippet)
                        .font(PoirotTheme.Typography.caption)
                        .foregroundStyle(PoirotTheme.Colors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                HStack(spacing: PoirotTheme.Spacing.sm) {
                    ConfigBadge(
                        text: plan.fileURL.lastPathComponent,
                        fg: PoirotTheme.Colors.teal,
                        bg: PoirotTheme.Colors.teal.opacity(0.15)
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(PoirotTheme.Spacing.lg)
            .cardChrome(isHovered: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
