import SwiftUI

struct ContentView: View {
    @Environment(AppState.self)
    private var appState
    @Environment(\.sessionLoader)
    private var sessionLoader

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 300)
        } detail: {
            detailView
                .animation(.easeInOut(duration: 0.25), value: appState.isLoadingSession)
        }
        .overlay {
            if appState.isSearchPresented {
                SearchOverlayView()
            }
        }
        .task {
            await loadProjectsInBatches()
        }
        .keyboardShortcut(for: .search) {
            appState.isSearchPresented.toggle()
        }
        .onChange(of: appState.selectedSession) { _, newSession in
            guard let session = newSession,
                  session.messages.isEmpty,
                  let url = session.fileURL
            else { return }

            if let cached = appState.cachedSession(for: session.id) {
                appState.selectedSession = cached
                return
            }

            appState.isLoadingSession = true
            let projectPath = session.projectPath
            let sessionId = session.id
            let startedAt = session.startedAt
            Task {
                let full = await Task.detached {
                    TranscriptParser().parse(
                        fileURL: url,
                        projectPath: projectPath,
                        sessionId: sessionId,
                        indexStartedAt: startedAt
                    )
                }.value

                if let full {
                    appState.cacheSession(full)
                    appState.selectedSession = full
                }
                appState.isLoadingSession = false
            }
        }
    }

    // MARK: - Batch Loading

    private func loadProjectsInBatches() async {
        do {
            // Phase 1: fast directory scan off main thread
            let directories = try await Task.detached {
                try SessionLoader.projectDirectoryURLs(
                    at: SessionLoader().claudeProjectsPath
                )
            }.value

            // Phase 2: build projects in batches, yielding to UI between each
            let batchSize = 5
            var isFirstBatch = true
            for batchStart in stride(from: 0, to: directories.count, by: batchSize) {
                let batchEnd = min(batchStart + batchSize, directories.count)
                let batch = Array(directories[batchStart ..< batchEnd])

                let projects = await Task.detached {
                    batch.compactMap { SessionLoader.loadProject(at: $0) }
                }.value

                withAnimation(.easeInOut(duration: 0.3)) {
                    appState.projects.append(contentsOf: projects)
                    if isFirstBatch {
                        appState.isLoadingProjects = false
                        isFirstBatch = false
                    }
                }

                if batchEnd < directories.count {
                    try? await Task.sleep(for: .milliseconds(50))
                }
            }
        } catch {
            print("Failed to load projects: \(error)")
        }

        if appState.isLoadingProjects {
            withAnimation(.easeInOut(duration: 0.3)) {
                appState.isLoadingProjects = false
            }
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            appState.isLoadingMoreProjects = false
        }
    }

    // MARK: - Detail

    @ViewBuilder
    private var detailView: some View {
        switch appState.selectedNav.id {
        case NavigationItem.sessions.id:
            if appState.selectedSession != nil {
                if appState.isLoadingSession {
                    SessionSkeletonView()
                        .transition(.opacity)
                } else if let session = appState.selectedSession {
                    SessionDetailView(session: session)
                        .transition(.opacity)
                }
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
        background {
            Button("") { action() }
                .keyboardShortcut(shortcut, modifiers: .command)
                .hidden()
        }
    }

    func keyboardShortcut(for shortcut: SearchShortcut, action: @escaping () -> Void) -> some View {
        background {
            Button("") { action() }
                .keyboardShortcut("k", modifiers: .command)
                .hidden()
        }
    }
}

private enum SearchShortcut {
    case search
}
