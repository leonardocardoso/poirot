import SwiftUI

// MARK: - Search Models

private enum SearchCategory: Int, CaseIterable, Hashable {
    case sessions
    case debugLogs
    case todos
    case commands
    case skills
    case plans
    case mcpServers
    case plugins
    case outputStyles
    case models
    case subAgents

    var label: String {
        switch self {
        case .sessions: "SESSIONS"
        case .debugLogs: "DEBUG LOGS"
        case .todos: "TODOS"
        case .commands: "COMMANDS"
        case .skills: "SKILLS"
        case .plans: "PLANS"
        case .mcpServers: "MCP SERVERS"
        case .plugins: "PLUGINS"
        case .outputStyles: "OUTPUT STYLES"
        case .models: "MODELS"
        case .subAgents: "SUB-AGENTS"
        }
    }

    var navItem: NavigationItem {
        switch self {
        case .sessions: .sessions
        case .debugLogs: .sessions
        case .todos: .todos
        case .commands: .commands
        case .skills: .skills
        case .plans: .plans
        case .mcpServers: .mcpServers
        case .plugins: .plugins
        case .outputStyles: .outputStyles
        case .models: .models
        case .subAgents: .subAgents
        }
    }
}

private enum SearchAction {
    case openSession(Session, projectId: String)
    case openDebugLog(sessionId: String, projectId: String)
    case navigateTo(NavigationItem)
    case openDetail(NavigationItem, ConfigDetailInfo)
}

private struct SearchResult: Identifiable {
    let id: String
    let category: SearchCategory
    let icon: String
    let title: String
    let subtitle: String
    let trailing: String
    let score: Int
    let action: SearchAction
}

private struct SearchGroup {
    let category: SearchCategory
    let results: [SearchResult]
}

// MARK: - SearchOverlayView

struct SearchOverlayView: View {
    @Environment(AppState.self)
    private var appState
    @Environment(\.provider)
    private var provider
    @State
    private var query = ""
    @State
    private var selectedIndex = 0
    @FocusState
    private var isFocused: Bool

    // Cached config items
    @State
    private var commands: [ClaudeCommand] = []
    @State
    private var skills: [ClaudeSkill] = []
    @State
    private var plans: [Plan] = []
    @State
    private var mcpServers: [MCPServer] = []
    @State
    private var plugins: [ClaudePlugin] = []
    @State
    private var outputStyles: [OutputStyle] = []
    @State
    private var todoEntries: [(sessionId: String, todos: [SessionTodo])] = []
    @State
    private var debugLogSessionIds: Set<String> = []

    // MARK: - Search Logic

    private func matchScore(
        _ text: String, _ q: String
    ) -> Int {
        HighlightedText.fuzzyMatch(text, query: q)?.score ?? 0
    }

