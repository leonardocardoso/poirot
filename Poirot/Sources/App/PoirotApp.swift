import SwiftUI

@main
struct PoirotApp: App {
    @State
    private var appState = AppState()
    @Environment(\.openWindow)
    private var openWindow

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1280, height: 820)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Poirot") {
                    openWindow(id: "about")
                }
            }
            CommandGroup(after: .textFormatting) {
                Button("Increase Font Size") { appState.increaseFontScale() }
                    .keyboardShortcut("+", modifiers: .command)
                Button("Decrease Font Size") { appState.decreaseFontScale() }
                    .keyboardShortcut("-", modifiers: .command)
                Button("Reset Font Size") { appState.resetFontScale() }
                    .keyboardShortcut("0", modifiers: .command)
            }
            CommandGroup(replacing: .help) {
                Button("Poirot Help") {
                    openWindow(id: "help")
                }
                .keyboardShortcut("?", modifiers: .command)
            }
        }

        Window("About Poirot", id: "about") {
            AboutView()
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)

        Window("Poirot Help", id: "help") {
            HelpView()
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environment(appState)
        }
    }
}
