import SwiftUI

struct FocusIndicatorModifier: ViewModifier {
    let area: FocusArea

    @Environment(AppState.self)
    private var appState
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    private var isFocused: Bool {
        appState.focusedArea == area
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                    .strokeBorder(
                        PoirotTheme.Colors.accent.opacity(isFocused ? 0.4 : 0),
                        lineWidth: 1.5
                    )
                    .allowsHitTesting(false)
            )
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 0.15),
                value: isFocused
            )
    }
}

extension View {
    func focusIndicator(for area: FocusArea) -> some View {
        modifier(FocusIndicatorModifier(area: area))
    }
}
