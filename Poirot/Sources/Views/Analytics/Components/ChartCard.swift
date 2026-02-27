import SwiftUI

struct ChartCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder
    let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                Text(title)
                    .font(PoirotTheme.Typography.bodyMedium)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                Text(subtitle)
                    .font(PoirotTheme.Typography.small)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
            }

            content
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
}
