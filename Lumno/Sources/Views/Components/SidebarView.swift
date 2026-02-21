import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self)
    private var appState
    @Environment(\.provider)
    private var provider

    var body: some View {
        VStack(spacing: 0) {
            navigationItems
            sidebarSearchBar
            projectsList
            Spacer()
            footer
        }
        .background(LumnoTheme.Colors.bgSidebar)
    }

    // MARK: - Navigation

    private var navigationItems: some View {
        VStack(spacing: 2) {
            ForEach(provider.navigationItems) { item in
                @Bindable
                var state = appState
                Button {
                    state.selectedNav = item
                } label: {
                    Label(item.title, systemImage: item.systemImage)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(NavItemButtonStyle(isActive: appState.selectedNav == item))
            }
        }
        .padding(LumnoTheme.Spacing.md)
    }

    // MARK: - Search Bar

    private var sidebarSearchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundStyle(LumnoTheme.Colors.textTertiary)

            @Bindable
            var state = appState
            TextField("Search projects...", text: $state.sidebarSearchQuery)
                .textFieldStyle(.plain)
                .font(LumnoTheme.Typography.caption)
                .foregroundStyle(LumnoTheme.Colors.textPrimary)

            if !appState.sidebarSearchQuery.isEmpty {
                Button {
                    appState.sidebarSearchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                .fill(LumnoTheme.Colors.bgCard)
        )
        .padding(.horizontal, LumnoTheme.Spacing.md)
    }

    // MARK: - Projects List

    private var projectsList: some View {
        VStack(alignment: .leading, spacing: LumnoTheme.Spacing.sm) {
            HStack(spacing: LumnoTheme.Spacing.sm) {
                Text("PROJECTS")
                    .font(LumnoTheme.Typography.sectionHeader)
                    .foregroundStyle(LumnoTheme.Colors.textTertiary)
                    .tracking(0.5)

                if !appState.isLoadingProjects {
                    Text("\(appState.filteredSortedProjects.count)")
                        .font(LumnoTheme.Typography.tiny)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            Capsule()
                                .fill(LumnoTheme.Colors.bgCard)
                        )
                }

                if appState.isLoadingMoreProjects {
                    ProgressView()
                        .controlSize(.mini)
                        .tint(LumnoTheme.Colors.textTertiary)
                }

                Spacer()

                refreshButton
                sortMenu
            }
            .padding(.horizontal, LumnoTheme.Spacing.md)

            ScrollView {
                if appState.isLoadingProjects {
                    projectsSkeletonRows
                        .transition(.opacity)
                } else {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(appState.filteredSortedProjects) { project in
                            ProjectRow(project: project)
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: appState.filteredSortedProjects.map(\.id))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.isLoadingProjects)
        }
        .padding(.top, LumnoTheme.Spacing.lg)
    }

    // MARK: - Refresh Button

    private var refreshButton: some View {
        Button {
            appState.refreshID = UUID()
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(LumnoTheme.Colors.textTertiary)
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
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(LumnoTheme.Colors.textTertiary)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
    }

    // MARK: - Skeleton

    private var projectsSkeletonRows: some View {
        VStack(alignment: .leading, spacing: LumnoTheme.Spacing.lg) {
            ForEach(0 ..< 5, id: \.self) { groupIndex in
                VStack(alignment: .leading, spacing: 2) {
                    // Project name placeholder
                    sidebarSkeletonRect(
                        width: Self.projectNameWidths[groupIndex],
                        height: 13
                    )
                    .padding(.vertical, 4)
                    .padding(.horizontal, LumnoTheme.Spacing.md)

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
                        .padding(.horizontal, LumnoTheme.Spacing.md)
                        .padding(.leading, LumnoTheme.Spacing.lg)
                    }
                }
            }
        }
    }

    private func sidebarSkeletonRect(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(LumnoTheme.Colors.bgCard)
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

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Button {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            } label: {
                Label("Settings", systemImage: "gearshape")
                    .font(LumnoTheme.Typography.caption)
                    .foregroundStyle(LumnoTheme.Colors.textSecondary)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("v0.1.0")
                .font(LumnoTheme.Typography.tiny)
                .foregroundStyle(LumnoTheme.Colors.accent)
        }
        .padding(LumnoTheme.Spacing.md)
        .overlay(alignment: .top) {
            Divider().opacity(0.3)
        }
    }
}

