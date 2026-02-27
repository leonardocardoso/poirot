import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String?
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)

                Spacer()
            }

            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                Text(value)
                    .font(PoirotTheme.Typography.heading)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                Text(title)
                    .font(PoirotTheme.Typography.small)
                    .foregroundStyle(PoirotTheme.Colors.textSecondary)

                if let subtitle {
                    Text(subtitle)
                        .font(PoirotTheme.Typography.micro)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }
            }
        }
        .padding(PoirotTheme.Spacing.md)
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
