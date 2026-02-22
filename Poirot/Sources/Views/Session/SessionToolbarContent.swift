import SwiftUI

struct SessionToolbarActions: View {
    let session: Session

    @State
    private var resumeTapped = false

    @State
    private var copyTapped = false

    @State
    private var revealTapped = false

    @AppStorage("openTerminalOnBash")
    private var openTerminalOnBash = false
    @AppStorage("preferredTerminal")
    private var preferredTerminal = PreferredTerminal.terminal.rawValue

    @Environment(AppState.self)
    private var appState

    @Environment(\.provider)
    private var provider

    var body: some View {
        Button {
            resumeSession()
        } label: {
            Label(
                resumeTapped ? "Copied" : "Resume",
                systemImage: resumeTapped ? "checkmark" : "arrow.uturn.forward"
            )
            .contentTransition(.symbolEffect(.replace))
        }
        .animation(.easeInOut(duration: 0.2), value: resumeTapped)

        Button {
            copyFileName()
        } label: {
            Image(systemName: copyTapped ? "checkmark" : "doc.on.doc")
                .contentTransition(.symbolEffect(.replace))
        }
        .help("Copy File Name")
        .animation(.easeInOut(duration: 0.2), value: copyTapped)

        Button {
            revealInFinder()
        } label: {
            Image(systemName: revealTapped ? "checkmark" : "folder")
                .contentTransition(.symbolEffect(.replace))
        }
        .help("Show in Finder")
        .animation(.easeInOut(duration: 0.2), value: revealTapped)
    }

    // MARK: - Actions

    private func resumeSession() {
        let command = "\(provider.cliPath) --resume \(session.id)"

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)

        if openTerminalOnBash {
            let terminal = PreferredTerminal(rawValue: preferredTerminal) ?? .terminal
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                TerminalLauncher.open(terminal)
            }
            appState.showToast("Copied `\(command)`")
        } else {
            appState.showToast("Copied `\(command)`")
        }

        resumeTapped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            resumeTapped = false
        }
    }

    private func copyFileName() {
        guard let url = session.fileURL else { return }
        let name = url.lastPathComponent
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(name, forType: .string)

        copyTapped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            copyTapped = false
        }
        appState.showToast("Copied `\(name)`")
    }

    private func revealInFinder() {
        guard let url = session.fileURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([url])

        revealTapped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            revealTapped = false
        }
    }
}

struct SessionToolbarFilter: View {
    @Environment(AppState.self)
    private var appState

    var body: some View {
        Button {
            appState.isToolFilterActive.toggle()
            if !appState.isToolFilterActive {
                appState.activeToolFilters.removeAll()
            }
        } label: {
            Image(systemName: appState.isToolFilterActive
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
                .contentTransition(.symbolEffect(.replace))
        }
        .help("Filter by Tool (⌘T)")
    }
}

struct SessionToolbarSearch: View {
    @Environment(AppState.self)
    private var appState

    var body: some View {
        Button {
            appState.isSessionSearchActive.toggle()
            if !appState.isSessionSearchActive {
                appState.sessionSearchQuery = ""
            }
        } label: {
            Image(systemName: appState.isSessionSearchActive ? "magnifyingglass.circle.fill" : "magnifyingglass")
                .contentTransition(.symbolEffect(.replace))
        }
        .help("Find in Session (⌘F)")
    }
}

struct SessionToolbarDelete: View {
    let session: Session

    @State
    private var showDeleteConfirmation = false

    @Environment(AppState.self)
    private var appState

    var body: some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            Image(systemName: "trash")
        }
        .help("Delete")
        .confirmationDialog(
            "Delete session?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                appState.deleteSession(session)
            }
        } message: {
            Text("This will permanently delete the session file. This action cannot be undone.")
        }
    }
}

struct SessionToolbarClose: View {
    @Environment(AppState.self)
    private var appState

    var body: some View {
        Button {
            appState.selectedSession = nil
            appState.selectedProject = nil
        } label: {
            Image(systemName: "xmark")
        }
        .help("Close")
    }
}
