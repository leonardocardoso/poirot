import SwiftUI

struct KeyboardNavigationModifier: ViewModifier {
    @Environment(AppState.self)
    private var appState
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @State
    private var keyBuffer: String = ""
    @State
    private var bufferResetTask: Task<Void, Never>?

    var enabled: Bool
    var sidebarItemCount: Int
    var onSidebarActivate: () -> Void
    var onDetailScroll: ((DetailScrollAction) -> Void)?

    enum DetailScrollAction {
        case up, down, halfPageUp, halfPageDown, top, bottom
    }

    func body(content: Content) -> some View {
        content
            .onKeyPress(phases: .down) { press in
                guard enabled,
                      !appState.isSearchPresented,
                      !appState.isShortcutHelpPresented
                else { return .ignored }

                return handleKeyPress(press)
            }
    }

    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        let char = press.characters
        let hasNoModifiers = press.modifiers.isEmpty
        let hasShift = press.modifiers == .shift

        // Tab / Shift+Tab to cycle focus
        if press.key == .tab, press.modifiers.isEmpty {
            cycleFocus(forward: true)
            return .handled
        }
        if press.key == .tab, hasShift {
            cycleFocus(forward: false)
            return .handled
        }

        // ? to show shortcut help (shift+/ on US keyboards)
        if char == "?", !isTextFieldFocused {
            appState.isShortcutHelpPresented = true
            return .handled
        }

        // / to open search
        if char == "/", hasNoModifiers, !isTextFieldFocused {
            appState.isSearchPresented = true
            return .handled
        }

        // Escape layered dismiss
        if press.key == .escape {
            return handleEscape()
        }

        // Route based on focus area
        switch appState.focusedArea {
        case .sidebar:
            return handleSidebarKey(press, char: char, hasNoModifiers: hasNoModifiers)
        case .detail:
            return handleDetailKey(press, char: char, hasNoModifiers: hasNoModifiers, hasShift: hasShift)
        }
    }

    // MARK: - Focus Cycling

    private func cycleFocus(forward: Bool) {
        let areas: [FocusArea] = [.sidebar, .detail]
        guard let idx = areas.firstIndex(of: appState.focusedArea) else { return }
        let next = forward
            ? areas[(idx + 1) % areas.count]
            : areas[(idx - 1 + areas.count) % areas.count]
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.15)) {
            appState.focusedArea = next
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

    // MARK: - Sidebar Keys

    private func handleSidebarKey( // swiftlint:disable:this function_parameter_count
        _ press: KeyPress,
        char: String,
        hasNoModifiers: Bool
    ) -> KeyPress.Result {
        guard hasNoModifiers || press.modifiers == .shift else { return .ignored }

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
            break
        }

        switch char {
        case "j":
            moveSidebarSelection(by: 1)
            return .handled
        case "k":
            moveSidebarSelection(by: -1)
            return .handled
        case "o":
            onSidebarActivate()
            return .handled
        case "G":
            appState.sidebarKeyboardIndex = max(sidebarItemCount - 1, 0)
            return .handled
        case "g":
            return handleSequence("g") {
                appState.sidebarKeyboardIndex = 0
            }
        default:
            return .ignored
        }
    }

    private func moveSidebarSelection(by delta: Int) {
        let newIndex = appState.sidebarKeyboardIndex + delta
        appState.sidebarKeyboardIndex = max(0, min(newIndex, sidebarItemCount - 1))
    }

    // MARK: - Detail Keys

    private func handleDetailKey( // swiftlint:disable:this function_parameter_count
        _ press: KeyPress,
        char: String,
        hasNoModifiers: Bool,
        hasShift: Bool
    ) -> KeyPress.Result {
        guard hasNoModifiers || hasShift else { return .ignored }

        switch char {
        case "j":
            onDetailScroll?(.down)
            return .handled
        case "k":
            onDetailScroll?(.up)
            return .handled
        case "d":
            onDetailScroll?(.halfPageDown)
            return .handled
        case "u":
            onDetailScroll?(.halfPageUp)
            return .handled
        case "G":
            onDetailScroll?(.bottom)
            return .handled
        case "g":
            return handleSequence("g") {
                onDetailScroll?(.top)
            }
        default:
            break
        }

        switch press.key {
        case .downArrow:
            onDetailScroll?(.down)
            return .handled
        case .upArrow:
            onDetailScroll?(.up)
            return .handled
        default:
            return .ignored
        }
    }

    // MARK: - Key Sequence Buffer

    private func handleSequence(
        _ char: String,
        action: @escaping () -> Void
    ) -> KeyPress.Result {
        bufferResetTask?.cancel()

        if keyBuffer == char {
            keyBuffer = ""
            action()
            return .handled
        }

        keyBuffer = char
        bufferResetTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            keyBuffer = ""
        }
        return .handled
    }

    private var isTextFieldFocused: Bool {
        appState.isSessionSearchActive || !appState.sidebarSearchQuery.isEmpty
    }
}

extension View {
    func keyboardNavigation(
        enabled: Bool = true,
        sidebarItemCount: Int,
        onSidebarActivate: @escaping () -> Void,
        onDetailScroll: ((KeyboardNavigationModifier.DetailScrollAction) -> Void)? = nil
    ) -> some View {
        modifier(KeyboardNavigationModifier(
            enabled: enabled,
            sidebarItemCount: sidebarItemCount,
            onSidebarActivate: onSidebarActivate,
            onDetailScroll: onDetailScroll
        ))
    }
}
