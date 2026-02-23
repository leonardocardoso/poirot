@testable import Poirot
import Testing

@Suite("PreferredEditor")
struct PreferredEditorTests {
    // MARK: - All Cases

    @Test
    func allCases_hasFourEditors() {
        #expect(PreferredEditor.allCases.count == 4)
    }

    // MARK: - Raw Values

    @Test
    func rawValues_matchExpected() {
        #expect(PreferredEditor.vscode.rawValue == "code")
        #expect(PreferredEditor.cursor.rawValue == "cursor")
        #expect(PreferredEditor.xcode.rawValue == "xcode")
        #expect(PreferredEditor.zed.rawValue == "zed")
    }

    // MARK: - Display Names

    @Test
    func displayNames_nonEmpty() {
        for editor in PreferredEditor.allCases {
            #expect(!editor.displayName.isEmpty)
        }
    }

    // MARK: - CLI Commands

    @Test
    func cliCommands_matchExpected() {
        #expect(PreferredEditor.vscode.cliCommand == "code")
        #expect(PreferredEditor.cursor.cliCommand == "cursor")
        #expect(PreferredEditor.xcode.cliCommand == "xed")
        #expect(PreferredEditor.zed.cliCommand == "zed")
    }

    // MARK: - Bundle Identifiers

    @Test
    func bundleIdentifiers_nonEmpty() {
        for editor in PreferredEditor.allCases {
            #expect(!editor.bundleIdentifier.isEmpty)
        }
    }

    @Test
    func bundleIdentifiers_matchExpected() {
        #expect(PreferredEditor.vscode.bundleIdentifier == "com.microsoft.VSCode")
        #expect(PreferredEditor.cursor.bundleIdentifier == "com.todesktop.230313mzl4w4u92")
        #expect(PreferredEditor.xcode.bundleIdentifier == "com.apple.dt.Xcode")
        #expect(PreferredEditor.zed.bundleIdentifier == "dev.zed.Zed")
    }
}
