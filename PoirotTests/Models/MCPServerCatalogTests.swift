@testable import Poirot
import Testing

struct MCPServerCatalogTests {
    // MARK: - Catalog Count

    @Test
    func catalog_hasEntries() {
        #expect(!MCPServerCatalog.entries.isEmpty)
    }

    // MARK: - Unique IDs

    @Test
    func catalog_allEntriesHaveUniqueIds() {
        let ids = MCPServerCatalog.entries.map(\.id)
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
    }

    // MARK: - Non-Empty Fields

    @Test
    func catalog_allEntriesHaveRequiredFields() {
        for entry in MCPServerCatalog.entries {
            #expect(!entry.id.isEmpty)
            #expect(!entry.name.isEmpty)
            #expect(!entry.description.isEmpty)
            #expect(!entry.icon.isEmpty)
            #expect(!entry.command.isEmpty)
        }
    }

    // MARK: - Search

    @Test
    func search_emptyQuery_returnsAll() {
        let results = MCPServerCatalog.search("")
        #expect(results.count == MCPServerCatalog.entries.count)
    }

    @Test
    func search_byName_findsMatch() {
        let results = MCPServerCatalog.search("github")
        #expect(results.contains { $0.id == "github" })
    }

    @Test
    func search_byDescription_findsMatch() {
        let results = MCPServerCatalog.search("browser automation")
        #expect(results.contains { $0.id == "playwright" })
    }

    @Test
    func search_noMatch_returnsEmpty() {
        let results = MCPServerCatalog.search("xyznonexistent123")
        #expect(results.isEmpty)
    }

    @Test
    func search_caseInsensitive() {
        let results = MCPServerCatalog.search("GITHUB")
        #expect(results.contains { $0.id == "github" })
    }

    // MARK: - Grouped

    @Test
    func grouped_coversAllEntries() {
        let groups = MCPServerCatalog.grouped()
        let totalGrouped = groups.reduce(0) { $0 + $1.entries.count }
        #expect(totalGrouped == MCPServerCatalog.entries.count)
    }

    @Test
    func grouped_noCategoryIsEmpty() {
        let groups = MCPServerCatalog.grouped()
        for group in groups {
            #expect(!group.entries.isEmpty)
        }
    }

    // MARK: - Categories

    @Test
    func categories_allHaveIcons() {
        for category in MCPCatalogCategory.allCases {
            #expect(!category.icon.isEmpty)
        }
    }

    // MARK: - Env Keys

    @Test
    func envKeys_githubRequiresToken() throws {
        let github = MCPServerCatalog.entries.first { $0.id == "github" }
        #expect(github != nil)
        #expect(github?.envKeys.count == 1)
        #expect(try #require(github?.envKeys[0].isRequired))
        #expect(try #require(github?.envKeys[0].isSensitive))
    }

    @Test
    func envKeys_playwrightRequiresNone() throws {
        let playwright = MCPServerCatalog.entries.first { $0.id == "playwright" }
        #expect(playwright != nil)
        #expect(try #require(playwright?.envKeys.isEmpty))
    }

    @Test
    func envKeys_allHaveUniqueIdsPerEntry() {
        for entry in MCPServerCatalog.entries {
            let ids = entry.envKeys.map(\.id)
            let uniqueIds = Set(ids)
            #expect(ids.count == uniqueIds.count, "Duplicate env key ID in \(entry.id)")
        }
    }
}
