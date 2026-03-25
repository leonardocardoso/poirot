import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self)
    private var appState
    @Environment(\.provider)
    private var provider
    @AppStorage("accentColor")
    private var accentColorRaw = AccentColor.golden.rawValue
    @AppStorage("colorTheme")
    private var colorThemeRaw = ColorTheme.default.rawValue
    @AppStorage("configNavCollapsed")
    private var configNavCollapsed = false
    @State
    private var isCollapseBarHovered = false
    var body: some View {
        VStack(spacing: 0) {
            navigationItems
            sidebarSearchBar
            projectsList
            Spacer()
        }
        .background {
            Color.clear
        }
    }

    // MARK: - Navigation

    private var mainNavItems: [NavigationItem] {
        provider.navigationItems.filter { $0.section == .main }
    }

    private var configNavItems: [NavigationItem] {
        provider.navigationItems.filter { $0.section == .config }
    }

    private var navigationItems: some View {
        Group {
            VStack(spacing: PoirotTheme.Spacing.xxs) {
                ForEach(Array(mainNavItems.enumerated()), id: \.element.id) { index, item in
                    navItemButton(for: item, index: index)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if !configNavItems.isEmpty {
                    if !configNavCollapsed {
                        let mainCount = mainNavItems.count
                        ForEach(Array(configNavItems.enumerated()), id: \.element.id) { index, item in
                            navItemButton(for: item, index: mainCount + index)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }

                    configCollapseToggle
                        .padding(.top, PoirotTheme.Spacing.xs)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.smooth, value: configNavCollapsed)
        }
        .animation(.smooth, value: configNavCollapsed)
        .padding(PoirotTheme.Spacing.md)
        .task {
            await recomputeSidebarCounts()
        }
        .onChange(of: appState.configProjectPath) {
            Task { await recomputeSidebarCounts() }
        }
    }

    private func navItemButton(for item: NavigationItem, index: Int) -> some View {
        @Bindable
        var state = appState
        let isKeyboardSelected = appState.sidebarKeyboardIndex == index
        return Button {
            state.selectedNav = item
        } label: {
            HStack(alignment: .firstTextBaseline) {
                Label(item.title, systemImage: item.systemImage)

                Spacer()

                if let count = appState.sidebarCounts[item.id] {
                    Text("\(count)")
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(
                            Capsule().fill(PoirotTheme.Colors.bgCard)
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(NavItemButtonStyle(
            isActive: appState.selectedNav == item,
            isKeyboardSelected: isKeyboardSelected
        ))
    }

    private var configCollapseToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                configNavCollapsed.toggle()
            }
        } label: {
            Image(systemName: configNavCollapsed ? "chevron.compact.down" : "chevron.compact.up")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(
                    isCollapseBarHovered
                        ? PoirotTheme.Colors.accent
                        : PoirotTheme.Colors.textTertiary
                )
                .contentTransition(.symbolEffect(.replace))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                        .fill(
                            isCollapseBarHovered
                                ? PoirotTheme.Colors.accentDim
                                : PoirotTheme.Colors.bgCard
                        )
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isCollapseBarHovered = $0 }
        .help(configNavCollapsed ? "Show more" : "Show less")
    }

    private func recomputeSidebarCounts() async {
        let modelsCount = provider.supportedModels.count
        let projectPath = appState.effectiveConfigProjectPath
        let counts = await Task.detached {
            AppState.computeSidebarCounts(
                supportedModelsCount: modelsCount,
                projectPath: projectPath
            )
        }.value
        appState.sidebarCounts = counts
    }

    // MARK: - Search Bar

    private var sidebarSearchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(PoirotTheme.Typography.small)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)

            @Bindable
            var state = appState
            TextField("Search projects...", text: $state.sidebarSearchQuery)
                .textFieldStyle(.plain)
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textPrimary)

            if !appState.sidebarSearchQuery.isEmpty {
                Button {
                    appState.sidebarSearchQuery = ""
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
    }

    // MARK: - Projects List

    private var projectsList: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            HStack(spacing: PoirotTheme.Spacing.sm) {
                Text("PROJECTS")
                    .font(PoirotTheme.Typography.sectionHeader)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    .tracking(0.5)

                if !appState.isLoadingProjects {
                    Text("\(appState.filteredSortedProjects.count)")
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            Capsule()
                                .fill(PoirotTheme.Colors.bgCard)
                        )
                }

                if appState.isLoadingMoreProjects {
                    ProgressView()
                        .controlSize(.mini)
                        .tint(PoirotTheme.Colors.textTertiary)
                }

                Spacer()

                agentSessionsToggle
                refreshButton
                sortMenu
            }
            .padding(.horizontal, PoirotTheme.Spacing.md)

            ScrollView {
                if appState.isLoadingProjects {
                    projectsSkeletonRows
                        .transition(.opacity)
                } else {
                    LazyVStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                        ForEach(appState.filteredSortedProjects) { project in
                            ProjectRow(project: project, highlightQuery: appState.sidebarSearchQuery)
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: appState.filteredSortedProjects.map(\.id))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.isLoadingProjects)
        }
        .padding(.top, PoirotTheme.Spacing.lg)
    }

    // MARK: - Refresh Button

    private var refreshButton: some View {
        Button {
            appState.refreshID = UUID()
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(PoirotTheme.Typography.microMedium)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                .symbolEffect(.rotate, value: appState.isLoadingMoreProjects)
        }
        .buttonStyle(.plain)
        .disabled(appState.isLoadingMoreProjects)
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

    // MARK: - Skeleton

    private var projectsSkeletonRows: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.lg) {
            ForEach(0 ..< 5, id: \.self) { groupIndex in
                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                    // Project name placeholder
                    sidebarSkeletonRect(
                        width: Self.projectNameWidths[groupIndex],
                        height: 13
                    )
                    .padding(.vertical, PoirotTheme.Spacing.xs)
                    .padding(.horizontal, PoirotTheme.Spacing.md)

                    // Session row placeholders
                    ForEach(0 ..< Self.sessionCounts[groupIndex], id: \.self) { rowIndex in
                        HStack {
                            sidebarSkeletonRect(
                                width: Self.sessionTitleWidths[groupIndex][rowIndex],
                                height: 11
                            )
                            Spacer()
                            sidebarSkeletonRect(width: 40, height: 9)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, PoirotTheme.Spacing.md)
                        .padding(.leading, PoirotTheme.Spacing.lg)
                    }
                }
            }
        }
    }

    private func sidebarSkeletonRect(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(PoirotTheme.Colors.bgCard)
            .frame(width: width, height: height)
            .shimmer(cornerRadius: 4)
    }

    // Fixed widths to avoid re-render jitter
    private static let projectNameWidths: [CGFloat] = [100, 80, 110, 90, 105]
    private static let sessionCounts = [4, 3, 5, 2, 4]
    private static let sessionTitleWidths: [[CGFloat]] = [
        [140, 110, 130, 100],
        [120, 150, 135],
        [130, 100, 145, 115, 125],
        [140, 110],
        [125, 135, 105, 145],
    ]
}

