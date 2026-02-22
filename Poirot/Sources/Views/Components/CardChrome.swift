import SwiftUI

extension View {
    func cardChrome(isHovered: Bool, isSelected: Bool = false) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                    .fill(isHovered ? PoirotTheme.Colors.bgCardHover : PoirotTheme.Colors.bgCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                    .strokeBorder(
                        isSelected
                            ? PoirotTheme.Colors.accent
                            : isHovered
                                ? Color.white.opacity(0.1)
                                : PoirotTheme.Colors.border,
                        lineWidth: 1
                    )
            )
    }
}
