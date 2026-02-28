import SwiftUI

// MARK: - Disable Animations Environment Key

private struct DisableAnimationsKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var disableAnimations: Bool {
        get { self[DisableAnimationsKey.self] }
        set { self[DisableAnimationsKey.self] = newValue }
    }
}

struct ShimmerModifier: ViewModifier {
    var cornerRadius: CGFloat = 0

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion
    @Environment(\.disableAnimations)
    private var disableAnimations
    @State
    private var phase: CGFloat = 0

    private var shouldSkip: Bool { reduceMotion || disableAnimations }

    func body(content: Content) -> some View {
        content
            .overlay {
                if shouldSkip {
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
                guard !shouldSkip else { return }
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
    @Environment(\.disableAnimations)
    private var disableAnimations

    func body(content: Content) -> some View {
        content
            .overlay {
                if !reduceMotion, !disableAnimations {
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
