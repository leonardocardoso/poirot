@testable import Poirot
import Testing

@Suite("ClaudeCodeProvider")
struct ClaudeCodeProviderTests {
    let provider = ClaudeCodeProvider()

    @Test
    func name_isClaudeCode() {
        #expect(provider.name == "Claude Code")
    }

    @Test
    func supportsAllCapabilities() {
        for capability in ProviderCapability.allCases {
            #expect(provider.supports(capability))
        }
    }

    @Test
    func navigationItems_includesAllEight() {
        #expect(provider.navigationItems.count == 8)
    }

    @Test
    func toolDefinitions_coversAllClaudeTools() {
        let expectedTools = ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "Task"]
        for tool in expectedTools {
            #expect(provider.toolDefinitions[tool] != nil)
        }
    }

    @Test
    func toolIcon_unknownTool_returnsFallback() {
        #expect(provider.toolIcon(for: "UnknownTool") == "wrench")
    }

    @Test
    func configurationItems_hasSevenItems() {
        #expect(provider.configurationItems.count == 7)
    }

    @Test
    func projectsPath_endsWithClaudeProjects() {
        #expect(provider.projectsPath.hasSuffix(".claude/projects"))
    }
}