    private var groupedResults: [SearchGroup] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return [] }

        var all: [SearchResult] = []
        buildSessionResults(q, into: &all)
        buildDebugLogResults(q, into: &all)
        buildTodoResults(q, into: &all)
        buildCommandResults(q, into: &all)
        buildSkillResults(q, into: &all)
        buildPlanResults(q, into: &all)
        buildMCPServerResults(q, into: &all)
        buildPluginResults(q, into: &all)
        buildOutputStyleResults(q, into: &all)
        buildModelResults(q, into: &all)
        buildSubAgentResults(q, into: &all)

        let grouped = Dictionary(grouping: all) { $0.category }
        let maxPerGroup = 5
        return SearchCategory.allCases.compactMap { cat in
            guard var items = grouped[cat], !items.isEmpty
            else { return nil }
            items.sort { $0.score > $1.score }
            return SearchGroup(
                category: cat,
                results: Array(items.prefix(maxPerGroup))
            )
        }
    }

    private var flatResults: [SearchResult] {
        groupedResults.flatMap(\.results)
    }

    private func flatIndex(
        forGroup groupIdx: Int, offset: Int
    ) -> Int {
        let groups = groupedResults
        var idx = 0
        for i in 0 ..< groupIdx {
            idx += groups[i].results.count
        }
        return idx + offset
    }

    // MARK: - Session Search

    private func buildSessionResults(
        _ q: String, into results: inout [SearchResult]
    ) {
        for project in appState.projects {
            for session in project.sessions {
                let titleScore = matchScore(session.title, q)
                let projScore = matchScore(project.name, q)
                let best = max(titleScore, projScore)
                guard best > 0 else { continue }
                results.append(SearchResult(
                    id: "session-\(session.id)",
                    category: .sessions,
                    icon: "text.bubble",
                    title: session.title,
                    subtitle: project.name,
                    trailing: session.timeAgo,
                    score: best,
                    action: .openSession(
                        session, projectId: project.id
                    )
                ))
            }
        }
    }

    // MARK: - Debug Log Search

    private func buildDebugLogResults(
        _ q: String, into results: inout [SearchResult]
    ) {
        // Only show debug log results for sessions that have logs
        for project in appState.projects {
            for session in project.sessions {
                guard debugLogSessionIds.contains(session.id)
                else { continue }
                let titleScore = matchScore(session.title, q)
                let debugScore = matchScore("debug log", q)
                let best = max(titleScore, debugScore)
                guard best > 0 else { continue }
                results.append(SearchResult(
                    id: "debuglog-\(session.id)",
                    category: .debugLogs,
                    icon: "ladybug",
                    title: session.title,
                    subtitle: "Debug Log",
                    trailing: project.name,
                    score: best,
                    action: .openDebugLog(
                        sessionId: session.id,
                        projectId: project.id
                    )
                ))
            }
        }
    }

    // MARK: - Command Search

    private func buildCommandResults(
        _ q: String, into results: inout [SearchResult]
    ) {
        for cmd in commands {
            let best = max(
                matchScore(cmd.name, q),
                matchScore(cmd.description, q)
            )
            guard best > 0 else { continue }
            results.append(SearchResult(
                id: "cmd-\(cmd.id)",
                category: .commands,
                icon: NavigationItem.commands.systemImage,
                title: cmd.name,
                subtitle: cmd.description,
                trailing: cmd.argumentHint ?? "",
                score: best,
                action: .openDetail(
                    .commands,
                    ConfigDetailInfo(
                        name: cmd.name,
                        markdownContent: cmd.body,
                        filePath: cmd.filePath,
                        scope: cmd.scope
                    )
                )
            ))
        }
    }

    // MARK: - Skill Search

    private func buildSkillResults(
        _ q: String, into results: inout [SearchResult]
    ) {
        for skill in skills {
            let best = max(
                matchScore(skill.name, q),
                matchScore(skill.description, q)
            )
            guard best > 0 else { continue }
            results.append(SearchResult(
                id: "skill-\(skill.id)",
                category: .skills,
                icon: NavigationItem.skills.systemImage,
                title: skill.name,
                subtitle: skill.description,
                trailing: skill.model ?? "",
                score: best,
                action: .openDetail(
                    .skills,
                    ConfigDetailInfo(
                        name: skill.name,
                        markdownContent: skill.body,
                        filePath: skill.filePath,
                        scope: skill.scope
                    )
                )
            ))
        }
    }

    // MARK: - Plan Search

    private func buildPlanResults(
        _ q: String, into results: inout [SearchResult]
    ) {
        for plan in plans {
            let nameScore = matchScore(plan.name, q)
            let contentScore = matchScore(
                String(plan.content.prefix(200)), q
            )
            let best = max(nameScore, contentScore)
            guard best > 0 else { continue }
            results.append(SearchResult(
                id: "plan-\(plan.id)",
                category: .plans,
                icon: NavigationItem.plans.systemImage,
                title: plan.name,
                subtitle: plan.fileURL.lastPathComponent,
                trailing: "",
                score: best,
                action: .openDetail(
                    .plans,
                    ConfigDetailInfo(
                        name: plan.name,
                        markdownContent: plan.content,
                        filePath: plan.fileURL.path,
                        scope: nil
                    )
                )
            ))
        }
    }

    // MARK: - TODO Search

    private func buildTodoResults(
        _ q: String, into results: inout [SearchResult]
    ) {
        for entry in todoEntries {
            for todo in entry.todos {
                let contentScore = matchScore(todo.content, q)
                let activeScore = matchScore(todo.activeForm, q)
                let best = max(contentScore, activeScore)
                guard best > 0 else { continue }
                results.append(SearchResult(
                    id: "todo-\(entry.sessionId)-\(todo.id)",
                    category: .todos,
                    icon: NavigationItem.todos.systemImage,
                    title: todo.content,
                    subtitle: entry.sessionId,
                    trailing: todo.status.rawValue,
                    score: best,
                    action: .navigateTo(.todos)
                ))
            }
        }
    }

    // MARK: - MCP Server Search

    private func buildMCPServerResults(
        _ q: String, into results: inout [SearchResult]
    ) {
        for server in mcpServers {
            let nameScore = matchScore(server.name, q)
            let toolScore = server.tools
                .map { matchScore($0, q) }.max() ?? 0
            let best = max(nameScore, toolScore)
            guard best > 0 else { continue }
            let toolLabel = server.isWildcard
                ? "All tools"
                : "\(server.tools.count) tools"
            results.append(SearchResult(
                id: "mcp-\(server.id)",
                category: .mcpServers,
                icon: NavigationItem.mcpServers.systemImage,
                title: server.name,
                subtitle: server.tools.prefix(3)
                    .joined(separator: ", "),
                trailing: toolLabel,
                score: best,
                action: .navigateTo(.mcpServers)
            ))
        }
    }

    // MARK: - Plugin Search

    private func buildPluginResults(
        _ q: String, into results: inout [SearchResult]
    ) {
        for plugin in plugins {
            let best = max(
                matchScore(plugin.name, q),
                matchScore(plugin.author, q)
            )
            guard best > 0 else { continue }
            results.append(SearchResult(
                id: "plugin-\(plugin.id)",
                category: .plugins,
                icon: NavigationItem.plugins.systemImage,
                title: plugin.name,
                subtitle: "by \(plugin.author)",
                trailing: "v\(plugin.version)",
                score: best,
                action: .navigateTo(.plugins)
            ))
        }
    }

    // MARK: - Output Style Search

    private func buildOutputStyleResults(
        _ q: String, into results: inout [SearchResult]
    ) {
        for style in outputStyles {
            let best = max(
                matchScore(style.name, q),
                matchScore(style.description, q)
            )
            guard best > 0 else { continue }
            results.append(SearchResult(
                id: "style-\(style.id)",
                category: .outputStyles,
                icon: NavigationItem.outputStyles.systemImage,
                title: style.name,
                subtitle: style.description,
                trailing: "",
                score: best,
                action: .openDetail(
                    .outputStyles,
                    ConfigDetailInfo(
                        name: style.name,
                        markdownContent: style.body,
                        filePath: style.filePath,
                        scope: style.scope
                    )
                )
            ))
        }
    }

    // MARK: - Model Search

    private func buildModelResults(
        _ q: String, into results: inout [SearchResult]
    ) {
        for model in provider.supportedModels {
            let s = matchScore(model, q)
            guard s > 0 else { continue }
            let isDefault = model == provider.defaultModelName
            results.append(SearchResult(
                id: "model-\(model)",
                category: .models,
                icon: NavigationItem.models.systemImage,
                title: model,
                subtitle: isDefault
                    ? "Default model" : "AI Model",
                trailing: isDefault ? "Default" : "",
                score: s,
                action: .navigateTo(.models)
            ))
        }
    }

    // MARK: - Sub-agent Search

    private func buildSubAgentResults(
        _ q: String, into results: inout [SearchResult]
    ) {
        for agent in SubAgent.builtIn {
            let best = max(
                matchScore(agent.name, q),
                matchScore(agent.description, q)
            )
            guard best > 0 else { continue }
            results.append(SearchResult(
                id: "agent-\(agent.id)",
                category: .subAgents,
                icon: agent.icon,
                title: agent.name,
                subtitle: agent.description,
                trailing: "\(agent.tools.count) tools",
                score: best,
                action: .navigateTo(.subAgents)
            ))
        }
    }

    // MARK: - Empty State Data

    private var configNavItems: [NavigationItem] {
        NavigationItem.allItems.filter {
            $0.id != "sessions"
        }
    }

    private var recentSessions: [(Project, Session)] {
        Array(
            appState.projects
                .flatMap { p in p.sessions.map { (p, $0) } }
                .sorted { $0.1.startedAt > $1.1.startedAt }
                .prefix(5)
        )
    }

    private var emptyItemCount: Int {
        configNavItems.count + recentSessions.count
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 0) {
                searchInput
                Divider().opacity(0.3)
                searchResultsList
            }
            .frame(width: 580)
            .background(
                RoundedRectangle(
                    cornerRadius: PoirotTheme.Radius.lg
                )
                .fill(PoirotTheme.Colors.bgCard)
                .stroke(PoirotTheme.Colors.border)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: PoirotTheme.Radius.lg
                )
            )
            .shadow(color: .black.opacity(0.4), radius: 30)
            .padding(.top, 80)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onAppear { isFocused = true }
        .task { await loadConfigItems() }
        .onKeyPress(.escape) {
            dismiss()
            return .handled
        }
        .onKeyPress(.upArrow) {
            if selectedIndex > 0 { selectedIndex -= 1 }
            return .handled
        }
        .onKeyPress(.downArrow) {
            let maxIdx = query.isEmpty
                ? emptyItemCount - 1
                : flatResults.count - 1
            if selectedIndex < maxIdx {
                selectedIndex += 1
            }
            return .handled
        }
        .onKeyPress(.return) {
            if query.isEmpty {
                navigateEmptyState(at: selectedIndex)
            } else {
                let flat = flatResults
                guard selectedIndex < flat.count
                else { return .ignored }
                navigate(to: flat[selectedIndex])
            }
            return .handled
        }
        .onChange(of: query) { selectedIndex = 0 }
    }

    // MARK: - Search Input

    private var searchInput: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(PoirotTheme.Typography.large)
                .foregroundStyle(
                    PoirotTheme.Colors.textTertiary
                )

            TextField(
                "Search sessions, commands, plans...",
                text: $query
            )
            .textFieldStyle(.plain)
            .font(PoirotTheme.Typography.subheading)
            .foregroundStyle(PoirotTheme.Colors.textPrimary)
            .focused($isFocused)

            if !query.isEmpty {
                let count = flatResults.count
                Text("\(count) results")
                    .font(PoirotTheme.Typography.tiny)
                    .foregroundStyle(
                        PoirotTheme.Colors.textTertiary
                    )
                    .contentTransition(.numericText())
            }

            Text("ESC")
                .font(PoirotTheme.Typography.tiny)
                .foregroundStyle(
                    PoirotTheme.Colors.textTertiary
                )
                .padding(.horizontal, 6)
                .padding(.vertical, PoirotTheme.Spacing.xxs)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(PoirotTheme.Colors.bgElevated)
                )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    // MARK: - Results List

    private var searchResultsList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                    if query.isEmpty {
                        emptyStateContent
                    } else if flatResults.isEmpty {
                        noResultsView
                    } else {
                        groupedSearchResults
                    }
                }
                .padding(PoirotTheme.Spacing.sm)
            }
            .frame(maxHeight: 400)
            .onChange(of: selectedIndex) {
                proxy.scrollTo(
                    selectedIndex, anchor: .center
                )
            }
        }
    }

    // MARK: - Grouped Search Results

    private var groupedSearchResults: some View {
        let groups = groupedResults
        return ForEach(
            Array(groups.enumerated()),
            id: \.element.category
        ) { groupIdx, group in
            sectionHeader(group.category.label)

            ForEach(
                Array(group.results.enumerated()),
                id: \.element.id
            ) { offset, result in
                let idx = flatIndex(
                    forGroup: groupIdx, offset: offset
                )
                UniversalResultRow(
                    result: result,
                    query: query,
                    isSelected: idx == selectedIndex
                )
                .id(idx)
                .onTapGesture { navigate(to: result) }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateContent: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
            sectionHeader("SCREENS")

            ForEach(
                Array(configNavItems.enumerated()),
                id: \.element.id
            ) { index, navItem in
                NavShortcutRow(
                    navItem: navItem,
                    count: appState.sidebarCounts[navItem.id],
                    isSelected: index == selectedIndex
                )
                .id(index)
                .onTapGesture {
                    appState.selectedNav = navItem
                    dismiss()
                }
            }

            if !recentSessions.isEmpty {
                sectionHeader("RECENT")

                ForEach(
                    Array(recentSessions.enumerated()),
                    id: \.element.1.id
                ) { index, pair in
                    let idx = configNavItems.count + index
                    RecentSessionRow(
                        session: pair.1,
                        projectName: pair.0.name,
                        isSelected: idx == selectedIndex
                    )
                    .id(idx)
                    .onTapGesture {
                        appState.selectedProject = pair.0.id
                        appState.selectedSession = pair.1
                        appState.selectedNav = .sessions
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - No Results

    private var noResultsView: some View {
        VStack(spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 24))
                .foregroundStyle(
                    PoirotTheme.Colors.textTertiary
                )
            Text("No results for \"\(query)\"")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(
                    PoirotTheme.Colors.textTertiary
                )
        }
        .frame(maxWidth: .infinity)
        .padding(PoirotTheme.Spacing.xl)
    }

    // MARK: - Section Header

    private func sectionHeader(
        _ title: String
    ) -> some View {
        Text(title)
            .font(PoirotTheme.Typography.sectionHeader)
            .foregroundStyle(
                PoirotTheme.Colors.textTertiary
            )
            .tracking(0.5)
            .padding(.horizontal, 10)
            .padding(.top, PoirotTheme.Spacing.sm)
            .padding(.bottom, PoirotTheme.Spacing.xxs)
    }

    // MARK: - Actions

    private func dismiss() {
        @Bindable
        var state = appState
        state.isSearchPresented = false
    }

    private func navigate(to result: SearchResult) {
        switch result.action {
        case let .openSession(session, projectId):
            appState.selectedProject = projectId
            appState.selectedSession = session
            appState.selectedNav = .sessions

        case let .openDebugLog(sessionId, projectId):
            appState.selectedProject = projectId
            appState.selectedNav = .sessions
            appState.showDebugLogSessionId = sessionId

        case let .navigateTo(navItem):
            appState.selectedNav = navItem

        case let .openDetail(navItem, detail):
            appState.selectedNav = navItem
            appState.activeConfigDetail = detail
            appState.pushConfigDetail(
                navItemID: navItem.id, detail: detail
            )
        }
        dismiss()
    }

    private func navigateEmptyState(at index: Int) {
        let navItems = configNavItems
        if index < navItems.count {
            appState.selectedNav = navItems[index]
            dismiss()
        } else {
            let sessionIdx = index - navItems.count
            let recent = recentSessions
            guard sessionIdx < recent.count
            else { return }
            let (project, session) = recent[sessionIdx]
            appState.selectedProject = project.id
            appState.selectedSession = session
            appState.selectedNav = .sessions
            dismiss()
        }
    }

    private func loadConfigItems() async {
        let projectPath = appState.effectiveConfigProjectPath
        let result = await Task.detached {
            (
                ClaudeConfigLoader.loadCommands(projectPath: projectPath),
                ClaudeConfigLoader.loadSkills(projectPath: projectPath),
                ClaudeConfigLoader.loadPlans(),
                ClaudeConfigLoader.loadMCPServers(projectPath: projectPath),
                ClaudeConfigLoader.loadPlugins(),
                ClaudeConfigLoader.loadOutputStyles(projectPath: projectPath),
                TodoLoader().loadAllTodos(),
                Set(DebugLogLoader().allSessionIds())
            )
        }.value
        commands = result.0
        skills = result.1
        plans = result.2
        mcpServers = result.3
        plugins = result.4
        outputStyles = result.5
        let allTodos = result.6
        todoEntries = allTodos.filter { !$0.value.isEmpty }
            .map { (sessionId: $0.key, todos: $0.value) }
        debugLogSessionIds = result.7
    }
}

// MARK: - Universal Result Row

private struct UniversalResultRow: View {
    let result: SearchResult
    let query: String
    let isSelected: Bool

    @State
    private var isHovered = false

    var body: some View {
        HStack(spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: result.icon)
                .font(PoirotTheme.Typography.small)
                .foregroundStyle(
                    PoirotTheme.Colors.textTertiary
                )
                .frame(width: 20)

            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                Text(
                    HighlightedText.fuzzyAttributedString(
                        result.title, query: query
                    )
                )
                .font(PoirotTheme.Typography.captionMedium)
                .foregroundStyle(
                    PoirotTheme.Colors.textPrimary
                )
                .lineLimit(1)

                if !result.subtitle.isEmpty {
                    Text(result.subtitle)
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(
                            PoirotTheme.Colors.textTertiary
                        )
                        .lineLimit(1)
                }
            }

            Spacer()

            if !result.trailing.isEmpty {
                Text(result.trailing)
                    .font(PoirotTheme.Typography.tiny)
                    .foregroundStyle(
                        PoirotTheme.Colors.textTertiary
                    )
            }

            if isSelected {
                Text("↵")
                    .font(PoirotTheme.Typography.tiny)
                    .foregroundStyle(
                        PoirotTheme.Colors.textTertiary
                    )
                    .padding(.horizontal, PoirotTheme.Spacing.xs)
                    .padding(.vertical, 1)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.xs)
                            .fill(
                                PoirotTheme.Colors
                                    .bgElevated
                            )
                    )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, PoirotTheme.Spacing.sm)
        .background(
            RoundedRectangle(
                cornerRadius: PoirotTheme.Radius.sm
            )
            .fill(
                isSelected || isHovered
                    ? PoirotTheme.Colors.bgElevated
                    : .clear
            )
        )
        .onHover { isHovered = $0 }
    }
}

