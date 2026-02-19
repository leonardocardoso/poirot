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
    @AppStorage("textEditor") private var textEditor = "code"
    @AppStorage("claudeCodePath") private var claudeCodePath = "/usr/local/bin/claude"

    var body: some View {
        Form {
            Picker("Default Editor", selection: $textEditor) {
                Text("VS Code").tag("code")
                Text("Cursor").tag("cursor")
                Text("Xcode").tag("xcode")
            }

            TextField("Claude Code Path", text: $claudeCodePath)
        }
        .padding()
    }
}

private struct AppearanceSettingsView: View {
    @AppStorage("showAnimations") private var showAnimations = true

    var body: some View {
        Form {
            Toggle("Message streaming animations", isOn: $showAnimations)
        }
        .padding()
    }
}