// MARK: - Project Row

private struct ProjectRow: View {
    let project: Project
    @Environment(AppState.self)
    private var appState
    @State
    private var isHovered = false
    @State
    private var isMenuPresented = false
    @State
    private var isConfirmingDelete = false

    private var isSelected: Bool {
        appState.selectedProject == project.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Button {
                appState.selectedNav = .sessions
                appState.selectedSession = nil
                appState.selectedProject = project.id
            } label: {
                HStack {
                    Label(project.name, systemImage: "shippingbox")
                        .font(LumnoTheme.Typography.captionMedium)
                        .foregroundStyle(isSelected ? LumnoTheme.Colors.accent : LumnoTheme.Colors.textPrimary)

                    Spacer(minLength: LumnoTheme.Spacing.sm)

                    ZStack {
                        Text("\(project.sessions.count)")
                            .font(LumnoTheme.Typography.tiny)
                            .foregroundStyle(LumnoTheme.Colors.textTertiary)
                            .opacity(isHovered || isMenuPresented ? 0 : 1)

                        projectMenu
                            .opacity(isHovered || isMenuPresented ? 1 : 0)
                    }
                    .fixedSize()
                }
                .padding(.vertical, 4)
                .padding(.horizontal, LumnoTheme.Spacing.md)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isHovered = hovering
                if !hovering, !isMenuPresented {
                    isConfirmingDelete = false
                }
            }

            ForEach(project.sessions) { session in
                SessionRow(session: session)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var projectMenu: some View {
        Button {
            isMenuPresented = true
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(LumnoTheme.Colors.textTertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                        .fill(LumnoTheme.Colors.bgCard)
                )
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isMenuPresented, arrowEdge: .trailing) {
            VStack(alignment: .leading, spacing: 2) {
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
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)

                PopoverMenuItem(
                    label: isConfirmingDelete ? "Confirm Delete" : "Delete",
                    systemImage: isConfirmingDelete ? "checkmark" : "trash",
                    foreground: LumnoTheme.Colors.red
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
    @Environment(AppState.self)
    private var appState
    @Environment(\.provider)
    private var provider
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
            state.selectedSession = session
        } label: {
            HStack {
                Text(session.title)
                    .lineLimit(1)
                    .font(LumnoTheme.Typography.caption)

                Spacer()

                if isHovered || isMenuPresented {
                    sessionMenu
                        .transition(.opacity)
                } else {
                    Text(session.timeAgo)
                        .font(LumnoTheme.Typography.tiny)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, LumnoTheme.Spacing.md)
            .padding(.leading, LumnoTheme.Spacing.lg)
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
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(LumnoTheme.Colors.textTertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                        .fill(LumnoTheme.Colors.bgCard)
                )
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isMenuPresented, arrowEdge: .trailing) {
            VStack(alignment: .leading, spacing: 2) {
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
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)

                PopoverMenuItem(
                    label: isConfirmingDelete ? "Confirm Delete" : "Delete",
                    systemImage: isConfirmingDelete ? "checkmark" : "trash",
                    foreground: LumnoTheme.Colors.red
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
    var foreground: Color = LumnoTheme.Colors.textSecondary
    let action: () -> Void

    @State
    private var isItemHovered = false

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: systemImage)
                .font(LumnoTheme.Typography.caption)
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                        .fill(isItemHovered ? LumnoTheme.Colors.bgCardHover : .clear)
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

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LumnoTheme.Typography.captionMedium)
            .foregroundStyle(isActive ? LumnoTheme.Colors.accent : LumnoTheme.Colors.textSecondary)
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                    .fill(isActive ? LumnoTheme.Colors.accentDim : .clear)
            )
    }
}

private struct SessionItemButtonStyle: ButtonStyle {
    let isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isActive ? LumnoTheme.Colors.accent : LumnoTheme.Colors.textSecondary)
            .background(
                RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                    .fill(isActive ? LumnoTheme.Colors.accentDim : .clear)
            )
    }
}
