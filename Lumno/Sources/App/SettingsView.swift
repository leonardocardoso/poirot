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
        }
        .frame(width: 450, height: 300)
    }
}

private struct GeneralSettingsView: View {
    @Environment(\.provider)
    private var provider
    @AppStorage("textEditor")
    private var textEditor = "code"
    @AppStorage("claudeCodePath")
    private var claudeCodePath = "/usr/local/bin/claude"

    var body: some View {
        Form {
            Picker("Default Editor", selection: $textEditor) {
                Text("VS Code").tag("code")
                Text("Cursor").tag("cursor")
                Text("Xcode").tag("xcode")
            }

            TextField(provider.cliLabel, text: $claudeCodePath)
        }
        .padding()
    }
}

private struct AppearanceSettingsView: View {
    @Environment(AppState.self)
    private var appState
    @AppStorage("showAnimations")
    private var showAnimations = true

    var body: some View {
        @Bindable
        var appState = appState
        Form {
            Toggle("Message streaming animations", isOn: $showAnimations)

            HStack {
                Text("Font Size")
                Spacer()
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
        .padding()
    }
}
