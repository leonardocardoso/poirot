import SwiftUI

struct MenuBarView: View {
    @Environment(AppState.self)
    private var appState
    @Environment(\.provider)
    private var provider
    @Environment(\.openWindow)
    private var openWindow
    @State
    private var menuBarState = MenuBarState()

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            Divider().opacity(0.3)
            searchField
            Divider().opacity(0.3)
            sessionsList
            Divider().opacity(0.3)
            footerSection
        }
        .frame(width: 320)
        .background(PoirotTheme.Colors.bgCard)
        .onAppear {
            menuBarState.loadRecentSessions(from: appState.projects)
            Task {
                await menuBarState.refreshStatus(
                    cliPath: UserDefaults.standard.string(forKey: "claudeCodePath")
                        ?? "/usr/local/bin/claude"
                )
                appState.menuBarStatus = menuBarState.claudeCodeStatus
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: statusIcon)
                .font(PoirotTheme.Typography.body)
                .foregroundStyle(statusColor)
                .symbolEffect(.pulse, isActive: menuBarState.claudeCodeStatus == .running)

            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                Text(provider.assistantName)
                    .font(PoirotTheme.Typography.captionMedium)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                Text(statusLabel)
                    .font(PoirotTheme.Typography.tiny)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
            }

            Spacer()

            Text("\(appState.projects.count) projects")
                .font(PoirotTheme.Typography.tiny)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
        }
        .padding(.horizontal, PoirotTheme.Spacing.lg)
        .padding(.vertical, PoirotTheme.Spacing.md)
    }

    // MARK: - Search

    private var searchField: some View {
        HStack(spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(PoirotTheme.Typography.small)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)

            TextField(
                "Search recent sessions...",
                text: Binding(
                    get: { menuBarState.searchQuery },
                    set: { menuBarState.searchQuery = $0 }
                )
            )
            .textFieldStyle(.plain)
            .font(PoirotTheme.Typography.caption)
            .foregroundStyle(PoirotTheme.Colors.textPrimary)

            if !menuBarState.searchQuery.isEmpty {
                Button {
                    menuBarState.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(PoirotTheme.Typography.small)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, PoirotTheme.Spacing.lg)
        .padding(.vertical, PoirotTheme.Spacing.sm)
    }

    // MARK: - Sessions List

    private var sessionsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                let sessions = menuBarState.filteredSessions
                if sessions.isEmpty {
                    emptyState
                } else {
                    ForEach(sessions, id: \.session.id) { pair in
                        MenuBarSessionRow(
                            session: pair.session,
                            projectName: pair.project.name
                        ) {
                            openSessionInApp(pair.session, projectId: pair.project.id)
                        }
                    }
                }
            }
            .padding(PoirotTheme.Spacing.sm)
        }
        .frame(maxHeight: 300)
    }

    private var emptyState: some View {
        VStack(spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: "text.bubble")
                .font(.system(size: 20))
                .foregroundStyle(PoirotTheme.Colors.textTertiary)

            Text(menuBarState.searchQuery.isEmpty ? "No recent sessions" : "No matching sessions")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(PoirotTheme.Spacing.xl)
    }

    // MARK: - Footer

    private var footerSection: some View {
        Button {
            NSApp.activate()
            openWindow(id: "main")
        } label: {
            HStack(spacing: PoirotTheme.Spacing.sm) {
                Image(systemName: "macwindow")
                    .font(PoirotTheme.Typography.small)

                Text("Open Poirot")
                    .font(PoirotTheme.Typography.captionMedium)

                Spacer()

                Image(systemName: "arrow.up.forward")
                    .font(PoirotTheme.Typography.tiny)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
            }
            .padding(.horizontal, PoirotTheme.Spacing.lg)
            .padding(.vertical, PoirotTheme.Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(PoirotTheme.Colors.textPrimary)
    }

    // MARK: - Status Helpers

    private var statusIcon: String {
        switch menuBarState.claudeCodeStatus {
        case .running: "circle.fill"
        case .idle: "circle"
        case .notInstalled: "exclamationmark.circle"
        }
    }

    private var statusColor: Color {
        switch menuBarState.claudeCodeStatus {
        case .running: PoirotTheme.Colors.green
        case .idle: PoirotTheme.Colors.textTertiary
        case .notInstalled: PoirotTheme.Colors.orange
        }
    }

    private var statusLabel: String {
        switch menuBarState.claudeCodeStatus {
        case .running: "Running"
        case .idle: "Idle"
        case .notInstalled: "CLI not found"
        }
    }

    // MARK: - Actions

    private func openSessionInApp(_ session: Session, projectId: String) {
        NSApp.activate()
        appState.selectedProject = projectId
        appState.selectedSession = session
        appState.selectedNav = .sessions
    }
}

// MARK: - Session Row

private struct MenuBarSessionRow: View {
    let session: Session
    let projectName: String
    let action: () -> Void

    @State
    private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: PoirotTheme.Spacing.sm) {
                Image(systemName: "text.bubble")
                    .font(PoirotTheme.Typography.small)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                    Text(session.title)
                        .font(PoirotTheme.Typography.captionMedium)
                        .foregroundStyle(PoirotTheme.Colors.textPrimary)
                        .lineLimit(1)

                    Text(projectName)
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .lineLimit(1)
                }

                Spacer()

                Text(session.timeAgo)
                    .font(PoirotTheme.Typography.tiny)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
            }
            .padding(.horizontal, PoirotTheme.Spacing.sm)
            .padding(.vertical, PoirotTheme.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                    .fill(isHovered ? PoirotTheme.Colors.bgElevated : .clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
