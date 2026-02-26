import AppKit
import SwiftUI

enum PoirotTheme {
    // MARK: - Colors

    enum Colors {
        static let accent = Color(hex: 0xE8A642)
        static let accentDim = Color(lightHex: 0xE8A642, darkHex: 0xE8A642, lightOpacity: 0.18, darkOpacity: 0.15)

        static let bgApp = Color(lightHex: 0xF3F4F7, darkHex: 0x0D0D0F)
        static let bgSidebar = Color(lightHex: 0xECEEF3, darkHex: 0x141416)
        static let bgCard = Color(lightHex: 0xFFFFFF, darkHex: 0x1A1A1E)
        static let bgCardHover = Color(lightHex: 0xF5F7FB, darkHex: 0x222226)
        static let bgElevated = Color(lightHex: 0xFCFCFD, darkHex: 0x222226)
        static let bgCode = Color(lightHex: 0xEEF1F6, darkHex: 0x161618)

        static let textPrimary = Color(lightHex: 0x15161A, darkHex: 0xF5F5F7)
        static let textSecondary = Color(lightHex: 0x4E5260, darkHex: 0x8E8E93)
        static let textTertiary = Color(lightHex: 0x747A89, darkHex: 0x636366)

        static let border = Color(lightHex: 0x000000, darkHex: 0xFFFFFF, lightOpacity: 0.10, darkOpacity: 0.06)
        static let borderSubtle = Color(lightHex: 0x000000, darkHex: 0xFFFFFF, lightOpacity: 0.05, darkOpacity: 0.03)
        static let borderEmphasis = Color(lightHex: 0x000000, darkHex: 0xFFFFFF, lightOpacity: 0.16, darkOpacity: 0.10)

        static let green = Color(hex: 0x32D74B)
        static let red = Color(hex: 0xFF453A)
        static let blue = Color(hex: 0x0A84FF)
        static let orange = Color(hex: 0xFF9F0A)
        static let purple = Color(hex: 0xAF52DE)
        static let teal = Color(hex: 0x30D5C8)

        static let diffAddBg = Color(lightHex: 0x32D74B, darkHex: 0x32D74B, lightOpacity: 0.16, darkOpacity: 0.10)
        static let diffAddText = Color(hex: 0x32D74B)
        static let diffRemoveBg = Color(lightHex: 0xFF453A, darkHex: 0xFF453A, lightOpacity: 0.16, darkOpacity: 0.10)
        static let diffRemoveText = Color(hex: 0xFF453A)
    }

    // MARK: - Typography

    enum Typography {
        nonisolated(unsafe) static var scale: CGFloat = 1.0

        static var heroTitle: Font { .system(size: round(32 * scale), weight: .semibold) }
        static var title: Font { .system(size: round(28 * scale), weight: .semibold) }
        static var heading: Font { .system(size: round(20 * scale), weight: .semibold) }
        static var headingSmall: Font { .system(size: round(18 * scale), weight: .semibold) }
        static var large: Font { .system(size: round(16 * scale), weight: .regular) }
        static var largeSemibold: Font { .system(size: round(16 * scale), weight: .semibold) }
        static var subheading: Font { .system(size: round(15 * scale), weight: .medium) }
        static var body: Font { .system(size: round(14 * scale), weight: .regular) }
        static var bodyMedium: Font { .system(size: round(14 * scale), weight: .medium) }
        static var caption: Font { .system(size: round(13 * scale), weight: .regular) }
        static var captionMedium: Font { .system(size: round(13 * scale), weight: .medium) }
        static var small: Font { .system(size: round(12 * scale), weight: .regular) }
        static var smallBold: Font { .system(size: round(12 * scale), weight: .semibold) }
        static var tiny: Font { .system(size: round(11 * scale), weight: .regular) }
        static var sectionHeader: Font { .system(size: round(11 * scale), weight: .semibold) }
        static var micro: Font { .system(size: round(10 * scale), weight: .regular) }
        static var microMedium: Font { .system(size: round(10 * scale), weight: .medium) }
        static var microSemibold: Font { .system(size: round(10 * scale), weight: .semibold) }
        static var microBold: Font { .system(size: round(10 * scale), weight: .bold) }
        static var nano: Font { .system(size: round(9 * scale), weight: .regular) }
        static var nanoSemibold: Font { .system(size: round(9 * scale), weight: .semibold) }
        static var nanoBold: Font { .system(size: round(9 * scale), weight: .bold) }
        static var pico: Font { .system(size: round(8 * scale), weight: .regular) }
        static var picoSemibold: Font { .system(size: round(8 * scale), weight: .semibold) }
        static var code: Font { .system(size: round(12.5 * scale), weight: .regular, design: .monospaced) }
        static var codeSmall: Font { .system(size: round(11 * scale), weight: .regular, design: .monospaced) }
        static var codeMicro: Font {
            .system(size: round(10 * scale), weight: .semibold, design: .monospaced)
        }

        static var codeNano: Font {
            .system(size: round(9 * scale), weight: .semibold, design: .monospaced)
        }
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 2
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
        static let xs: CGFloat = 3
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 14
        static let xl: CGFloat = 20
    }

    // MARK: - Icon Sizes

    enum IconSize {
        static let sm: CGFloat = 20
        static let md: CGFloat = 36
        static let lg: CGFloat = 52
        static let xl: CGFloat = 96
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

    init(lightHex: UInt, darkHex: UInt, lightOpacity: Double = 1.0, darkOpacity: Double = 1.0) {
        self.init(nsColor: NSColor(name: nil) { appearance in
            let isDarkMode = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let selectedHex = isDarkMode ? darkHex : lightHex
            let selectedOpacity = isDarkMode ? darkOpacity : lightOpacity
            let components = Self.rgbComponents(from: selectedHex)
            return NSColor(
                srgbRed: components.red,
                green: components.green,
                blue: components.blue,
                alpha: selectedOpacity
            )
        })
    }

    private static func rgbComponents(from hex: UInt) -> (red: Double, green: Double, blue: Double) {
        (
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
}
