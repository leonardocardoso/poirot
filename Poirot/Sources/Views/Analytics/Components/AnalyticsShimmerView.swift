import SwiftUI

struct AnalyticsShimmerView: View {
    @State
    private var shimmerPhase: CGFloat = -1

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxl) {
                // Header shimmer
                HStack {
                    VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xs) {
                        shimmerRect(width: 200, height: 20)
                        shimmerRect(width: 140, height: 12)
                    }
                    Spacer()
                }

                // Summary cards shimmer
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: PoirotTheme.Spacing.md), count: 4),
                    spacing: PoirotTheme.Spacing.md
                ) {
                    ForEach(0 ..< 8, id: \.self) { _ in
                        shimmerCard
                    }
                }

                // Chart shimmers
                shimmerChartCard(height: 220)
                shimmerChartCard(height: 240)
                shimmerChartCard(height: 200)

                HStack(spacing: PoirotTheme.Spacing.lg) {
                    shimmerChartCard(height: 280)
                    shimmerChartCard(height: 280)
                }
            }
            .padding(PoirotTheme.Spacing.xxl)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmerPhase = 1
            }
        }
    }

    private var shimmerCard: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            shimmerRect(width: 20, height: 14)
            shimmerRect(width: 80, height: 20)
            shimmerRect(width: 100, height: 12)
            shimmerRect(width: 60, height: 10)
        }
        .padding(PoirotTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .fill(PoirotTheme.Colors.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .stroke(PoirotTheme.Colors.border, lineWidth: 1)
        )
    }

    private func shimmerChartCard(height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.md) {
            shimmerRect(width: 160, height: 14)
            shimmerRect(width: 220, height: 12)
            shimmerRect(height: height)
        }
        .padding(PoirotTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .fill(PoirotTheme.Colors.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .stroke(PoirotTheme.Colors.border, lineWidth: 1)
        )
    }

    private func shimmerRect(width: CGFloat? = nil, height: CGFloat = 14) -> some View {
        RoundedRectangle(cornerRadius: PoirotTheme.Radius.xs)
            .fill(PoirotTheme.Colors.bgCardHover)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            PoirotTheme.Colors.textTertiary.opacity(0.08),
                            .clear,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.6)
                    .offset(x: shimmerPhase * geometry.size.width * 1.3)
                }
                .clipped()
            )
    }
}
