import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self) private var appState

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
            ForEach(AppState.NavigationItem.allCases) { item in
                @Bindable var state = appState
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
            HStack {
                Text("PROJECTS")
                    .font(LumnoTheme.Typography.sectionHeader)
                    .foregroundStyle(LumnoTheme.Colors.textTertiary)
                    .tracking(0.5)

                Spacer()
            }
            .padding(.horizontal, LumnoTheme.Spacing.md)

            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(appState.projects) { project in
                        ProjectRow(project: project)
                    }
                }
            }
        }
        .padding(.top, LumnoTheme.Spacing.lg)
    }

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
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(project.name, systemImage: "shippingbox")
                .font(LumnoTheme.Typography.captionMedium)
                .foregroundStyle(LumnoTheme.Colors.textPrimary)
                .padding(.vertical, 4)
                .padding(.horizontal, LumnoTheme.Spacing.md)

            ForEach(project.sessions) { session in
                @Bindable var state = appState
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
