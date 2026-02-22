import SwiftUI

struct ConfigScreenHeader: View {
    let item: ConfigurationItem
    let dynamicCount: String?
    var screenID: String = ""
    var showLayoutToggle: Bool = false

    @Environment(AppState.self)
    private var appState

    init(
        item: ConfigurationItem,
        dynamicCount: String? = nil,
        screenID: String = "",
        showLayoutToggle: Bool = false
    ) {
        self.item = item
        self.dynamicCount = dynamicCount
        self.screenID = screenID
        self.showLayoutToggle = showLayoutToggle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            HStack(spacing: PoirotTheme.Spacing.md) {
                Image(systemName: item.icon)
                    .font(PoirotTheme.Typography.headingSmall)
                    .foregroundStyle(item.iconColor)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                            .fill(item.iconColor.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                    Text(item.title)
                        .font(PoirotTheme.Typography.heading)
                        .foregroundStyle(PoirotTheme.Colors.textPrimary)

                    Text(dynamicCount ?? item.count)
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .padding(.horizontal, PoirotTheme.Spacing.sm)
                        .padding(.vertical, PoirotTheme.Spacing.xxs)
                        .background(
                            Capsule().fill(PoirotTheme.Colors.bgElevated)
                        )
                }

                Spacer()

                if showLayoutToggle {
                    layoutToggle
                }
            }

            Text(item.description)
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
                .lineSpacing(PoirotTheme.Spacing.xxs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, PoirotTheme.Spacing.xxxl)
        .padding(.vertical, PoirotTheme.Spacing.xl)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.3)
        }
    }

    private var layoutToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                appState.toggleConfigLayout(for: screenID)
            }
        } label: {
            Image(systemName: appState.configLayout(for: screenID) == .grid ? "list.bullet" : "square.grid.2x2")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
    }
}