// MARK: - Navigation Shortcut Row

private struct NavShortcutRow: View {
    let navItem: NavigationItem
    let count: Int?
    let isSelected: Bool

    @State
    private var isHovered = false

    var body: some View {
        HStack(spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: navItem.systemImage)
                .font(PoirotTheme.Typography.small)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(PoirotTheme.Colors.accent)
                .frame(width: 20)

            Text(navItem.title)
                .font(PoirotTheme.Typography.captionMedium)
                .foregroundStyle(
                    PoirotTheme.Colors.textPrimary
                )

            Spacer()

            if let count {
                Text("\(count)")
                    .font(PoirotTheme.Typography.tiny)
                    .foregroundStyle(
                        PoirotTheme.Colors.textTertiary
                    )
            }

            Image(systemName: "chevron.right")
                .font(PoirotTheme.Typography.nanoSemibold)
                .foregroundStyle(
                    PoirotTheme.Colors.textTertiary
                )

            if isSelected {
                Text("↵")
                    .font(PoirotTheme.Typography.tiny)
                    .foregroundStyle(
                        PoirotTheme.Colors.textTertiary
                    )
                    .padding(.horizontal, PoirotTheme.Spacing.xs)
                    .padding(.vertical, 1)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.xs)
                            .fill(
                                PoirotTheme.Colors
                                    .bgElevated
                            )
                    )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, PoirotTheme.Spacing.sm)
        .background(
            RoundedRectangle(
                cornerRadius: PoirotTheme.Radius.sm
            )
            .fill(
                isSelected || isHovered
                    ? PoirotTheme.Colors.bgElevated
                    : .clear
            )
        )
        .onHover { isHovered = $0 }
    }
}

