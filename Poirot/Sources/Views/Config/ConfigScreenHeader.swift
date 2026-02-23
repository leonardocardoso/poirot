import SwiftUI

struct ConfigScreenHeader: View {
    let item: ConfigurationItem
    let dynamicCount: String?
    var screenID: String = ""
    var showLayoutToggle: Bool = false
    var showProjectPicker: Bool = false

    @Environment(AppState.self)
    private var appState

    init(
        item: ConfigurationItem,
        dynamicCount: String? = nil,
        screenID: String = "",
        showLayoutToggle: Bool = false,
        showProjectPicker: Bool = false
    ) {
        self.item = item
        self.dynamicCount = dynamicCount
        self.screenID = screenID
        self.showLayoutToggle = showLayoutToggle
        self.showProjectPicker = showProjectPicker
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            HStack(spacing: PoirotTheme.Spacing.md) {
                Image(systemName: item.icon)
                    .font(PoirotTheme.Typography.headingSmall)
                    .foregroundStyle(item.iconColor)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                            .fill(item.iconColor.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                    Text(item.title)
                        .font(PoirotTheme.Typography.heading)
                        .foregroundStyle(PoirotTheme.Colors.textPrimary)

                    Text(dynamicCount ?? item.count)
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .padding(.horizontal, PoirotTheme.Spacing.sm)
                        .padding(.vertical, PoirotTheme.Spacing.xxs)
                        .background(
                            Capsule().fill(PoirotTheme.Colors.bgElevated)
                        )
                }

                Spacer()

                if showLayoutToggle {
                    layoutToggle
                }
            }

            Text(item.description)
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
                .lineSpacing(PoirotTheme.Spacing.xxs)

            if showProjectPicker {
                projectPickerBar
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, PoirotTheme.Spacing.xxxl)
        .padding(.vertical, PoirotTheme.Spacing.xl)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.3)
        }
    }

    // MARK: - Project Picker

    private var projectPickerBar: some View {
        HStack(spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: "folder.fill")
                .font(PoirotTheme.Typography.small)
                .foregroundStyle(
                    appState.configProjectPath != nil
                        ? PoirotTheme.Colors.green
                        : PoirotTheme.Colors.textTertiary
                )

            if let name = appState.configProjectName {
                Text(name)
                    .font(PoirotTheme.Typography.captionMedium)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)
                    .lineLimit(1)

                Button {
                    appState.configProjectPath = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(PoirotTheme.Typography.small)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            } else {
                Text("No project folder selected")
                    .font(PoirotTheme.Typography.caption)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
            }

            Spacer()

            Button {
                browseForProject()
            } label: {
                Text("Browse\u{2026}")
                    .font(PoirotTheme.Typography.caption)
                    .foregroundStyle(PoirotTheme.Colors.textSecondary)
                    .padding(.horizontal, PoirotTheme.Spacing.sm)
                    .padding(.vertical, PoirotTheme.Spacing.xxs)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                            .fill(PoirotTheme.Colors.bgElevated)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(PoirotTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                .fill(PoirotTheme.Colors.bgCard)
        )
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

    private var layoutToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                appState.toggleConfigLayout(for: screenID)
            }
        } label: {
            Image(systemName: appState.configLayout(for: screenID) == .grid ? "list.bullet" : "square.grid.2x2")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
    }
}
