import SwiftUI

enum AnalyticsColorPalette {
    static let all: [Color] = [
        PoirotTheme.Colors.accent,
        PoirotTheme.Colors.blue,
        PoirotTheme.Colors.purple,
        PoirotTheme.Colors.teal,
        PoirotTheme.Colors.green,
        PoirotTheme.Colors.orange,
    ]

    static func colors(count: Int) -> [Color] {
        Array(all.prefix(count))
    }
}
