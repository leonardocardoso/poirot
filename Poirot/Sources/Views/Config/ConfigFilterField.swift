import SwiftUI

struct ConfigFilterField: View {
    @Binding
    var searchQuery: String

    var body: some View {
        HStack(spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)

            TextField("Filter\u{2026}", text: $searchQuery)
                .textFieldStyle(.plain)
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textPrimary)

            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(PoirotTheme.Typography.caption)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, PoirotTheme.Spacing.md)
        .padding(.vertical, PoirotTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                .fill(PoirotTheme.Colors.bgCard)
        )
        .padding(.horizontal, PoirotTheme.Spacing.xxxl)
        .padding(.top, PoirotTheme.Spacing.sm)
    }
}
