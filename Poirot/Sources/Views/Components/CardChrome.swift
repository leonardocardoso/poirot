import SwiftUI

extension View {
    func cardChrome(isHovered: Bool, isSelected: Bool = false) -> some View {
        background(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .fill(isHovered ? PoirotTheme.Colors.bgCardHover : PoirotTheme.Colors.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .strokeBorder(
                    isSelected
                        ? PoirotTheme.Colors.accent
                        : isHovered
                        ? PoirotTheme.Colors.borderEmphasis
                        : PoirotTheme.Colors.border,
                    lineWidth: 1
                )
        )
    }
}
