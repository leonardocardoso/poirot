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
        nonisolated(unsafe) static var scale: CGFloat = 1.0

        static var title: Font { .system(size: round(28 * scale), weight: .semibold) }
        static var heading: Font { .system(size: round(20 * scale), weight: .semibold) }
        static var subheading: Font { .system(size: round(15 * scale), weight: .medium) }
        static var body: Font { .system(size: round(14 * scale), weight: .regular) }
        static var bodyMedium: Font { .system(size: round(14 * scale), weight: .medium) }
        static var caption: Font { .system(size: round(13 * scale), weight: .regular) }
        static var captionMedium: Font { .system(size: round(13 * scale), weight: .medium) }
        static var small: Font { .system(size: round(12 * scale), weight: .regular) }
        static var smallBold: Font { .system(size: round(12 * scale), weight: .semibold) }
        static var tiny: Font { .system(size: round(11 * scale), weight: .regular) }
        static var sectionHeader: Font { .system(size: round(11 * scale), weight: .semibold) }
        static var code: Font { .system(size: round(12.5 * scale), weight: .regular, design: .monospaced) }
        static var codeSmall: Font { .system(size: round(11 * scale), weight: .regular, design: .monospaced) }
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
