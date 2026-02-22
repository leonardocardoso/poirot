import AppKit
import SwiftUI

/// An invisible NSView overlay that changes the cursor to a pointing hand.
/// Does not intercept mouse events — clicks and text selection pass through.
private class PointingHandNSView: NSView {
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }

    override func hitTest(_: NSPoint) -> NSView? { nil }
}

private struct PointingHandCursorRepresentable: NSViewRepresentable {
    func makeNSView(context _: Context) -> NSView { PointingHandNSView() }

    func updateNSView(_ nsView: NSView, context _: Context) {
        nsView.window?.invalidateCursorRects(for: nsView)
    }
}

extension View {
    /// Shows a pointing hand cursor when the mouse hovers over this view.
    func pointingHandCursor() -> some View {
        overlay(PointingHandCursorRepresentable())
    }

    /// Applies pointing hand cursor only when the text contains a URL.
    @ViewBuilder
    func linkCursorIfNeeded(_ text: String) -> some View {
        if text.contains("http://") || text.contains("https://") {
            pointingHandCursor()
        } else {
            self
        }
    }
}
