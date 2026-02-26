import SwiftUI

struct HomeView: View {
    @Environment(AppState.self)
    private var appState
    @Environment(\.provider)
    private var provider

    @State
    private var isProjectPickerOpen = false

    private var selectedProjectLabel: String {
        guard let id = appState.selectedProject,
              let project = appState.projects.first(where: { $0.id == id }) else {
            return "All Projects"
        }
        return project.name
    }

    private var recentSessions: [(project: Project, session: Session)] {
        appState.projects
            .flatMap { p in p.sessions.map { (project: p, session: $0) } }
            .sorted { $0.session.startedAt > $1.session.startedAt }
            .prefix(5)
            .map { ($0.project, $0.session) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                    .padding(.top, PoirotTheme.Spacing.xxxl)
                recentSessionsSection
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, PoirotTheme.Spacing.xxl)
        }
        .background(PoirotTheme.Colors.bgApp)
        .overlay(alignment: .bottomTrailing) {
            GitHubStarButton()
                .padding(PoirotTheme.Spacing.xl)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: PoirotTheme.Spacing.sm) {
            // Logo
            Image("PoirotLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: PoirotTheme.Radius.xl))
                .shadow(color: PoirotTheme.Colors.accent.opacity(0.3), radius: 20)
                .padding(.bottom, PoirotTheme.Spacing.md)

            Text(provider.companionTagline)
                .font(PoirotTheme.Typography.title)
                .foregroundStyle(PoirotTheme.Colors.textPrimary)

            Text("Browse sessions, explore diffs, re-run commands")
                .font(PoirotTheme.Typography.subheading)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)

            // Project selector + search
            HStack(spacing: PoirotTheme.Spacing.sm) {
                Button {
                    isProjectPickerOpen.toggle()
                } label: {
                    HStack(spacing: PoirotTheme.Spacing.sm) {
                        Image(systemName: "folder")
                            .font(PoirotTheme.Typography.small)
                            .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        Text(selectedProjectLabel)
                            .font(PoirotTheme.Typography.body)
                            .foregroundStyle(PoirotTheme.Colors.textSecondary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(PoirotTheme.Typography.microSemibold)
                            .foregroundStyle(PoirotTheme.Colors.textTertiary)
                            .rotationEffect(.degrees(isProjectPickerOpen ? 180 : 0))
                            .animation(.easeOut(duration: 0.2), value: isProjectPickerOpen)
                    }
                    .padding(.vertical, PoirotTheme.Spacing.sm)
                    .padding(.horizontal, PoirotTheme.Spacing.md)
                    .frame(width: 240)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                            .fill(PoirotTheme.Colors.bgCard)
                            .stroke(
                                isProjectPickerOpen
                                    ? PoirotTheme.Colors.accent.opacity(0.3)
                                    : PoirotTheme.Colors.border
                            )
                    )
                }
                .buttonStyle(.plain)
                .popover(isPresented: $isProjectPickerOpen, arrowEdge: .bottom) {
                    ProjectPickerPopover()
                        .environment(appState)
                }

                Button {
                    appState.isSearchPresented = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(PoirotTheme.Typography.caption)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .frame(width: 34, height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                                .fill(PoirotTheme.Colors.bgCard)
                                .stroke(PoirotTheme.Colors.border)
                        )
                }
                .buttonStyle(.plain)
                .help("Search (⌘K)")
            }
            .padding(.bottom, PoirotTheme.Spacing.xxl)

            // Suggestion cards
            HStack(spacing: PoirotTheme.Spacing.md) {
                SuggestionCard(
                    icon: "clock",
                    iconColor: PoirotTheme.Colors.blue,
                    text: "Browse your latest coding sessions across all projects"
                )

                SuggestionCard(
                    icon: "magnifyingglass",
                    iconColor: PoirotTheme.Colors.accent,
                    text: "Search across all conversations, commands, and file changes"
                )

                SuggestionCard(
                    icon: "gearshape",
                    iconColor: PoirotTheme.Colors.green,
                    text: "Manage your skills, MCPs, and slash commands"
                )
            }
            .frame(maxWidth: 720)
            .padding(.horizontal, PoirotTheme.Spacing.xxl)
        }
    }

    // MARK: - Recent Sessions

    @ViewBuilder
    private var recentSessionsSection: some View {
        if !recentSessions.isEmpty {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(PoirotTheme.Typography.small)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    Text("Recent Sessions")
                        .font(PoirotTheme.Typography.sectionHeader)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .tracking(0.5)
                }
                .padding(.horizontal, PoirotTheme.Spacing.md)

                VStack(spacing: 0) {
                    ForEach(Array(recentSessions.enumerated()), id: \.element.session.id) { index, pair in
                        Button {
                            appState.selectedProject = pair.project.id
                            appState.selectedSession = pair.session
                            appState.selectedNav = .sessions
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                                    Text(pair.session.title)
                                        .font(PoirotTheme.Typography.body)
                                        .foregroundStyle(PoirotTheme.Colors.textPrimary)
                                        .lineLimit(1)

                                    Text(pair.project.name)
                                        .font(PoirotTheme.Typography.caption)
                                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                Text(pair.session.timeAgo)
                                    .font(PoirotTheme.Typography.caption)
                                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
                            }
                            .padding(.vertical, PoirotTheme.Spacing.sm)
                            .padding(.horizontal, PoirotTheme.Spacing.md)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if index < recentSessions.count - 1 {
                            Divider()
                                .overlay(PoirotTheme.Colors.border)
                                .padding(.horizontal, PoirotTheme.Spacing.md)
                        }
                    }
                }
            }
            .padding(.vertical, PoirotTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                    .fill(PoirotTheme.Colors.bgCard)
                    .stroke(PoirotTheme.Colors.border)
            )
            .frame(maxWidth: 720)
            .padding(.horizontal, PoirotTheme.Spacing.xxl)
            .padding(.top, PoirotTheme.Spacing.xl)
        }
    }
}

