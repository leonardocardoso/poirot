@testable import Poirot
import Testing

@Suite("NavigationItem")
struct NavigationItemTests {
    @Test
    func allItems_hasElevenItems() {
        #expect(NavigationItem.allItems.count == 11)
    }

    @Test
    func analytics_hasNoRequiredCapability() {
        #expect(NavigationItem.analytics.requiredCapability == nil)
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
}
