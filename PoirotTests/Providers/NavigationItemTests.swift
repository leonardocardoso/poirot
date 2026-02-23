@testable import Poirot
import Testing

@Suite("NavigationItem")
struct NavigationItemTests {
    @Test
    func allItems_hasSevenItems() {
        #expect(NavigationItem.allItems.count == 8)
    }

    @Test
    func sessions_hasNoRequiredCapability() {
        #expect(NavigationItem.sessions.requiredCapability == nil)
    }

    @Test
    func skills_requiresSkillsCapability() {
        #expect(NavigationItem.skills.requiredCapability == .skills)
    }
}
