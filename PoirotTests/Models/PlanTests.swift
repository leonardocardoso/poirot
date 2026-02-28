@testable import Poirot
import Foundation
import Testing

@Suite("Plan")
struct PlanTests {
    @Test
    func humanize_convertsDashSlugs() {
        let result = Plan.humanize(slug: "abstract-wobbling-mccarthy")
        #expect(result == "Abstract Wobbling Mccarthy")
    }

    @Test
    func humanize_convertsUnderscoreSlugs() {
        let result = Plan.humanize(slug: "some_plan_name")
        #expect(result == "Some Plan Name")
    }

    @Test
    func humanize_handlesSingleWord() {
        let result = Plan.humanize(slug: "plan")
        #expect(result == "Plan")
    }

    @Test
    func humanize_handlesMixedSeparators() {
        let result = Plan.humanize(slug: "my-plan_name")
        #expect(result == "My Plan Name")
    }

    @Test
    func humanize_handlesEmptyString() {
        let result = Plan.humanize(slug: "")
        #expect(result == "")
    }

    @Test
    func identifiable_usesIdProperty() {
        let plan = Plan(
            id: "test-slug",
            name: "Test Slug",
            content: "# Hello",
            fileURL: URL(fileURLWithPath: "/tmp/test-slug.md")
        )
        #expect(plan.id == "test-slug")
    }

    @Test
    func hashable_equalPlansHaveSameHash() {
        let url = URL(fileURLWithPath: "/tmp/test.md")
        let plan1 = Plan(id: "a", name: "A", content: "x", fileURL: url)
        let plan2 = Plan(id: "a", name: "A", content: "x", fileURL: url)
        #expect(plan1 == plan2)
        #expect(plan1.hashValue == plan2.hashValue)
    }

    @Test
    func hashable_differentPlansAreDifferent() {
        let plan1 = Plan(
            id: "a",
            name: "A",
            content: "x",
            fileURL: URL(fileURLWithPath: "/tmp/a.md")
        )
        let plan2 = Plan(
            id: "b",
            name: "B",
            content: "y",
            fileURL: URL(fileURLWithPath: "/tmp/b.md")
        )
        #expect(plan1 != plan2)
    }

    // MARK: - Delete

    @Test
    func delete_removesFileFromDisk() throws {
        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("PlanTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        let fileURL = tmpDir.appendingPathComponent("test-plan.md")
        try "# Test Plan".write(to: fileURL, atomically: true, encoding: .utf8)

        #expect(FileManager.default.fileExists(atPath: fileURL.path))

        let deleted = ClaudeConfigLoader.deleteConfigFile(at: fileURL.path)
        #expect(deleted)
        #expect(!FileManager.default.fileExists(atPath: fileURL.path))

        try? FileManager.default.removeItem(at: tmpDir)
    }

    // MARK: - Filter/Search Matching

    @Test
    func fuzzyMatch_matchesPlanName() {
        let result = HighlightedText.fuzzyMatch("Abstract Wobbling Mccarthy", query: "wobbling")
        #expect(result != nil)
        #expect(result!.score > 0)
    }

    @Test
    func fuzzyMatch_noMatchReturnNil() {
        let result = HighlightedText.fuzzyMatch("Abstract Wobbling", query: "zzzzz")
        #expect(result == nil)
    }

    @Test
    func fuzzyMatch_matchesPlanContent() {
        let content = "This plan describes the feature implementation steps"
        let result = HighlightedText.fuzzyMatch(content, query: "feature")
        #expect(result != nil)
        #expect(result!.score > 0)
    }
}
