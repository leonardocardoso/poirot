import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self)
    private var appState
    @Environment(\.provider)
    private var provider

    var body: some View {
        VStack(spacing: 0) {
            navigationItems
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

    // MARK: - Projects List

    private var projectsList: some View {
        VStack(alignment: .leading, spacing: LumnoTheme.Spacing.sm) {
            HStack(spacing: LumnoTheme.Spacing.sm) {
                Text("PROJECTS")
                    .font(LumnoTheme.Typography.sectionHeader)
                    .foregroundStyle(LumnoTheme.Colors.textTertiary)
                    .tracking(0.5)

                if appState.isLoadingMoreProjects {
                    ProgressView()
                        .controlSize(.mini)
                        .tint(LumnoTheme.Colors.textTertiary)
                }

                Spacer()

                sortMenu
            }
            .padding(.horizontal, LumnoTheme.Spacing.md)

            ScrollView {
                if appState.isLoadingProjects {
                    projectsSkeletonRows
                        .transition(.opacity)
                } else {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(appState.sortedProjects) { project in
                            ProjectRow(project: project)
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: appState.sortedProjects.map(\.id))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.isLoadingProjects)
        }
        .padding(.top, LumnoTheme.Spacing.lg)
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
            .shimmer()
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

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(project.name, systemImage: "shippingbox")
                .font(LumnoTheme.Typography.captionMedium)
                .foregroundStyle(LumnoTheme.Colors.textPrimary)
                .padding(.vertical, 4)
                .padding(.horizontal, LumnoTheme.Spacing.md)

            ForEach(project.sessions) { session in
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

                        Text(session.timeAgo)
                            .font(LumnoTheme.Typography.tiny)
                            .foregroundStyle(LumnoTheme.Colors.textTertiary)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, LumnoTheme.Spacing.md)
                    .padding(.leading, LumnoTheme.Spacing.lg)
                }
                .buttonStyle(SessionItemButtonStyle(isActive: appState.selectedSession == session))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
