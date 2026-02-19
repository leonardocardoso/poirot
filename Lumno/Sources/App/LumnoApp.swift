import SwiftUI

@main
struct LumnoApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1280, height: 820)

        Settings {
            SettingsView()
                .environment(appState)
        }
    }
}
