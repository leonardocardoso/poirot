import SwiftUI

enum LumnoTheme {
    // MARK: - Colors

    enum Colors {
        static let accent = Color(hex: 0xE8A642)
        static let accentDim = Color(hex: 0xE8A642).opacity(0.15)

        static let bgApp = Color(hex: 0x0D0D0F)
        static let bgSidebar = Color(hex: 0x141416)
        static let bgCard = Color(hex: 0x1A1A1E)
        static let bgCardHover = Color(hex: 0x222226)
        static let bgElevated = Color(hex: 0x222226)
        static let bgCode = Color(hex: 0x161618)

        static let textPrimary = Color(hex: 0xF5F5F7)
        static let textSecondary = Color(hex: 0x8E8E93)
        static let textTertiary = Color(hex: 0x636366)

        static let border = Color.white.opacity(0.06)
        static let borderSubtle = Color.white.opacity(0.03)

        static let green = Color(hex: 0x32D74B)
        static let red = Color(hex: 0xFF453A)
        static let blue = Color(hex: 0x0A84FF)
        static let orange = Color(hex: 0xFF9F0A)
        static let purple = Color(hex: 0xAF52DE)

        static let diffAddBg = Color(hex: 0x32D74B).opacity(0.1)
        static let diffAddText = Color(hex: 0x32D74B)
        static let diffRemoveBg = Color(hex: 0xFF453A).opacity(0.1)
        static let diffRemoveText = Color(hex: 0xFF453A)
    }

    // MARK: - Typography

    enum Typography {
        static let title = Font.system(size: 28, weight: .semibold, design: .default)
        static let heading = Font.system(size: 20, weight: .semibold, design: .default)
        static let subheading = Font.system(size: 15, weight: .medium, design: .default)
        static let body = Font.system(size: 14, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 14, weight: .medium, design: .default)
        static let caption = Font.system(size: 13, weight: .regular, design: .default)
        static let captionMedium = Font.system(size: 13, weight: .medium, design: .default)
        static let small = Font.system(size: 12, weight: .regular, design: .default)
        static let smallBold = Font.system(size: 12, weight: .semibold, design: .default)
        static let tiny = Font.system(size: 11, weight: .regular, design: .default)
        static let sectionHeader = Font.system(size: 11, weight: .semibold, design: .default)
        static let code = Font.system(size: 12.5, weight: .regular, design: .monospaced)
        static let codeSmall = Font.system(size: 11, weight: .regular, design: .monospaced)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Radii

    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 14
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
