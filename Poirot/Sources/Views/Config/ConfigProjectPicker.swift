import SwiftUI

/// Dropdown menu for selecting a project scope.
/// Lists all discovered projects from `~/.claude/projects/`, with a fallback "Browse..." option
/// to manually pick a folder. Selecting a project filters config screens (Commands, Plans, etc.)
/// to show both global and project-scoped items.
struct ConfigProjectPicker: View {
    @Environment(AppState.self)
    private var appState

    /// Projects discovered from `~/.claude/projects/`, filtered to those with a valid path.
    private var knownProjects: [Project] {
        appState.projects
            .filter { !$0.path.isEmpty }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        Menu {
            Button {
                appState.configProjectPath = nil
            } label: {
                Label("All (Global only)", systemImage: "globe")
            }

            if !knownProjects.isEmpty {
                Divider()

                ForEach(knownProjects) { project in
                    Button {
                        appState.configProjectPath = project.path
                    } label: {
                        HStack {
                            Label(project.name, systemImage: "folder.fill")
                            if appState.configProjectPath == project.path {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Divider()

            Button {
                browseForProject()
            } label: {
                Label("Browse\u{2026}", systemImage: "folder.badge.plus")
            }
        } label: {
            HStack(spacing: PoirotTheme.Spacing.sm) {
                Image(systemName: "folder.fill")
                    .font(PoirotTheme.Typography.caption)
                    .foregroundStyle(
                        appState.configProjectPath != nil
                            ? PoirotTheme.Colors.green
                            : PoirotTheme.Colors.textTertiary
                    )

                if let name = appState.configProjectName {
                    Text(name)
                        .font(PoirotTheme.Typography.caption)
                        .foregroundStyle(PoirotTheme.Colors.textPrimary)
                        .lineLimit(1)
                } else {
                    Text("No project selected")
                        .font(PoirotTheme.Typography.caption)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }

                Image(systemName: "chevron.down")
                    .font(PoirotTheme.Typography.pico)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
            }
            .padding(.horizontal, PoirotTheme.Spacing.md)
            .padding(.vertical, PoirotTheme.Spacing.sm)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
    }

    private func browseForProject() {
        let panel = NSOpenPanel()
        panel.title = "Select Project Folder"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            let path = url.path
            appState.configProjectPath = path

            let claudeDir = url.appendingPathComponent(".claude")
            var isDir: ObjCBool = false
            if !FileManager.default.fileExists(atPath: claudeDir.path, isDirectory: &isDir) || !isDir.boolValue {
                appState.showToast(
                    "No .claude/ directory found in **\(url.lastPathComponent)**",
                    icon: "exclamationmark.triangle.fill",
                    style: .info
                )
            }
        }
    }
}
