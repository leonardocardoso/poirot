import SwiftUI

struct ShimmerModifier: ViewModifier {
    var cornerRadius: CGFloat = 0

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
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
    func shimmer(cornerRadius: CGFloat = 0) -> some View {
        modifier(ShimmerModifier(cornerRadius: cornerRadius))
    }

    func shimmerReveal(isRevealed: Bool, delay: Double = 0, cornerRadius: CGFloat = 0) -> some View {
        modifier(ShimmerRevealModifier(isRevealed: isRevealed, delay: delay, cornerRadius: cornerRadius))
    }
}

// MARK: - Shimmer Reveal

struct ShimmerRevealModifier: ViewModifier {
    let isRevealed: Bool
    var delay: Double = 0
    var cornerRadius: CGFloat = 0

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                if !reduceMotion {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(PoirotTheme.Colors.bgCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .strokeBorder(PoirotTheme.Colors.border, lineWidth: 1)
                        )
                        .shimmer(cornerRadius: cornerRadius)
                        .opacity(isRevealed ? 0 : 1)
                        .animation(.easeOut(duration: 0.35).delay(delay), value: isRevealed)
                        .allowsHitTesting(false)
                }
            }
    }
}
