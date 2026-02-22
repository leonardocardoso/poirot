import SwiftUI

struct SessionSkeletonView: View {
    var body: some View {
        VStack(spacing: 0) {
            headerSkeleton
            messagesSkeleton
            Spacer()
        }
        .scrollDisabled(true)
        .background(PoirotTheme.Colors.bgApp)
    }

    // MARK: - Header

    private var headerSkeleton: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            skeletonRect(width: 340, height: 16)

            HStack(spacing: PoirotTheme.Spacing.sm) {
                skeletonRect(width: 100, height: 18, radius: PoirotTheme.Radius.xs)
                skeletonRect(width: 110, height: 18, radius: PoirotTheme.Radius.xs)
                skeletonRect(width: 130, height: 14)

                Spacer()

                skeletonRect(width: 80, height: 28, radius: PoirotTheme.Radius.sm)
                skeletonRect(width: 110, height: 28, radius: PoirotTheme.Radius.sm)
                skeletonRect(width: 120, height: 28, radius: PoirotTheme.Radius.sm)
                skeletonRect(width: 70, height: 28, radius: PoirotTheme.Radius.sm)
            }
        }
        .padding(.horizontal, PoirotTheme.Spacing.xxxl)
        .padding(.vertical, PoirotTheme.Spacing.lg)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.3)
        }
    }

    // MARK: - Messages

    private var messagesSkeleton: some View {
        GeometryReader { geo in
            let bubbleWidth = (geo.size.width - PoirotTheme.Spacing.xxxl * 2) * 0.75

            ScrollView {
                VStack(spacing: PoirotTheme.Spacing.lg) {
                    ForEach(0 ..< 6, id: \.self) { index in
                        if index.isMultiple(of: 2) {
                            userBubbleSkeleton(index: index, maxWidth: bubbleWidth)
                        } else {
                            assistantBubbleSkeleton(index: index, maxWidth: bubbleWidth)
                        }
                    }
                }
                .padding(PoirotTheme.Spacing.xxxl)
            }
        }
    }

    // MARK: - User Bubble Skeleton (right-aligned)

    private func userBubbleSkeleton(index: Int, maxWidth: CGFloat) -> some View {
        let innerWidth = maxWidth - 28 // padding (14 * 2)
        let lineRatios = Self.userLineRatios(index)

        return HStack {
            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xs) {
                HStack(spacing: PoirotTheme.Spacing.sm) {
                    skeletonRect(width: 28, height: 12)
                    skeletonRect(width: 50, height: 10)
                }

                ForEach(Array(lineRatios.enumerated()), id: \.offset) { _, ratio in
                    skeletonRect(width: innerWidth * ratio, height: 12)
                }
            }
            .padding(PoirotTheme.Spacing.lg)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                    .fill(PoirotTheme.Colors.bgElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                            .stroke(PoirotTheme.Colors.border)
                    )
            )
        }
    }

    // MARK: - Assistant Bubble Skeleton (left-aligned)

    private func assistantBubbleSkeleton(index: Int, maxWidth: CGFloat) -> some View {
        let innerWidth = maxWidth - 28 // padding (14 * 2)
        let lineRatios = Self.assistantLineRatios(index)

        return HStack(alignment: .top, spacing: PoirotTheme.Spacing.md) {
            skeletonRect(width: 28, height: 28, radius: PoirotTheme.Radius.sm)

            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
                // Text bubble
                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xs) {
                    HStack(spacing: PoirotTheme.Spacing.sm) {
                        skeletonRect(width: 44, height: 12)
                        skeletonRect(width: 50, height: 10)
                    }

                    ForEach(Array(lineRatios.enumerated()), id: \.offset) { _, ratio in
                        skeletonRect(width: innerWidth * ratio, height: 12)
                    }
                }
                .padding(PoirotTheme.Spacing.lg)
                .frame(maxWidth: maxWidth, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                        .fill(PoirotTheme.Colors.bgCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                                .stroke(PoirotTheme.Colors.border)
                        )
                )

                // Tool block skeleton (only for some)
                if index == 1 || index == 3 {
                    skeletonRect(height: 44, radius: PoirotTheme.Radius.md)
                        .frame(maxWidth: maxWidth)
                }
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Helpers

    private func skeletonRect(
        width: CGFloat? = nil,
        height: CGFloat,
        radius: CGFloat = PoirotTheme.Radius.sm
    ) -> some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(PoirotTheme.Colors.bgCard)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .shimmer(cornerRadius: radius)
    }

    private static func userLineRatios(_ index: Int) -> [CGFloat] {
        switch index {
        case 0: [0.85, 0.65]
        case 2: [0.75, 0.55]
        case 4: [0.70, 0.80, 0.40]
        default: [0.90, 0.60]
        }
    }

    private static func assistantLineRatios(_ index: Int) -> [CGFloat] {
        switch index {
        case 1: [0.90, 0.85, 0.50]
        case 3: [0.85, 0.95, 0.65]
        case 5: [0.80, 0.70]
        default: [0.90, 0.75, 0.55]
        }
    }
}
