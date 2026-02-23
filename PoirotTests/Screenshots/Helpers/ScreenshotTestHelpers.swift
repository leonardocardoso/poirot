import SnapshotTesting
import SwiftUI
import Testing

@testable import Poirot

// MARK: - Standard Sizes

enum ScreenshotSize {
    static let fullApp = CGSize(width: 1280, height: 820)
    static let mainContent = CGSize(width: 1020, height: 820)
    static let sidebar = CGSize(width: 260, height: 820)
    static let component = CGSize(width: 600, height: 400)
    static let componentWide = CGSize(width: 800, height: 400)
    static let componentCollapsed = CGSize(width: 600, height: 80)
    static let componentHeader = CGSize(width: 800, height: 120)
    static let badge = CGSize(width: 200, height: 40)
    static let toast = CGSize(width: 500, height: 80)
    static let settings = CGSize(width: 560, height: 360)
    static let onboarding = CGSize(width: 520, height: 480)
    static let help = CGSize(width: 540, height: 620)
    static let diff = CGSize(width: 600, height: 300)
    static let emptyState = CGSize(width: 600, height: 300)
}

// MARK: - Snapshot Helpers

/// Synchronous snapshot — use for views that don't rely on .task / .onAppear async loading.
func snapshotView<V: View>(
    _ view: V,
    size: CGSize,
    named name: String,
    record isRecording: Bool = false
) {
    let hostingView = NSHostingController(
        rootView: view
            .frame(width: size.width, height: size.height)
    )
    hostingView.view.frame = CGRect(origin: .zero, size: size)

    assertSnapshot(
        of: hostingView,
        as: .image(size: size),
        named: name,
        record: isRecording
    )
}

/// Async snapshot — attaches the view to a window and uses Task.sleep to yield the MainActor,
/// allowing SwiftUI .task / .onAppear async modifiers to execute before capturing.
func snapshotView<V: View>(
    _ view: V,
    size: CGSize,
    named name: String,
    record isRecording: Bool = false,
    delay: TimeInterval
) async throws {
    let hostingView = NSHostingController(
        rootView: view
            .frame(width: size.width, height: size.height)
    )
    hostingView.view.frame = CGRect(origin: .zero, size: size)

    // Attach to a real window so .onAppear / .task modifiers fire
    let window = NSWindow(
        contentRect: CGRect(origin: .zero, size: size),
        styleMask: [.borderless],
        backing: .buffered,
        defer: false
    )
    window.contentViewController = hostingView
    window.makeKeyAndOrderFront(nil)

    // Yield the MainActor so SwiftUI .task modifiers can execute
    try await Task.sleep(for: .seconds(delay))

    assertSnapshot(
        of: hostingView,
        as: .image(size: size),
        named: name,
        record: isRecording
    )
}

// MARK: - App State Factory

func makeAppState(
    projects: [Project] = ScreenshotData.projects,
    selectedSession: Session? = nil,
    selectedNav: NavigationItem = .sessions,
    isLoadingProjects: Bool = false,
    isLoadingMoreProjects: Bool = false,
    isSearchPresented: Bool = false,
    selectedProject: String? = nil,
    isSessionSearchActive: Bool = false,
    sessionSearchQuery: String = "",
    isToolFilterActive: Bool = false,
    activeToolFilters: Set<String> = [],
    toastQueue: [Toast] = []
) -> AppState {
    let state = AppState()
    state.projects = projects
    state.selectedSession = selectedSession
    state.selectedNav = selectedNav
    state.isLoadingProjects = isLoadingProjects
    state.isLoadingMoreProjects = isLoadingMoreProjects
    state.isSearchPresented = isSearchPresented
    state.selectedProject = selectedProject
    state.isSessionSearchActive = isSessionSearchActive
    state.sessionSearchQuery = sessionSearchQuery
    state.isToolFilterActive = isToolFilterActive
    state.activeToolFilters = activeToolFilters
    state.toastQueue = toastQueue
    return state
}

// MARK: - Environment Wrapper

func withEnvironment<V: View>(
    _ view: V,
    state: AppState? = nil,
    provider: any ProviderDescribing = ClaudeCodeProvider()
) -> some View {
    let appState = state ?? makeAppState()
    return view
        .environment(appState)
        .environment(\.provider, provider)
}

// MARK: - Composite App View (Sidebar + Detail)
// NavigationSplitView doesn't render its sidebar in NSHostingController snapshots.
// This helper manually composes sidebar + detail side-by-side for full-app screenshots.

func compositeAppView<Detail: View>(
    state: AppState? = nil,
    provider: any ProviderDescribing = ClaudeCodeProvider(),
    @ViewBuilder detail: () -> Detail
) -> some View {
    let appState = state ?? makeAppState()
    return HStack(spacing: 0) {
        SidebarView()
            .frame(width: 260)
        Divider()
        detail()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .environment(appState)
    .environment(\.provider, provider)
}
