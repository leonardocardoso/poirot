@testable import Poirot
import Testing

@Suite("SubAgent")
struct SubAgentTests {
    // MARK: - Built-in Count

    @Test
    func builtIn_hasFourAgents() {
        #expect(SubAgent.builtIn.count == 4)
    }

    // MARK: - Expected IDs

    @Test
    func builtIn_hasExpectedIds() {
        let ids = SubAgent.builtIn.map(\.id)
        #expect(ids.contains("explore"))
        #expect(ids.contains("plan"))
        #expect(ids.contains("bash"))
        #expect(ids.contains("general"))
    }

    // MARK: - Non-Empty Fields

    @Test
    func builtIn_allHaveNonEmptyFields() {
        for agent in SubAgent.builtIn {
            #expect(!agent.name.isEmpty)
            #expect(!agent.icon.isEmpty)
            #expect(!agent.description.isEmpty)
            #expect(!agent.tools.isEmpty)
        }
    }

    // MARK: - Explore Agent Tools

    @Test
    func builtIn_exploreAgent_hasExpectedTools() {
        let explore = SubAgent.builtIn.first { $0.id == "explore" }!
        #expect(explore.tools.contains("Glob"))
        #expect(explore.tools.contains("Grep"))
        #expect(explore.tools.contains("Read"))
        #expect(explore.tools.contains("Bash"))
    }

    // MARK: - Bash Agent Tools

    @Test
    func builtIn_bashAgent_hasOnlyBashTool() {
        let bash = SubAgent.builtIn.first { $0.id == "bash" }!
        #expect(bash.tools == ["Bash"])
    }

    // MARK: - Built-in Scope

    @Test
    func builtIn_allAreBuiltInScope() {
        for agent in SubAgent.builtIn {
            #expect(agent.isBuiltIn)
            #expect(agent.scope == .builtIn)
            #expect(agent.filePath == nil)
        }
    }

    // MARK: - Known Tools

    @Test
    func knownTools_isNonEmpty() {
        #expect(!SubAgent.knownTools.isEmpty)
        #expect(SubAgent.knownTools.contains("Bash"))
        #expect(SubAgent.knownTools.contains("Read"))
    }
}