// MARK: - Project Row

private struct ProjectRow: View {
    let project: Project
    var highlightQuery: String = ""
    @Environment(AppState.self)
    private var appState
    @AppStorage("accentColor")
    private var accentColorRaw = AccentColor.golden.rawValue
    @AppStorage("colorTheme")
    private var colorThemeRaw = ColorTheme.default.rawValue
    @State
    private var isHovered = false
    @State
    private var isMenuPresented = false
    @State
    private var isConfirmingDelete = false
    @State
    private var isExpanded = true

    private var isSelected: Bool {
        appState.selectedProject == project.id
    }

    private var showSessions: Bool {
        isExpanded || !highlightQuery.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
            HStack(alignment: .top, spacing: PoirotTheme.Spacing.xs) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(PoirotTheme.Typography.picoSemibold)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .frame(width: 12, height: 18)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button {
                    appState.selectedNav = .sessions
                    appState.selectedSession = nil
                    appState.selectedProject = project.id
                } label: {
                    HStack {
                        Label {
                            Text(HighlightedText.fuzzyAttributedString(project.name, query: highlightQuery))
                        } icon: {
                            Image(systemName: "shippingbox")
                        }
                        .font(PoirotTheme.Typography.captionMedium)
                        .foregroundStyle(isSelected ? PoirotTheme.Colors.accent : PoirotTheme.Colors.textPrimary)

                        Spacer(minLength: PoirotTheme.Spacing.sm)

                        ZStack {
                            Text("\(project.sessions.count)")
                                .font(PoirotTheme.Typography.tiny)
                                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                                .opacity(isHovered || isMenuPresented ? 0 : 1)

                            projectMenu
                                .opacity(isHovered || isMenuPresented ? 1 : 0)
                        }
                        .fixedSize()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, PoirotTheme.Spacing.xs)
            .padding(.horizontal, PoirotTheme.Spacing.md)
            .onHover { hovering in
                isHovered = hovering
                if !hovering, !isMenuPresented {
                    isConfirmingDelete = false
                }
            }

            if showSessions {
                ForEach(project.sessions) { session in
                    SessionRow(session: session, highlightQuery: highlightQuery)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var projectMenu: some View {
        Button {
            isMenuPresented = true
        } label: {
            Image(systemName: "ellipsis")
                .font(PoirotTheme.Typography.microBold)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, PoirotTheme.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                        .fill(PoirotTheme.Colors.bgCard)
                )
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isMenuPresented, arrowEdge: .trailing) {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                PopoverMenuItem(
                    label: "Copy Folder Name",
                    systemImage: "doc.on.doc"
                ) {
                    let url = appState.projectDirectoryURL(for: project)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(url.lastPathComponent, forType: .string)
                    isMenuPresented = false
                }

                PopoverMenuItem(
                    label: "Show in Finder",
                    systemImage: "folder"
                ) {
                    let url = appState.projectDirectoryURL(for: project)
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                    isMenuPresented = false
                }

                Divider()
                    .padding(.horizontal, PoirotTheme.Spacing.sm)
                    .padding(.vertical, PoirotTheme.Spacing.xxs)

                PopoverMenuItem(
                    label: isConfirmingDelete ? "Confirm Delete" : "Delete",
                    systemImage: isConfirmingDelete ? "checkmark" : "trash",
                    foreground: PoirotTheme.Colors.red
                ) {
                    if isConfirmingDelete {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            appState.deleteProject(project)
                        }
                        isMenuPresented = false
                        isConfirmingDelete = false
                    } else {
                        isConfirmingDelete = true
                    }
                }
            }
            .padding(6)
            .frame(width: 190)
        }
        .onChange(of: isMenuPresented) { _, presented in
            if !presented {
                isConfirmingDelete = false
            }
        }
    }
}

// MARK: - Session Row

private struct SessionRow: View {
    let session: Session
    var highlightQuery: String = ""
    @Environment(AppState.self)
    private var appState
    @Environment(\.provider)
    private var provider
    @AppStorage("accentColor")
    private var accentColorRaw = AccentColor.golden.rawValue
    @AppStorage("colorTheme")
    private var colorThemeRaw = ColorTheme.default.rawValue
    @State
    private var isHovered = false
    @State
    private var isMenuPresented = false
    @State
    private var isConfirmingDelete = false

