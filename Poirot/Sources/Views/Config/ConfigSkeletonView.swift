import SwiftUI

struct ConfigSkeletonView: View {
    let layout: ConfigLayout

    var body: some View {
        if layout == .grid {
            gridSkeleton
        } else {
            listSkeleton
        }
    }

    private var gridSkeleton: some View {
        ScrollView {
            HStack(
                alignment: .top,
                spacing: PoirotTheme.Spacing.lg
            ) {
                ForEach(0 ..< 2, id: \.self) { column in
                    LazyVStack(spacing: PoirotTheme.Spacing.lg) {
                        ForEach(0 ..< 3, id: \.self) { row in
                            skeletonCard(
                                delay: Double(column * 3 + row) * 0.06
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, PoirotTheme.Spacing.xxxl)
            .padding(.top, PoirotTheme.Spacing.lg)
            .padding(.bottom, PoirotTheme.Spacing.xxl)
        }
        .scrollIndicators(.never)
    }

    private var listSkeleton: some View {
        ScrollView {
            LazyVStack(spacing: PoirotTheme.Spacing.md) {
                ForEach(0 ..< 4, id: \.self) { index in
                    skeletonCard(delay: Double(index) * 0.05)
                }
            }
            .padding(.horizontal, PoirotTheme.Spacing.xxxl)
            .padding(.top, PoirotTheme.Spacing.lg)
            .padding(.bottom, PoirotTheme.Spacing.xxl)
        }
        .scrollIndicators(.never)
    }

    private func skeletonCard(delay: Double) -> some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            // Title
            skeletonRect(width: 140, height: 14)

            // Description line 1
            skeletonRect(height: 10)

            // Description line 2
            skeletonRect(width: 200, height: 10)

            // Badges
            HStack(spacing: PoirotTheme.Spacing.sm) {
                skeletonRect(width: 64, height: 20)
                skeletonRect(width: 48, height: 20)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PoirotTheme.Spacing.lg)
        .background(
            RoundedRectangle(
                cornerRadius: PoirotTheme.Radius.md
            )
            .fill(PoirotTheme.Colors.bgCard)
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: PoirotTheme.Radius.md
            )
            .strokeBorder(
                PoirotTheme.Colors.border, lineWidth: 1
            )
        )
        .shimmer(cornerRadius: PoirotTheme.Radius.md)
    }

    private func skeletonRect(
        width: CGFloat? = nil,
        height: CGFloat
    ) -> some View {
        RoundedRectangle(cornerRadius: PoirotTheme.Radius.xs)
            .fill(PoirotTheme.Colors.bgElevated)
            .frame(
                maxWidth: width ?? .infinity,
                minHeight: height,
                maxHeight: height,
                alignment: .leading
            )
    }
}
