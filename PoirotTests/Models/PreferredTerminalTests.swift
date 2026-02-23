@testable import Poirot
import Testing

@Suite("PreferredTerminal")
struct PreferredTerminalTests {
    // MARK: - All Cases

    @Test
    func allCases_hasSixTerminals() {
        #expect(PreferredTerminal.allCases.count == 6)
    }

    // MARK: - Raw Values

    @Test
    func rawValues_matchExpected() {
        #expect(PreferredTerminal.terminal.rawValue == "terminal")
        #expect(PreferredTerminal.iterm2.rawValue == "iterm2")
        #expect(PreferredTerminal.warp.rawValue == "warp")
        #expect(PreferredTerminal.ghostty.rawValue == "ghostty")
        #expect(PreferredTerminal.kitty.rawValue == "kitty")
        #expect(PreferredTerminal.alacritty.rawValue == "alacritty")
    }

    // MARK: - Display Names

    @Test
    func displayNames_nonEmpty() {
        for terminal in PreferredTerminal.allCases {
            #expect(!terminal.displayName.isEmpty)
        }
    }

    // MARK: - Bundle Identifiers

    @Test
    func bundleIdentifiers_matchExpected() {
        #expect(PreferredTerminal.terminal.bundleIdentifier == "com.apple.Terminal")
        #expect(PreferredTerminal.iterm2.bundleIdentifier == "com.googlecode.iterm2")
        #expect(PreferredTerminal.warp.bundleIdentifier == "dev.warp.Warp-Stable")
        #expect(PreferredTerminal.ghostty.bundleIdentifier == "com.mitchellh.ghostty")
        #expect(PreferredTerminal.kitty.bundleIdentifier == "net.kovidgoyal.kitty")
        #expect(PreferredTerminal.alacritty.bundleIdentifier == "org.alacritty")
    }
}
