@testable import Poirot
import AppKit
import Testing

@Suite("AppearanceMode")
struct AppearanceModeTests {
    // MARK: - All Cases

    @Test
    func allCases_hasThreeModes() {
        #expect(AppearanceMode.allCases.count == 3)
    }

    // MARK: - Raw Values

    @Test
    func rawValues_matchExpected() {
        #expect(AppearanceMode.auto.rawValue == "auto")
        #expect(AppearanceMode.light.rawValue == "light")
        #expect(AppearanceMode.dark.rawValue == "dark")
    }

    @Test
    func rawValues_initFromString() {
        #expect(AppearanceMode(rawValue: "auto") == .auto)
        #expect(AppearanceMode(rawValue: "light") == .light)
        #expect(AppearanceMode(rawValue: "dark") == .dark)
        #expect(AppearanceMode(rawValue: "invalid") == nil)
    }

    // MARK: - Labels

    @Test
    func labels_matchExpected() {
        #expect(AppearanceMode.auto.label == "Auto")
        #expect(AppearanceMode.light.label == "Light")
        #expect(AppearanceMode.dark.label == "Dark")
    }

    // MARK: - NSAppearance

    @Test
    func appearance_autoReturnsNil() {
        #expect(AppearanceMode.auto.appearance == nil)
    }

    @Test
    func appearance_lightReturnsAqua() {
        let appearance = AppearanceMode.light.appearance
        #expect(appearance?.name == .aqua)
    }

    @Test
    func appearance_darkReturnsDarkAqua() {
        let appearance = AppearanceMode.dark.appearance
        #expect(appearance?.name == .darkAqua)
    }
}
