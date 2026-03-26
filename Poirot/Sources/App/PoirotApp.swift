import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let mode = AppearanceMode(rawValue: UserDefaults.standard.string(forKey: "appearanceMode") ?? "") ?? .auto
        NSApp.appearance = mode.appearance
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()
        menu.addItem(withTitle: "New Window", action: #selector(newWindow(_:)), keyEquivalent: "")
        return menu
    }

    @objc
    private func newWindow(_ sender: Any?) {
        NSApp.activate()
        NSApp.sendAction(#selector(NSResponder.newWindowForTab(_:)), to: nil, from: nil)
    }
}

@main
struct PoirotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate
    @State
    private var appState = AppState()
    @AppStorage("showMenuBarIcon")
    private var showMenuBarIcon = true
    @Environment(\.openWindow)
    private var openWindow
    var body: some Scene {
        WindowGroup(id: "main") {
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

                Button("Keyboard Shortcuts") {
                    appState.isShortcutHelpPresented = true
                }
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

        MenuBarExtra("Poirot", image: "MenuBarIcon", isInserted: $showMenuBarIcon) {
            MenuBarView()
                .environment(appState)
        }
        .menuBarExtraStyle(.window)
    }
}
