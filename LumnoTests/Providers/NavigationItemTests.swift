@testable import Lumno
import Testing

@Suite("NavigationItem")
struct NavigationItemTests {
    @Test
    func allItems_hasFourItems() {
        #expect(NavigationItem.allItems.count == 4)
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
