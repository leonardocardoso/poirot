@testable import Poirot
import Foundation
import Testing

struct SettingsWriterMCPTests {
    // MARK: - Helpers

    private func withTempClaudeConfig(
        initial: [String: Any] = [:],
        body: (URL) throws -> Void
    ) throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let configURL = tempDir.appendingPathComponent(".claude.json")
        if !initial.isEmpty {
            let data = try JSONSerialization.data(
                withJSONObject: initial,
                options: [.prettyPrinted, .sortedKeys]
            )
            try data.write(to: configURL)
        }

        try body(configURL)
    }

    private func readConfig(at url: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: url)
        return try JSONSerialization.jsonObject(with: data) as! [String: Any]
    }

    // MARK: - Catalog Validation

    @Test
    func catalog_entriesAreValid() {
        for entry in MCPServerCatalog.entries {
            #expect(!entry.command.isEmpty, "Entry \(entry.id) has empty command")
            #expect(
                !entry.args.isEmpty || entry.envKeys.isEmpty || !entry.envKeys.isEmpty,
                "Entry \(entry.id) validation"
            )
        }
    }

    // MARK: - Catalog Search Integration

    @Test
    func catalog_searchByCategory() {
        let results = MCPServerCatalog.search("Developer")
        #expect(!results.isEmpty)
        for result in results {
            #expect(result.category == .developer)
        }
    }

    // MARK: - Env Key Properties

    @Test
    func envKey_defaultValues() {
        let key = MCPEnvKey(
            id: "TEST_KEY",
            label: "Test",
            description: "A test key"
        )
        #expect(key.isRequired)
        #expect(!key.isSensitive)
        #expect(key.placeholder.isEmpty)
    }

    @Test
    func envKey_customValues() {
        let key = MCPEnvKey(
            id: "SECRET",
            label: "Secret",
            description: "A secret",
            placeholder: "sk-...",
            isRequired: false,
            isSensitive: true
        )
        #expect(!key.isRequired)
        #expect(key.isSensitive)
        #expect(key.placeholder == "sk-...")
    }
}
