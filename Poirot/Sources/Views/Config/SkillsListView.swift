@preconcurrency import MarkdownUI
import SwiftUI

struct SkillsListView: View {
    let item: ConfigurationItem
    @State
    private var skills: [ClaudeSkill] = []
    @State
    private var isRevealed = false
    @State
    private var isLoaded = false
    @State
    private var selectedSkill: ClaudeSkill?
    @State
    private var filterQuery = ""

    @AppStorage("textEditor")
    private var textEditor = PreferredEditor.vscode.rawValue

    @Environment(AppState.self)
    private var appState

    private var editor: PreferredEditor {
        PreferredEditor(rawValue: textEditor) ?? .vscode
    }

    private var filteredSkills: [ClaudeSkill] {
        let q = filterQuery.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return skills }
        return skills.filter { skill in
            HighlightedText.fuzzyMatch(skill.name, query: q) != nil
                || HighlightedText.fuzzyMatch(skill.description, query: q) != nil
        }
    }

    var body: some View {
        Group {
            if let skill = selectedSkill {
                ConfigItemDetailView(
                    title: skill.name,
                    icon: "bolt.fill",
                    iconColor: PoirotTheme.Colors.accent,
                    markdownBody: skill.body,
                    filePath: skill.filePath,
                    scope: skill.scope
                ) {
                    HStack(spacing: PoirotTheme.Spacing.sm) {
                        if let model = skill.model {
                            ConfigBadge(
                                text: ConfigHelpers.formatModel(model),
                                fg: PoirotTheme.Colors.accent,
                                bg: PoirotTheme.Colors.accentDim
                            )
                        }
                        if let tools = skill.allowedTools, !tools.isEmpty {
                            let toolNames = tools.split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                            ForEach(toolNames, id: \.self) { tool in
                                ConfigBadge(
                                    text: tool,
                                    fg: PoirotTheme.Colors.blue,
                                    bg: PoirotTheme.Colors.blue.opacity(0.15)
                                )
                            }
                        }
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                listView
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .task(id: appState.activeConfigDetail?.filePath) {
            if skills.isEmpty { reloadSkills() }
            if let detail = appState.activeConfigDetail,
               selectedSkill?.filePath != detail.filePath,
               let match = skills.first(where: { $0.filePath == detail.filePath }) {
                selectedSkill = match
            }
        }
        .onChange(of: appState.activeConfigDetail) {
            if let detail = appState.activeConfigDetail {
                if selectedSkill?.filePath != detail.filePath {
                    let match = skills.first(where: { $0.filePath == detail.filePath })
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSkill = match
                    }
                }
            } else if selectedSkill != nil {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedSkill = nil
                }
                reloadSkills()
            }
        }
    }

    private var listView: some View {
        VStack(spacing: 0) {
            ConfigScreenHeader(
                item: item,
                dynamicCount: "\(skills.count) \(skills.count == 1 ? "skill" : "skills")",
                screenID: item.id,
                showLayoutToggle: true,
                showProjectPicker: true
            )

            if !skills.isEmpty {
                ConfigFilterField(searchQuery: $filterQuery)
            }

            if !isLoaded {
                ConfigSkeletonView(
                    layout: appState.configLayout(for: item.id)
                )
            } else if skills.isEmpty {
                ConfigEmptyState(
                    icon: "bolt",
                    message: "No skills found",
                    hint: "~/.claude/skills/"
                )
            } else if filteredSkills.isEmpty {
                ConfigEmptyState(
                    icon: "magnifyingglass",
                    message: "No skills match \"\(filterQuery)\"",
                    hint: "Try a different search term"
                )
            } else {
                configContent
            }
        }
        .background(PoirotTheme.Colors.bgApp)
        .task {
            reloadSkills()
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
        .onChange(of: appState.configAddTrigger) {
            createAndOpen()
        }
        .onChange(of: appState.configProjectPath) {
            reloadSkills()
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
                        ForEach(skillsForColumn(column), id: \.element.id) { index, skill in
                            SkillCard(skill: skill) {
                                selectSkill(skill)
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

    private func skillsForColumn(_ column: Int) -> [(offset: Int, element: ClaudeSkill)] {
        Array(filteredSkills.enumerated()).filter { $0.offset % 2 == column }
    }

    private var configList: some View {
        ScrollView {
            LazyVStack(spacing: PoirotTheme.Spacing.md) {
                ForEach(Array(filteredSkills.enumerated()), id: \.element.id) { index, skill in
                    SkillCard(skill: skill) {
                        selectSkill(skill)
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

    private func selectSkill(_ skill: ClaudeSkill) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedSkill = skill
        }
        let detail = ConfigDetailInfo(
            name: skill.name,
            markdownContent: skill.body,
            filePath: skill.filePath,
            scope: skill.scope
        )
        appState.activeConfigDetail = detail
        appState.pushConfigDetail(navItemID: NavigationItem.skills.id, detail: detail)
    }

    private func createAndOpen() {
        Task.detached {
            if let path = ClaudeConfigLoader.createSkillTemplate() {
                await MainActor.run {
                    EditorLauncher.open(filePath: path, editor: editor)
                    reloadSkills()
                    appState.showToast("Created new skill template", icon: "plus.circle.fill")
                }
            }
        }
    }

    private func reloadSkills() {
        skills = ClaudeConfigLoader.loadSkills(projectPath: appState.effectiveConfigProjectPath)
    }
}

// MARK: - Skill Card

private struct SkillCard: View {
    let skill: ClaudeSkill
    let onTap: () -> Void
    @State
    private var isHovered = false

    var body: some View {
        Button { onTap() } label: {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
                Text(skill.name)
                    .font(PoirotTheme.Typography.bodyMedium)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                if !skill.description.isEmpty {
                    Text(skill.description)
                        .font(PoirotTheme.Typography.caption)
                        .foregroundStyle(PoirotTheme.Colors.textSecondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }

                HStack(spacing: PoirotTheme.Spacing.sm) {
                    ConfigScopeBadge(scope: skill.scope)

                    if let model = skill.model {
                        ConfigBadge(
                            text: ConfigHelpers.formatModel(model),
                            fg: PoirotTheme.Colors.accent,
                            bg: PoirotTheme.Colors.accentDim
                        )
                    }
                    if let tools = skill.allowedTools, !tools.isEmpty {
                        ConfigBadge(
                            text: "\(tools.split(separator: ",").count) tools",
                            fg: PoirotTheme.Colors.blue,
                            bg: PoirotTheme.Colors.blue.opacity(0.15)
                        )
                    }
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
