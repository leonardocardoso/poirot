import SwiftUI

struct ConfigEmptyState: View {
    let icon: String
    let message: String
    let hint: String

    var body: some View {
        VStack(spacing: PoirotTheme.Spacing.md) {
            Image(systemName: icon)
                .font(PoirotTheme.Typography.heroTitle)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)

            Text(message)
                .font(PoirotTheme.Typography.body)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)

            Text(hint)
                .font(PoirotTheme.Typography.code)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                .padding(.horizontal, PoirotTheme.Spacing.md)
                .padding(.vertical, PoirotTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                        .fill(PoirotTheme.Colors.bgElevated)
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
