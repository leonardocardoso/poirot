import SwiftUI

struct SessionsNavigationView: View {
    @Environment(AppState.self)
    private var appState

    @State
    private var listSearchQuery = ""

    @State
    private var collapsedProjects: Set<String> = []

    private var filteredProjects: [Project] {
        let projects = appState.filteredSortedProjects
        let trimmed = listSearchQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return projects }

        return projects.compactMap { project in
            if HighlightedText.fuzzyMatch(project.name, query: trimmed) != nil {
                return project
            }
            let matching = project.sessions.filter {
                HighlightedText.fuzzyMatch($0.title, query: trimmed) != nil
                    || HighlightedText.fuzzyMatch($0.id, query: trimmed) != nil
            }
            guard !matching.isEmpty else { return nil }
            return Project(
                id: project.id,
                name: project.name,
                path: project.path,
                sessions: matching
            )
        }
    }

    var body: some View {
        HSplitView {
            sessionsListPane
                .frame(minWidth: 220, idealWidth: 280, maxWidth: 380)

            detailPane
                .frame(minWidth: 400, idealWidth: 600)
        }
    }

    // MARK: - Sessions List Pane

    private var sessionsListPane: some View {
        VStack(spacing: 0) {
            sessionsListHeader
            sessionsListSearchBar
            Divider().opacity(0.3)

            if appState.isLoadingProjects {
                loadingState
            } else if filteredProjects.isEmpty {
                emptySearchState
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(filteredProjects) { project in
                                SessionsProjectSection(
                                    project: project,
                                    searchQuery: listSearchQuery,
                                    isCollapsed: collapsedProjects.contains(project.id),
                                    onToggleCollapse: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if collapsedProjects.contains(project.id) {
                                                collapsedProjects.remove(project.id)
                                            } else {
                                                collapsedProjects.insert(project.id)
                                            }
                                        }
                                    }
                                )
                                .id(project.id)
                            }
                        }
                        .padding(.vertical, PoirotTheme.Spacing.xs)
                    }
                    .onChange(of: appState.selectedProject) { _, newProject in
                        if let id = newProject {
                            withAnimation {
                                proxy.scrollTo(id, anchor: .top)
                            }
                        }
                    }
                }
            }
        }
        .background(PoirotTheme.Colors.bgSidebar)
    }

    private var sessionsListHeader: some View {
        HStack {
            Label("All Sessions", systemImage: "rectangle.stack.fill")
                .font(PoirotTheme.Typography.captionMedium)
                .foregroundStyle(PoirotTheme.Colors.textPrimary)

            Spacer()

            let total = filteredProjects.reduce(0) { $0 + $1.sessions.count }
            Text("\(total)")
                .font(PoirotTheme.Typography.tiny)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
                .background(
                    Capsule().fill(PoirotTheme.Colors.bgCard)
                )

            agentSessionsToggle
            refreshButton
            sortMenu
        }
        .padding(.horizontal, PoirotTheme.Spacing.md)
        .padding(.vertical, PoirotTheme.Spacing.sm)
    }

    // MARK: - Agent Sessions Toggle

    private var agentSessionsToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                appState.showAgentSessions.toggle()
            }
        } label: {
            Image(systemName: appState.showAgentSessions ? "person.2.wave.2" : "person.2")
                .font(PoirotTheme.Typography.microMedium)
                .foregroundStyle(
                    appState.showAgentSessions
                        ? PoirotTheme.Colors.accent
                        : PoirotTheme.Colors.textTertiary
                )
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .help(appState.showAgentSessions ? "Hide agent sessions" : "Show agent sessions")
    }

    // MARK: - Refresh Button

    @ViewBuilder
    private var refreshButton: some View {
        if appState.isLoadingMoreProjects {
            ProgressView()
                .controlSize(.mini)
                .tint(PoirotTheme.Colors.textTertiary)
        } else {
            Button {
                appState.refreshID = UUID()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(PoirotTheme.Typography.microMedium)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Sort Menu

    private var sortMenu: some View {
        Menu {
            ForEach(ProjectSortOption.allCases, id: \.self) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        appState.projectSortOption = option
                    }
                } label: {
                    if appState.projectSortOption == option {
                        Label(option.label, systemImage: "checkmark")
                    } else {
                        Text(option.label)
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(PoirotTheme.Typography.microMedium)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
    }

    private var sessionsListSearchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(PoirotTheme.Typography.small)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)

            TextField("Search sessions\u{2026}", text: $listSearchQuery)
                .textFieldStyle(.plain)
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textPrimary)

            if !listSearchQuery.isEmpty {
                Button {
                    listSearchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(PoirotTheme.Typography.small)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, PoirotTheme.Spacing.sm)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                .fill(PoirotTheme.Colors.bgCard)
        )
        .padding(.horizontal, PoirotTheme.Spacing.md)
        .padding(.bottom, PoirotTheme.Spacing.sm)
    }

    private var loadingState: some View {
        VStack(spacing: PoirotTheme.Spacing.sm) {
            ProgressView()
                .controlSize(.small)
                .tint(PoirotTheme.Colors.textTertiary)
            Text("Loading sessions\u{2026}")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptySearchState: some View {
        VStack(spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 24))
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                .symbolRenderingMode(.hierarchical)

            Text("No sessions found")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Detail Pane

    @ViewBuilder
    private var detailPane: some View {
        if let session = appState.selectedSession {
            if appState.isShowingFileHistory {
                FileHistoryView(session: session)
                    .transition(.opacity)
            } else if appState.isLoadingSession || (session.messages.isEmpty && session.fileURL != nil) {
                SessionSkeletonView()
                    .transition(.opacity)
            } else {
                SessionDetailView(session: session)
                    .transition(.opacity)
            }
        } else {
            noSessionSelectedState
        }
    }

    private var noSessionSelectedState: some View {
        VStack(spacing: PoirotTheme.Spacing.lg) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 48))
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                .symbolRenderingMode(.hierarchical)

            Text("Select a Session")
                .font(PoirotTheme.Typography.heading)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)

            Text("Choose a session from the list to view its content")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PoirotTheme.Colors.bgApp)
    }
}

