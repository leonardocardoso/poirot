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
    @State
    private var filterQuery = ""
    @State
    private var fileWatcher: FileWatcher?

    @Environment(AppState.self)
    private var appState

    private var filteredPlans: [Plan] {
        let q = filterQuery.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return plans }
        return plans.filter { plan in
            HighlightedText.fuzzyMatch(plan.name, query: q) != nil
                || HighlightedText.fuzzyMatch(String(plan.content.prefix(200)), query: q) != nil
        }
    }

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

            if !plans.isEmpty {
                ConfigFilterField(searchQuery: $filterQuery)
            }

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
            } else if filteredPlans.isEmpty {
                ConfigEmptyState(
                    icon: "magnifyingglass",
                    message: "No plans match \"\(filterQuery)\"",
                    hint: "Try a different search term"
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
        .onAppear {
            guard fileWatcher == nil else { return }
            let plansPath = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".claude/plans").path
            let watcher = FileWatcher { [weak appState] in
                reloadPlans()
                appState?.sidebarCounts[NavigationItem.plans.id] = plans.count
            }
            watcher.start(path: plansPath)
            fileWatcher = watcher
        }
        .onDisappear {
            fileWatcher?.stop()
            fileWatcher = nil
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
                            PlanCard(
                                plan: plan,
                                onTap: { selectPlan(plan) },
                                onDelete: { deletePlan(plan) }
                            )
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
        Array(filteredPlans.enumerated()).filter { $0.offset % 2 == column }
    }

    private var configList: some View {
        ScrollView {
            LazyVStack(spacing: PoirotTheme.Spacing.md) {
                ForEach(Array(filteredPlans.enumerated()), id: \.element.id) { index, plan in
                    PlanCard(
                        plan: plan,
                        onTap: { selectPlan(plan) },
                        onDelete: { deletePlan(plan) }
                    )
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

    private func deletePlan(_ plan: Plan) {
        if ClaudeConfigLoader.deleteConfigFile(at: plan.fileURL.path) {
            withAnimation(.easeOut(duration: 0.25)) {
                plans.removeAll { $0.id == plan.id }
            }
            appState.showToast("Deleted \(plan.name)", icon: "trash", style: .info)
            syncSidebarCount()
        }
    }

    private func syncSidebarCount() {
        appState.sidebarCounts[NavigationItem.plans.id] = plans.count
    }

    private func reloadPlans() {
        plans = ClaudeConfigLoader.loadPlans()
    }
}

// MARK: - Plan Card

private struct PlanCard: View {
    let plan: Plan
    let onTap: () -> Void
    let onDelete: () -> Void
    @State
    private var isHovered = false
    @State
    private var showDeleteConfirmation = false
    @State
    private var copyTapped = false

    @Environment(AppState.self)
    private var appState

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

                    Spacer()

                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(plan.content, forType: .string)
                        appState.showToast("Copied content to clipboard")
                        copyTapped = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copyTapped = false }
                    } label: {
                        Image(systemName: copyTapped ? "checkmark" : "doc.on.doc")
                            .font(PoirotTheme.Typography.tiny)
                            .foregroundStyle(PoirotTheme.Colors.textTertiary)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                    .help("Copy Content")

                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .font(PoirotTheme.Typography.tiny)
                            .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .help("Delete Plan")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(PoirotTheme.Spacing.lg)
            .cardChrome(isHovered: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .confirmationDialog(
            "Delete \(plan.name)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This will permanently delete the file. This action cannot be undone.")
        }
    }
}