    var body: some View {
        @Bindable
        var state = appState
        Button {
            state.selectedNav = .sessions
            guard state.selectedSession?.id != session.id else { return }
            state.selectedSession = session
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: PoirotTheme.Spacing.xs) {
                    if session.isSidechain {
                        Image(systemName: "cpu")
                            .font(.system(size: 9))
                            .foregroundStyle(PoirotTheme.Colors.purple)
                    }

                    MarqueeText(
                        text: session.title,
                        font: PoirotTheme.Typography.caption,
                        highlightQuery: highlightQuery
                    )
                    .foregroundStyle(
                        session.isSidechain
                            ? PoirotTheme.Colors.textTertiary
                            : PoirotTheme.Colors.textSecondary
                    )

                    Spacer()

                    if isHovered || isMenuPresented {
                        sessionMenu
                            .transition(.opacity)
                    } else {
                        Text(session.timeAgo)
                            .font(PoirotTheme.Typography.tiny)
                            .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    }
                }

                if session.isSidechain, let agentId = session.agentId {
                    Text(agentId)
                        .font(.system(size: 9))
                        .foregroundStyle(PoirotTheme.Colors.purple)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            Capsule().fill(PoirotTheme.Colors.purple.opacity(0.15))
                        )
                } else if let firstPrompt = session.firstPrompt, !firstPrompt.isEmpty {
                    Text(firstPrompt)
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, PoirotTheme.Spacing.md)
            .padding(.leading, PoirotTheme.Spacing.lg)
            .contentShape(Rectangle())
        }
        .buttonStyle(SessionItemButtonStyle(isActive: appState.selectedSession == session))
        .onHover { hovering in
            isHovered = hovering
            if !hovering, !isMenuPresented {
                isConfirmingDelete = false
            }
        }
    }

    private var sessionMenu: some View {
        Button {
            isMenuPresented = true
        } label: {
            Image(systemName: "ellipsis")
                .font(PoirotTheme.Typography.microBold)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, PoirotTheme.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                        .fill(PoirotTheme.Colors.bgCard)
                )
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isMenuPresented, arrowEdge: .trailing) {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                PopoverMenuItem(
                    label: "Resume",
                    systemImage: "arrow.uturn.forward"
                ) {
                    Self.openTerminalWithResume(
                        cliPath: provider.cliPath,
                        sessionId: session.id,
                        projectPath: session.projectPath
                    )
                    isMenuPresented = false
                }

                if let url = session.fileURL {
                    PopoverMenuItem(
                        label: "Copy File Name",
                        systemImage: "doc.on.doc"
                    ) {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(url.lastPathComponent, forType: .string)
                        isMenuPresented = false
                    }

                    PopoverMenuItem(
                        label: "Show in Finder",
                        systemImage: "folder"
                    ) {
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                        isMenuPresented = false
                    }
                }

                Divider()
                    .padding(.horizontal, PoirotTheme.Spacing.sm)
                    .padding(.vertical, PoirotTheme.Spacing.xxs)

                PopoverMenuItem(
                    label: isConfirmingDelete ? "Confirm Delete" : "Delete",
                    systemImage: isConfirmingDelete ? "checkmark" : "trash",
                    foreground: PoirotTheme.Colors.red
                ) {
                    if isConfirmingDelete {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            appState.deleteSession(session)
                        }
                        isMenuPresented = false
                        isConfirmingDelete = false
                    } else {
                        isConfirmingDelete = true
                    }
                }
            }
            .padding(6)
            .frame(width: 190)
        }
        .onChange(of: isMenuPresented) { _, presented in
            if !presented {
                isConfirmingDelete = false
            }
        }
    }

    private static func openTerminalWithResume(
        cliPath: String,
        sessionId: String,
        projectPath: String
    ) {
        let command = "cd \(projectPath.shellEscaped) && \(cliPath) --resume \(sessionId)"
        TerminalLauncher.launch(command: command, clipboardText: "\(cliPath) --resume \(sessionId)")
    }
}

