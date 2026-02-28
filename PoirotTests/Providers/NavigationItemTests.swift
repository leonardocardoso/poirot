@testable import Poirot
import Testing

@Suite("NavigationItem")
struct NavigationItemTests {
    @Test
    func allItems_hasTenItems() {
        #expect(NavigationItem.allItems.count == 10)
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
