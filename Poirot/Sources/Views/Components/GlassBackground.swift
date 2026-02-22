import SwiftUI

struct GlassBackground: View {
    enum ShapeKind {
        case rect(cornerRadius: CGFloat)
        case circle
        case capsule
    }

    let shape: ShapeKind

    init(in shape: ShapeKind) {
        self.shape = shape
    }

    var body: some View {
        if #available(macOS 26.0, *) {
            glassView
        } else {
            materialView
        }
    }

    @available(macOS 26.0, *)
    @ViewBuilder
    private var glassView: some View {
        switch shape {
        case let .rect(r):
            Color.clear.glassEffect(.regular, in: .rect(cornerRadius: r))
        case .circle:
            Color.clear.glassEffect(.regular, in: .circle)
        case .capsule:
            Color.clear.glassEffect(.regular, in: .capsule)
        }
    }

    @ViewBuilder
    private var materialView: some View {
        switch shape {
        case let .rect(r):
            RoundedRectangle(cornerRadius: r).fill(.ultraThinMaterial)
        case .circle:
            Circle().fill(.ultraThinMaterial)
        case .capsule:
            Capsule().fill(.ultraThinMaterial)
        }
    }
}