// MARK: - Popover Menu Item

private struct PopoverMenuItem: View {
    let label: String
    let systemImage: String
    var foreground: Color = PoirotTheme.Colors.textSecondary
    let action: () -> Void

    @State
    private var isItemHovered = false

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: systemImage)
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
                .padding(.horizontal, PoirotTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                        .fill(isItemHovered ? PoirotTheme.Colors.bgCardHover : .clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isItemHovered = $0 }
    }
}

// MARK: - Button Styles

private struct NavItemButtonStyle: ButtonStyle {
    let isActive: Bool
    var isKeyboardSelected: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PoirotTheme.Typography.captionMedium)
            .foregroundStyle(isActive ? PoirotTheme.Colors.accent : PoirotTheme.Colors.textSecondary)
            .padding(.vertical, 6)
            .padding(.horizontal, PoirotTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                    .fill(isActive ? PoirotTheme.Colors.accentDim : .clear)
            )
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                    .strokeBorder(
                        PoirotTheme.Colors.accent.opacity(isKeyboardSelected ? 0.5 : 0),
                        lineWidth: 1
                    )
            )
    }
}

private struct SessionItemButtonStyle: ButtonStyle {
    let isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isActive ? PoirotTheme.Colors.accent : PoirotTheme.Colors.textSecondary)
            .background(
                RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                    .fill(isActive ? PoirotTheme.Colors.accentDim : .clear)
            )
    }
}
