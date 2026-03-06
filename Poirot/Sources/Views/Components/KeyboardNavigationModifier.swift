import SwiftUI

struct KeyboardNavigationModifier: ViewModifier {
    @Environment(AppState.self)
    private var appState
    @State
    private var eventMonitor: Any?

    var sidebarItemCount: Int
    var onSidebarActivate: () -> Void

    func body(content: Content) -> some View {
        content
            .focusable()
            .focusEffectDisabled()
            .onKeyPress(phases: .down) { press in
                guard !appState.isSearchPresented,
                      !appState.isShortcutHelpPresented
                else { return .ignored }

                return handleKeyPress(press)
            }
            .onAppear { installEventMonitor() }
            .onDisappear { removeEventMonitor() }
    }

    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        // Escape layered dismiss
        if press.key == .escape {
            return handleEscape()
        }

        guard press.modifiers.isEmpty else { return .ignored }

        // Arrow keys navigate sidebar
        switch press.key {
        case .downArrow:
            moveSidebarSelection(by: 1)
            return .handled
        case .upArrow:
            moveSidebarSelection(by: -1)
            return .handled
        case .return:
            onSidebarActivate()
            return .handled
        default:
            return .ignored
        }
    }

    // MARK: - Escape

    private func handleEscape() -> KeyPress.Result {
        if appState.isSessionSearchActive {
            appState.isSessionSearchActive = false
            appState.sessionSearchQuery = ""
            return .handled
        }
        if appState.isToolFilterActive {
            appState.isToolFilterActive = false
            appState.activeToolFilters.removeAll()
            return .handled
        }
        if appState.activeConfigDetail != nil {
            appState.activeConfigDetail = nil
            return .handled
        }
        if appState.selectedSession != nil {
            appState.selectedSession = nil
            return .handled
        }
        return .ignored
    }

    // MARK: - Sidebar Navigation

    private func moveSidebarSelection(by delta: Int) {
        let newIndex = appState.sidebarKeyboardIndex + delta
        appState.sidebarKeyboardIndex = max(0, min(newIndex, sidebarItemCount - 1))
    }

    // MARK: - Text Field Escape Monitor

    private func installEventMonitor() {
        guard eventMonitor == nil else { return }
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard let window = NSApp.keyWindow,
                  let textView = window.firstResponder as? NSTextView,
                  textView.isFieldEditor
            else { return event }

            if event.keyCode == 53 { // Escape
                window.makeFirstResponder(nil)
                return nil
            }
            return event
        }
    }

    private func removeEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

extension View {
    func keyboardNavigation(
        sidebarItemCount: Int,
        onSidebarActivate: @escaping () -> Void
    ) -> some View {
        modifier(KeyboardNavigationModifier(
            sidebarItemCount: sidebarItemCount,
            onSidebarActivate: onSidebarActivate
        ))
    }
}
