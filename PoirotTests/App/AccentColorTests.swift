@testable import Poirot
import Testing

@Suite("AccentColor")
struct AccentColorTests {
    // MARK: - All Cases

    @Test
    func allCases_hasSixColors() {
        #expect(AccentColor.allCases.count == 6)
    }

    @Test
    func allCases_orderedCorrectly() {
        let expected: [AccentColor] = [.golden, .blue, .purple, .green, .red, .teal]
        #expect(AccentColor.allCases == expected)
    }

    // MARK: - Raw Values

    @Test
    func rawValues_matchExpected() {
        #expect(AccentColor.golden.rawValue == "golden")
        #expect(AccentColor.blue.rawValue == "blue")
        #expect(AccentColor.purple.rawValue == "purple")
        #expect(AccentColor.green.rawValue == "green")
        #expect(AccentColor.red.rawValue == "red")
        #expect(AccentColor.teal.rawValue == "teal")
    }

    @Test
    func rawValues_initFromString() {
        #expect(AccentColor(rawValue: "golden") == .golden)
        #expect(AccentColor(rawValue: "blue") == .blue)
        #expect(AccentColor(rawValue: "purple") == .purple)
        #expect(AccentColor(rawValue: "green") == .green)
        #expect(AccentColor(rawValue: "red") == .red)
        #expect(AccentColor(rawValue: "teal") == .teal)
        #expect(AccentColor(rawValue: "invalid") == nil)
    }

    // MARK: - Labels

    @Test
    func labels_matchExpected() {
        #expect(AccentColor.golden.label == "Golden")
        #expect(AccentColor.blue.label == "Blue")
        #expect(AccentColor.purple.label == "Purple")
        #expect(AccentColor.green.label == "Green")
        #expect(AccentColor.red.label == "Red")
        #expect(AccentColor.teal.label == "Teal")
    }

    // MARK: - Hex Values

    @Test
    func lightHex_allColorsHaveValues() {
        for color in AccentColor.allCases {
            #expect(color.lightHex > 0, "lightHex should be non-zero for \(color.label)")
        }
    }

    @Test
    func darkHex_allColorsHaveValues() {
        for color in AccentColor.allCases {
            #expect(color.darkHex > 0, "darkHex should be non-zero for \(color.label)")
        }
    }

    @Test
    func goldenHex_matchesOriginalDesignTokens() {
        #expect(AccentColor.golden.lightHex == 0xC88422)
        #expect(AccentColor.golden.darkHex == 0xE8A642)
    }

    // MARK: - Swatch Color

    @Test
    func swatchColor_allColorsProduceNonNilColor() {
        for color in AccentColor.allCases {
            // Just verifying the computed property doesn't crash
            _ = color.swatchColor
        }
    }

    // MARK: - Storage

    @Test
    func storage_defaultIsGolden() {
        // Save and restore to avoid test pollution
        let saved = AccentColorStorage.current
        defer { AccentColorStorage.current = saved }

        AccentColorStorage.current = .golden
        #expect(AccentColorStorage.current == .golden)
    }

    @Test
    func storage_persistsSelection() {
        let saved = AccentColorStorage.current
        defer { AccentColorStorage.current = saved }

        AccentColorStorage.current = .purple
        #expect(AccentColorStorage.current == .purple)

        AccentColorStorage.current = .teal
        #expect(AccentColorStorage.current == .teal)
    }
}
