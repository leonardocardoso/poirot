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
                skeletonRect(width: 340, height: 16)

                HStack(spacing: LumnoTheme.Spacing.sm) {
                    skeletonRect(width: 100, height: 18, radius: 4)
                    skeletonRect(width: 110, height: 18, radius: 4)
                    skeletonRect(width: 140, height: 14)
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
                ForEach(0 ..< 8, id: \.self) { index in
                    messageRowSkeleton(index: index)

                    if index == 1 || index == 3 {
                        toolBlockSkeleton()
                    }
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

    private func toolBlockSkeleton() -> some View {
        skeletonRect(height: 44, radius: LumnoTheme.Radius.md)
            .frame(maxWidth: 820)
            .padding(.leading, 40)
    }

    // MARK: - Helpers

    private func skeletonRect(width: CGFloat? = nil, height: CGFloat, radius: CGFloat = 6) -> some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(LumnoTheme.Colors.bgCard)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .shimmer()
    }

    private static func lineWidthsForIndex(_ index: Int) -> [CGFloat] {
        switch index {
        case 0: [520, 380]
        case 1: [700, 620, 340]
        case 2: [460, 540]
        case 3: [660, 580, 420]
        case 4: [500, 440]
        case 5: [720, 640, 300]
        case 6: [480, 560]
        default: [620, 540, 380]
        }
    }
}
