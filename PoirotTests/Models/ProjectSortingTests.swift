@testable import Poirot
import Foundation
import Testing

@Suite("ProjectSortOption")
struct ProjectSortOptionTests {
    @Test
    func allCases_hasThreeOptions() {
        #expect(ProjectSortOption.allCases.count == 3)
    }

    @Test
    func rawValues_areCorrect() {
        #expect(ProjectSortOption.recentActivity.rawValue == "recentActivity")
        #expect(ProjectSortOption.name.rawValue == "name")
        #expect(ProjectSortOption.sessionCount.rawValue == "sessionCount")
    }

    @Test
    func label_returnsLocalizedStrings() {
        // Labels should be non-empty localized strings
        #expect(!ProjectSortOption.recentActivity.label.isEmpty)
        #expect(!ProjectSortOption.name.label.isEmpty)
        #expect(!ProjectSortOption.sessionCount.label.isEmpty)
    }
}

@Suite("SessionLayout")
struct SessionLayoutTests {
    @Test
    func rawValues_areCorrect() {
        #expect(SessionLayout.grid.rawValue == "grid")
        #expect(SessionLayout.list.rawValue == "list")
    }

    @Test
    func initFromRawValue_worksForValidValues() {
        #expect(SessionLayout(rawValue: "grid") == .grid)
        #expect(SessionLayout(rawValue: "list") == .list)
    }

    @Test
    func initFromRawValue_returnsNilForInvalid() {
        #expect(SessionLayout(rawValue: "tiles") == nil)
    }
}
