import SwiftUI

@main
struct LumnoApp: App {
    @State
    private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1280, height: 820)
        .commands {
            CommandGroup(after: .textFormatting) {
                Button("Increase Font Size") { appState.increaseFontScale() }
                    .keyboardShortcut("+", modifiers: .command)
                Button("Decrease Font Size") { appState.decreaseFontScale() }
                    .keyboardShortcut("-", modifiers: .command)
                Button("Reset Font Size") { appState.resetFontScale() }
                    .keyboardShortcut("0", modifiers: .command)
            }
        }

        Settings {
            SettingsView()
                .environment(appState)
        }
    }
}
