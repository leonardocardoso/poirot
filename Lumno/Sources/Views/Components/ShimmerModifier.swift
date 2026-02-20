import SwiftUI

struct ShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion
    @State
    private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                if reduceMotion {
                    Color.white.opacity(0.05)
                } else {
                    GeometryReader { geo in
                        let width = geo.size.width
                        let gradientWidth = width * 0.6
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.1), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: gradientWidth)
                        .offset(x: -gradientWidth + phase * (width + gradientWidth))
                    }
                    .clipped()
                }
            }
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
