@testable import Poirot
import Testing

@Suite("NavigationItem")
struct NavigationItemTests {
    @Test
    func allItems_hasFourteenItems() {
        #expect(NavigationItem.allItems.count == 14)
    }

    @Test
    func analytics_hasNoRequiredCapability() {
        #expect(NavigationItem.analytics.requiredCapability == nil)
    }

    @Test
    func history_hasNoRequiredCapability() {
        #expect(NavigationItem.history.requiredCapability == nil)
    }

    @Test
    func history_hasCorrectSystemImage() {
        #expect(NavigationItem.history.systemImage == "clock.arrow.circlepath")
    }

    @Test
    func analytics_hasCorrectSystemImage() {
        #expect(NavigationItem.analytics.systemImage == "chart.xyaxis.line")
    }

    @Test
    func sessions_hasNoRequiredCapability() {
        #expect(NavigationItem.sessions.requiredCapability == nil)
    }

    @Test
    func skills_requiresSkillsCapability() {
        #expect(NavigationItem.skills.requiredCapability == .skills)
    }

    @Test
    func plans_requiresPlansCapability() {
        #expect(NavigationItem.plans.requiredCapability == .plans)
    }

    @Test
    func memory_requiresMemoryCapability() {
        #expect(NavigationItem.memory.requiredCapability == .memory)
    }

    @Test
    func memory_hasCorrectSystemImage() {
        #expect(NavigationItem.memory.systemImage == "brain.head.profile.fill")
    }
}
