import SwiftUI

struct SessionSkeletonView: View {
    var body: some View {
        VStack(spacing: 0) {
            headerSkeleton
            messagesSkeleton
            Spacer()
        }
        .scrollDisabled(true)
        .background(LumnoTheme.Colors.bgApp)
    }

    // MARK: - Header

    private var headerSkeleton: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                skeletonRect(width: 220, height: 16)

                HStack(spacing: LumnoTheme.Spacing.sm) {
                    skeletonRect(width: 80, height: 18, radius: 4)
                    skeletonRect(width: 90, height: 18, radius: 4)
                    skeletonRect(width: 120, height: 14)
                }
            }

            Spacer()

            skeletonRect(width: 80, height: 28, radius: LumnoTheme.Radius.sm)
        }
        .padding(.horizontal, LumnoTheme.Spacing.xxxl)
        .padding(.vertical, LumnoTheme.Spacing.lg)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.3)
        }
    }

    // MARK: - Messages

    private var messagesSkeleton: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: LumnoTheme.Spacing.xl) {
                ForEach(0 ..< 5, id: \.self) { index in
                    messageRowSkeleton(index: index)
                }
            }
            .padding(LumnoTheme.Spacing.xxxl)
        }
    }

    private func messageRowSkeleton(index: Int) -> some View {
        let isUser = index.isMultiple(of: 2)
        let lineWidths = Self.lineWidthsForIndex(index)

        return HStack(alignment: .top, spacing: LumnoTheme.Spacing.md) {
            skeletonRect(width: 28, height: 28, radius: 8)
                .opacity(isUser ? 0.6 : 1)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: LumnoTheme.Spacing.sm) {
                    skeletonRect(width: 40, height: 12)
                    skeletonRect(width: 50, height: 10)
                }

                ForEach(Array(lineWidths.enumerated()), id: \.offset) { _, width in
                    skeletonRect(width: width, height: 12)
                }
            }
        }
        .frame(maxWidth: 820, alignment: .leading)
    }

    // MARK: - Helpers

    private func skeletonRect(width: CGFloat, height: CGFloat, radius: CGFloat = 6) -> some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(LumnoTheme.Colors.bgCard)
            .frame(width: width, height: height)
            .shimmer()
    }

    private static func lineWidthsForIndex(_ index: Int) -> [CGFloat] {
        switch index {
        case 0: [320, 280]
        case 1: [400, 350, 180]
        case 2: [260, 300]
        case 3: [380, 340, 220]
        default: [300, 260]
        }
    }
}
