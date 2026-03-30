@testable import Poirot
import Foundation
import Testing

@Suite("SessionGroup")
struct SessionGroupTests {
    // MARK: - Helpers

    private func makeSession(
        id: String,
        startedAt: Date = .now,
        parentSessionId: String? = nil,
        isSidechain: Bool = false,
        agentType: String? = nil
    ) -> Session {
        Session(
            id: id,
            projectPath: "/test",
            messages: [],
            startedAt: startedAt,
            model: nil,
            totalTokens: 0,
            isSidechain: isSidechain,
            parentSessionId: parentSessionId,
            agentType: agentType
        )
    }

    // MARK: - Grouping

    @Test
    func group_parentWithAgents_groupsTogether() {
        let parent = makeSession(id: "p1", startedAt: Date(timeIntervalSince1970: 100))
        let agent1 = makeSession(id: "a1", startedAt: Date(timeIntervalSince1970: 110), parentSessionId: "p1", agentType: "Explore")
        let agent2 = makeSession(id: "a2", startedAt: Date(timeIntervalSince1970: 120), parentSessionId: "p1", agentType: "Plan")

        let groups = SessionGroup.group(sessions: [parent, agent1, agent2])

        #expect(groups.count == 1)
        #expect(groups[0].parent.id == "p1")
        #expect(groups[0].agents.count == 2)
        #expect(groups[0].agentCount == 2)
    }

    @Test
    func group_agentsSortedByStartTime() {
        let parent = makeSession(id: "p1", startedAt: Date(timeIntervalSince1970: 100))
        let agentLate = makeSession(id: "a2", startedAt: Date(timeIntervalSince1970: 300), parentSessionId: "p1")
        let agentEarly = makeSession(id: "a1", startedAt: Date(timeIntervalSince1970: 200), parentSessionId: "p1")

        let groups = SessionGroup.group(sessions: [parent, agentLate, agentEarly])

        #expect(groups[0].agents[0].id == "a1")
        #expect(groups[0].agents[1].id == "a2")
    }

    @Test
    func group_multipleParents_createsSeparateGroups() {
        let parent1 = makeSession(id: "p1", startedAt: Date(timeIntervalSince1970: 200))
        let parent2 = makeSession(id: "p2", startedAt: Date(timeIntervalSince1970: 100))
        let agent1 = makeSession(id: "a1", startedAt: Date(timeIntervalSince1970: 210), parentSessionId: "p1")
        let agent2 = makeSession(id: "a2", startedAt: Date(timeIntervalSince1970: 110), parentSessionId: "p2")

        let groups = SessionGroup.group(sessions: [parent1, parent2, agent1, agent2])

        #expect(groups.count == 2)
        #expect(groups[0].parent.id == "p1")
        #expect(groups[0].agents.count == 1)
        #expect(groups[1].parent.id == "p2")
        #expect(groups[1].agents.count == 1)
    }

    @Test
    func group_parentWithNoAgents_createsGroupWithEmptyAgents() {
        let parent = makeSession(id: "p1")

        let groups = SessionGroup.group(sessions: [parent])

        #expect(groups.count == 1)
        #expect(groups[0].agents.isEmpty)
        #expect(groups[0].agentCount == 0)
    }

    @Test
    func group_orphanSidechain_becomesStandaloneGroup() {
        let orphan = makeSession(id: "o1", isSidechain: true)

        let groups = SessionGroup.group(sessions: [orphan])

        #expect(groups.count == 1)
        #expect(groups[0].parent.id == "o1")
        #expect(groups[0].agents.isEmpty)
    }

    @Test
    func group_emptySessions_returnsEmpty() {
        let groups = SessionGroup.group(sessions: [])
        #expect(groups.isEmpty)
    }

    @Test
    func group_sortedDescendingByParentStartTime() {
        let oldest = makeSession(id: "p1", startedAt: Date(timeIntervalSince1970: 100))
        let newest = makeSession(id: "p2", startedAt: Date(timeIntervalSince1970: 300))
        let middle = makeSession(id: "p3", startedAt: Date(timeIntervalSince1970: 200))

        let groups = SessionGroup.group(sessions: [oldest, newest, middle])

        #expect(groups[0].parent.id == "p2")
        #expect(groups[1].parent.id == "p3")
        #expect(groups[2].parent.id == "p1")
    }

    // MARK: - Computed Properties

    @Test
    func allSessions_includesParentAndAgents() {
        let parent = makeSession(id: "p1", startedAt: Date(timeIntervalSince1970: 100))
        let agent = makeSession(id: "a1", startedAt: Date(timeIntervalSince1970: 110), parentSessionId: "p1")

        let groups = SessionGroup.group(sessions: [parent, agent])
        let all = groups[0].allSessions

        #expect(all.count == 2)
        #expect(all[0].id == "p1")
        #expect(all[1].id == "a1")
    }
}