// MARK: - Recent Session Row

private struct RecentSessionRow: View {
    let session: Session
    let projectName: String
    let isSelected: Bool

    @State
    private var isHovered = false

    var body: some View {
        HStack(spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: "text.bubble")
                .font(PoirotTheme.Typography.small)
                .foregroundStyle(
                    PoirotTheme.Colors.textTertiary
                )
                .frame(width: 20)

            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                Text(session.title)
                    .font(
                        PoirotTheme.Typography.captionMedium
                    )
                    .foregroundStyle(
                        PoirotTheme.Colors.textPrimary
                    )
                    .lineLimit(1)

                Text(projectName)
                    .font(PoirotTheme.Typography.tiny)
                    .foregroundStyle(
                        PoirotTheme.Colors.textTertiary
                    )
                    .lineLimit(1)
            }

            Spacer()

            Text(session.timeAgo)
                .font(PoirotTheme.Typography.tiny)
                .foregroundStyle(
                    PoirotTheme.Colors.textTertiary
                )

            if isSelected {
                Text("↵")
                    .font(PoirotTheme.Typography.tiny)
                    .foregroundStyle(
                        PoirotTheme.Colors.textTertiary
                    )
                    .padding(.horizontal, PoirotTheme.Spacing.xs)
                    .padding(.vertical, 1)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.xs)
                            .fill(
                                PoirotTheme.Colors
                                    .bgElevated
                            )
                    )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, PoirotTheme.Spacing.sm)
        .background(
            RoundedRectangle(
                cornerRadius: PoirotTheme.Radius.sm
            )
            .fill(
                isSelected || isHovered
                    ? PoirotTheme.Colors.bgElevated
                    : .clear
            )
        )
        .onHover { isHovered = $0 }
    }
}