// MARK: - Suggestion Card

private struct SuggestionCard: View {
    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(PoirotTheme.Typography.body)
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                        .fill(iconColor.opacity(0.15))
                )

            Text(text)
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PoirotTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .fill(PoirotTheme.Colors.bgCard)
                .stroke(PoirotTheme.Colors.border)
        )
    }
}

// MARK: - GitHub Star Button

private struct GitHubStarButton: View {
    @Environment(\.openURL)
    private var openURL

    @AppStorage("hasInteractedWithGitHubStar")
    private var hasInteracted = false

    var body: some View {
        if !hasInteracted {
            Button {
                hasInteracted = true
                if let url = URL(string: "https://github.com/leonardocardoso/poirot") {
                    openURL(url)
                }
            } label: {
                HStack(spacing: PoirotTheme.Spacing.sm) {
                    Image(systemName: "star.fill")
                        .font(PoirotTheme.Typography.caption)
                        .foregroundStyle(PoirotTheme.Colors.accent)

                    Text("Star on GitHub")
                        .font(PoirotTheme.Typography.caption)
                        .foregroundStyle(PoirotTheme.Colors.textSecondary)
                }
                .padding(.vertical, PoirotTheme.Spacing.sm)
                .padding(.horizontal, PoirotTheme.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                        .fill(PoirotTheme.Colors.bgCard)
                        .stroke(PoirotTheme.Colors.border)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Project Picker Popover

private struct ProjectPickerPopover: View {
    @Environment(AppState.self)
    private var appState
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(spacing: 6) {
                    Image(systemName: "folder")
                        .font(PoirotTheme.Typography.small)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    Text("Projects")
                        .font(PoirotTheme.Typography.sectionHeader)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .tracking(0.5)
                }
                .padding(.horizontal, PoirotTheme.Spacing.md)
                .padding(.top, PoirotTheme.Spacing.md)
                .padding(.bottom, PoirotTheme.Spacing.sm)

                // All Projects row
                projectRow(
                    name: "All Projects",
                    sessionCount: appState.projects.reduce(0) { $0 + $1.sessions.count },
                    isSelected: appState.selectedProject == nil
                ) {
                    appState.selectedProject = nil
                    dismiss()
                }

                Divider()
                    .overlay(PoirotTheme.Colors.border)
                    .padding(.horizontal, PoirotTheme.Spacing.md)

                // Project rows
                ForEach(Array(appState.filteredSortedProjects.enumerated()), id: \.element.id) { index, project in
                    projectRow(
                        name: project.name,
                        sessionCount: project.sessions.count,
                        isSelected: appState.selectedProject == project.id
                    ) {
                        appState.selectedProject = project.id
                        appState.selectedNav = .sessions
                        dismiss()
                    }

                    if index < appState.filteredSortedProjects.count - 1 {
                        Divider()
                            .overlay(PoirotTheme.Colors.border)
                            .padding(.horizontal, PoirotTheme.Spacing.md)
                    }
                }
            }
            .padding(.bottom, PoirotTheme.Spacing.md)
        }
        .frame(width: 400)
        .frame(maxHeight: 400)
        .background(PoirotTheme.Colors.bgCard)
    }

    private func projectRow(
        name: String,
        sessionCount: Int,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                    Text(name)
                        .font(PoirotTheme.Typography.body)
                        .foregroundStyle(isSelected ? PoirotTheme.Colors.accent : PoirotTheme.Colors.textPrimary)
                        .lineLimit(1)

                    Text("\(sessionCount) sessions")
                        .font(PoirotTheme.Typography.caption)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(PoirotTheme.Typography.smallBold)
                        .foregroundStyle(PoirotTheme.Colors.accent)
                }
            }
            .padding(.vertical, PoirotTheme.Spacing.sm)
            .padding(.horizontal, PoirotTheme.Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