// MARK: - Project Section

private struct SessionsProjectSection: View {
    let project: Project
    var searchQuery: String = ""
    let isCollapsed: Bool
    let onToggleCollapse: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            projectHeader

            if !isCollapsed {
                ForEach(project.sessions) { session in
                    SessionsListRow(session: session, searchQuery: searchQuery)
                }
            }
        }
    }

    private var projectHeader: some View {
        Button(action: onToggleCollapse) {
            HStack(spacing: PoirotTheme.Spacing.xs) {
                Image(systemName: "chevron.right")
                    .font(PoirotTheme.Typography.picoSemibold)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    .rotationEffect(.degrees(isCollapsed ? 0 : 90))
                    .frame(width: 12, height: 18)

                Image(systemName: "shippingbox")
                    .font(PoirotTheme.Typography.small)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    .symbolRenderingMode(.hierarchical)

                Text(project.name)
                    .font(PoirotTheme.Typography.bodyMedium)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)
                    .lineLimit(1)

                Spacer()

                Text("\(project.sessions.count)")
                    .font(PoirotTheme.Typography.tiny)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(
                        Capsule().fill(PoirotTheme.Colors.bgCard)
                    )
            }
            .padding(.horizontal, PoirotTheme.Spacing.md)
            .padding(.vertical, PoirotTheme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Session Row

private struct SessionsListRow: View {
    let session: Session
    var searchQuery: String = ""

    @Environment(AppState.self)
    private var appState

    @State
    private var isHovered = false

    private var isSelected: Bool {
        appState.selectedSession == session
    }

    var body: some View {
        Button {
            appState.selectedSession = session
        } label: {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                HStack(spacing: PoirotTheme.Spacing.xs) {
                    if session.isSidechain {
                        Image(systemName: "cpu")
                            .font(.system(size: 9))
                            .foregroundStyle(PoirotTheme.Colors.purple)
                    }

                    Text(HighlightedText.fuzzyAttributedString(session.title, query: searchQuery))
                        .font(PoirotTheme.Typography.caption)
                        .foregroundStyle(
                            isSelected
                                ? PoirotTheme.Colors.accent
                                : PoirotTheme.Colors.textPrimary
                        )
                        .lineLimit(1)

                    Spacer()

                    Text(session.timeAgo)
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }

                HStack(spacing: PoirotTheme.Spacing.xs) {
                    if let model = session.model {
                        Text(Self.formatModel(model))
                            .font(PoirotTheme.Typography.tiny)
                            .foregroundStyle(PoirotTheme.Colors.accent)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(
                                Capsule().fill(PoirotTheme.Colors.accentDim)
                            )
                    }

                    if session.totalTokens > 0 {
                        Text("\(Self.formatTokens(session.totalTokens)) tk")
                            .font(PoirotTheme.Typography.tiny)
                            .foregroundStyle(PoirotTheme.Colors.blue)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(
                                Capsule().fill(PoirotTheme.Colors.blue.opacity(0.15))
                            )
                    }

                    Text("\(session.turnCount) \(session.turnCount == 1 ? "turn" : "turns")")
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }

                if let firstPrompt = session.firstPrompt, !firstPrompt.isEmpty {
                    Text(firstPrompt)
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .padding(.horizontal, PoirotTheme.Spacing.md)
            .padding(.vertical, PoirotTheme.Spacing.sm)
            .padding(.leading, PoirotTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                    .fill(
                        isSelected
                            ? PoirotTheme.Colors.accentDim
                            : isHovered ? PoirotTheme.Colors.bgCardHover : .clear
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }

    private static func formatModel(_ model: String) -> String {
        let name = model.replacingOccurrences(of: "claude-", with: "")
        if name.hasPrefix("opus-") {
            let version = name.dropFirst("opus-".count).prefix(while: { $0 != "-" && $0 != "_" })
            return "Opus \(version)"
        } else if name.hasPrefix("sonnet-") {
            let version = name.dropFirst("sonnet-".count).prefix(while: { $0 != "-" && $0 != "_" })
            return "Sonnet \(version)"
        } else if name.hasPrefix("haiku-") {
            let version = name.dropFirst("haiku-".count).prefix(while: { $0 != "-" && $0 != "_" })
            return "Haiku \(version)"
        }
        return model
    }

    private static func formatTokens(_ count: Int) -> String {
        if count >= 1000 {
            let k = Double(count) / 1000.0
            return k.truncatingRemainder(dividingBy: 1) == 0
                ? "\(Int(k))k"
                : String(format: "%.1fk", k)
        }
        return "\(count)"
    }
}
