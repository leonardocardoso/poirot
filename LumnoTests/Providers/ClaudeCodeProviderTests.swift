import Testing
@testable import Lumno

@Suite("ClaudeCodeProvider")
struct ClaudeCodeProviderTests {
    let provider = ClaudeCodeProvider()

    @Test func name_isClaudeCode() {
        #expect(provider.name == "Claude Code")
    }

    @Test func supportsAllCapabilities() {
        for capability in ProviderCapability.allCases {
            #expect(provider.supports(capability))
        }
    }

    @Test func navigationItems_includesAllFour() {
        #expect(provider.navigationItems.count == 4)
    }

    @Test func toolDefinitions_coversAllClaudeTools() {
        let expectedTools = ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "Task"]
        for tool in expectedTools {
            #expect(provider.toolDefinitions[tool] != nil)
        }
    }

    @Test func toolIcon_unknownTool_returnsFallback() {
        #expect(provider.toolIcon(for: "UnknownTool") == "wrench")
    }

    @Test func configurationItems_hasSixItems() {
        #expect(provider.configurationItems.count == 6)
    }

    @Test func projectsPath_endsWithClaudeProjects() {
        #expect(provider.projectsPath.hasSuffix(".claude/projects"))
    }
}
