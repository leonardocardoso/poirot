import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }

            ViewerSettingsView()
                .tabItem {
                    Label("Viewer", systemImage: "eye")
                }
        }
        .frame(width: 560, height: 360)
    }
}

// MARK: - General

private struct GeneralSettingsView: View {
    @Environment(\.provider)
    private var provider
    @AppStorage("textEditor")
    private var textEditor = PreferredEditor.vscode.rawValue
    @AppStorage("preferredTerminal")
    private var preferredTerminal = PreferredTerminal.terminal.rawValue
    @AppStorage("openTerminalOnBash")
    private var openTerminalOnBash = false
    @AppStorage("claudeCodePath")
    private var claudeCodePath = "/usr/local/bin/claude"

    var body: some View {
        VStack(spacing: 0) {
            settingsRow {
                Text("Default Editor:")
            } control: {
                Picker("", selection: $textEditor) {
                    ForEach(PreferredEditor.installedCases, id: \.rawValue) { editor in
                        Label {
                            Text(editor.displayName)
                        } icon: {
                            if let icon = editor.appIcon {
                                Image(nsImage: icon)
                            }
                        }
                        .tag(editor.rawValue)
                    }
                }
                .labelsHidden()
            }

            settingsRow {
                Text("Terminal Application:")
            } control: {
                Picker("", selection: $preferredTerminal) {
                    ForEach(PreferredTerminal.installedCases, id: \.rawValue) { terminal in
                        Label {
                            Text(terminal.displayName)
                        } icon: {
                            if let icon = terminal.appIcon {
                                Image(nsImage: icon)
                            }
                        }
                        .tag(terminal.rawValue)
                    }
                }
                .labelsHidden()
            }

            settingsRow {
                Text("Open Terminal Automatically:")
            } control: {
                Toggle("Open terminal when copying bash commands", isOn: $openTerminalOnBash)
                    .labelsHidden()
            }

            settingsRow {
                Text("\(provider.cliLabel):")
            } control: {
                HStack(spacing: 8) {
                    TextField("", text: $claudeCodePath)
                        .textFieldStyle(.roundedBorder)

                    Button("Browse\u{2026}") {
                        browseForCLI()
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 32)
    }

    private func browseForCLI() {
        let panel = NSOpenPanel()
        panel.title = "Select CLI Executable"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            claudeCodePath = url.path
        }
    }
}

// MARK: - Appearance

private struct AppearanceSettingsView: View {
    @Environment(AppState.self)
    private var appState
    @AppStorage("appearanceMode")
    private var appearanceMode = AppearanceMode.auto.rawValue
    @AppStorage("accentColor")
    private var accentColorRaw = AccentColor.golden.rawValue
    @AppStorage("colorTheme")
    private var colorThemeRaw = ColorTheme.default.rawValue
    @AppStorage("showAnimations")
    private var showAnimations = true

    private var colorThemeBinding: Binding<ColorTheme> {
        Binding(
            get: { ColorTheme(rawValue: colorThemeRaw) ?? .default },
            set: { newValue in
                colorThemeRaw = newValue.rawValue
                ColorThemeStorage.current = newValue
            }
        )
    }

    private var appearanceModeBinding: Binding<AppearanceMode> {
        Binding(
            get: { AppearanceMode(rawValue: appearanceMode) ?? .auto },
            set: { newValue in
                appearanceMode = newValue.rawValue
                NSApp.appearance = newValue.appearance
            }
        )
    }

    private var accentColorBinding: Binding<AccentColor> {
        Binding(
            get: { AccentColor(rawValue: accentColorRaw) ?? .golden },
            set: { newValue in
                accentColorRaw = newValue.rawValue
                AccentColorStorage.current = newValue
            }
        )
    }

    var body: some View {
        @Bindable
        var appState = appState

        VStack(spacing: 0) {
            settingsRow(alignment: .top) {
                Text("Appearance:")
            } control: {
                AppearancePicker(selection: appearanceModeBinding)
            }

            settingsDivider

            settingsRow(alignment: .top) {
                Text("Theme:")
            } control: {
                ThemePicker(selection: colorThemeBinding)
            }

            settingsDivider

            settingsRow {
                Text("Accent Color:")
            } control: {
                AccentColorPicker(selection: accentColorBinding)
            }

            settingsDivider

            settingsRow {
                Text("Animations:")
            } control: {
                Toggle("Message streaming animations", isOn: $showAnimations)
                    .labelsHidden()
            }

            settingsDivider

            settingsRow {
                Text("Font Size:")
            } control: {
                HStack(spacing: 8) {
                    Button { appState.decreaseFontScale() } label: {
                        Image(systemName: "minus")
                    }
                    Text("\(Int(round(appState.fontScale * 100)))%")
                        .monospacedDigit()
                        .frame(width: 44, alignment: .center)
                    Button { appState.increaseFontScale() } label: {
                        Image(systemName: "plus")
                    }
                    Button("Reset") { appState.resetFontScale() }
                        .disabled(appState.fontScale == 1.0)
                }
            }

            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 32)
    }
}

// MARK: - Viewer

private struct ViewerSettingsView: View {
    @AppStorage("wrapCodeLines")
    private var wrapCodeLines = true
    @AppStorage("autoExpandBlocks")
    private var autoExpandBlocks = true
    @AppStorage("parseMarkdownInResults")
    private var parseMarkdown = true

    var body: some View {
        VStack(spacing: 0) {
            settingsRow {
                Text("Wrap Lines Automatically:")
            } control: {
                Toggle("Wrap lines in code blocks", isOn: $wrapCodeLines)
                    .labelsHidden()
            }

            settingsRow {
                Text("Expand Blocks Automatically:")
            } control: {
                Toggle("Expand tool blocks automatically", isOn: $autoExpandBlocks)
                    .labelsHidden()
            }

            settingsRow {
                Text("Parse Markdown Automatically:")
            } control: {
                Toggle("Render markdown in tool results", isOn: $parseMarkdown)
                    .labelsHidden()
            }

            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 32)
    }
}

// MARK: - Settings Layout Helpers

private let settingsLabelWidth: CGFloat = 200

@MainActor
private func settingsRow<Label: View, Control: View>(
    alignment: VerticalAlignment = .firstTextBaseline,
    @ViewBuilder label: () -> Label,
    @ViewBuilder control: () -> Control
) -> some View {
    HStack(alignment: alignment, spacing: 12) {
        label()
            .frame(width: settingsLabelWidth, alignment: .trailing)

        control()

        Spacer()
    }
    .padding(.vertical, 8)
}

@MainActor
private var settingsDivider: some View {
    Divider()
        .padding(.leading, settingsLabelWidth + 12)
        .padding(.vertical, 4)
}
