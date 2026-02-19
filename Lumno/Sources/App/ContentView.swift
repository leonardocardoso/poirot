import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.sessionLoader) private var sessionLoader

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 300)
        } detail: {
            detailView
        }
        .overlay {
            if appState.isSearchPresented {
                SearchOverlayView()
            }
        }
        .task {
            do {
                appState.projects = try sessionLoader.discoverProjects()
            } catch {
                print("Failed to load projects: \(error)")
            }
        }
        .keyboardShortcut(for: .search) {
            appState.isSearchPresented.toggle()
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch appState.selectedNav.id {
        case NavigationItem.sessions.id:
            if let session = appState.selectedSession {
                SessionDetailView(session: session)
            } else {
                HomeView()
            }
        case NavigationItem.configuration.id:
            ConfigurationView()
        default:
            Text(appState.selectedNav.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Keyboard Shortcut Helper

private extension View {
    func keyboardShortcut(for shortcut: KeyEquivalent, action: @escaping () -> Void) -> some View {
        self.background {
            Button("") { action() }
                .keyboardShortcut(shortcut, modifiers: .command)
                .hidden()
        }
    }

    func keyboardShortcut(for shortcut: SearchShortcut, action: @escaping () -> Void) -> some View {
        self.background {
            Button("") { action() }
                .keyboardShortcut("k", modifiers: .command)
                .hidden()
        }
    }
}

private enum SearchShortcut {
    case search
}
