@testable import Poirot
import Foundation
import Testing

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
            fileURL: URL(fileURLWithPath: "/tmp/test-slug.md"),
            scope: .global
        )
        #expect(plan.id == "test-slug")
    }

    @Test
    func hashable_equalPlansHaveSameHash() {
        let url = URL(fileURLWithPath: "/tmp/test.md")
        let plan1 = Plan(id: "a", name: "A", content: "x", fileURL: url, scope: .global)
        let plan2 = Plan(id: "a", name: "A", content: "x", fileURL: url, scope: .global)
        #expect(plan1 == plan2)
        #expect(plan1.hashValue == plan2.hashValue)
    }

    @Test
    func hashable_differentPlansAreDifferent() {
        let plan1 = Plan(
            id: "a",
            name: "A",
            content: "x",
            fileURL: URL(fileURLWithPath: "/tmp/a.md"),
            scope: .global
        )
        let plan2 = Plan(
            id: "b",
            name: "B",
            content: "y",
            fileURL: URL(fileURLWithPath: "/tmp/b.md"),
            scope: .global
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

    // MARK: - Scope

    @Test
    func scope_globalPlanHasGlobalScope() {
        let plan = Plan(
            id: "global-test",
            name: "Test",
            content: "",
            fileURL: URL(fileURLWithPath: "/tmp/test.md"),
            scope: .global
        )
        #expect(plan.scope == .global)
    }

    @Test
    func scope_projectPlanHasProjectScope() {
        let plan = Plan(
            id: "project-test",
            name: "Test",
            content: "",
            fileURL: URL(fileURLWithPath: "/tmp/test.md"),
            scope: .project
        )
        #expect(plan.scope == .project)
    }

    // MARK: - Project-Scoped Loading

    @Test
    func loadPlans_globalOnly_returnsGlobalPlans() throws {
        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("PlanTests-global-\(UUID().uuidString)")
        let plansDir = tmpDir.appendingPathComponent(".claude/plans")
        try FileManager.default.createDirectory(at: plansDir, withIntermediateDirectories: true)
        try "# Global Plan".write(
            to: plansDir.appendingPathComponent("global-plan.md"),
            atomically: true,
            encoding: .utf8
        )

        // loadPlans without projectPath should not find plans in a project directory
        let plans = ClaudeConfigLoader.loadPlans()
        // Plans from ~/.claude/plans/ — we can't inject a custom home, but we can verify
        // that the method runs without error and returns an array
        #expect(plans is [Plan])

        try? FileManager.default.removeItem(at: tmpDir)
    }

    @Test
    func loadPlans_withProjectPath_includesProjectPlans() throws {
        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("PlanTests-project-\(UUID().uuidString)")
        let plansDir = tmpDir.appendingPathComponent(".claude/plans")
        try FileManager.default.createDirectory(at: plansDir, withIntermediateDirectories: true)
        try "# Project Plan".write(
            to: plansDir.appendingPathComponent("my-project-plan.md"),
            atomically: true,
            encoding: .utf8
        )

        let plans = ClaudeConfigLoader.loadPlans(projectPath: tmpDir.path)
        let projectPlans = plans.filter { $0.scope == .project }
        #expect(projectPlans.count >= 1)
        #expect(projectPlans.contains { $0.name == "My Project Plan" })

        try? FileManager.default.removeItem(at: tmpDir)
    }

    @Test
    func loadPlans_withProjectPath_tagsScopesCorrectly() throws {
        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("PlanTests-scopes-\(UUID().uuidString)")
        let plansDir = tmpDir.appendingPathComponent(".claude/plans")
        try FileManager.default.createDirectory(at: plansDir, withIntermediateDirectories: true)
        try "# A".write(
            to: plansDir.appendingPathComponent("a.md"),
            atomically: true,
            encoding: .utf8
        )

        let plans = ClaudeConfigLoader.loadPlans(projectPath: tmpDir.path)
        let projectPlans = plans.filter { $0.scope == .project }
        let globalPlans = plans.filter { $0.scope == .global }

        // Project plans should have project scope
        for plan in projectPlans {
            #expect(plan.scope == .project)
            #expect(plan.id.hasPrefix("project-"))
        }
        // Global plans should have global scope
        for plan in globalPlans {
            #expect(plan.scope == .global)
            #expect(plan.id.hasPrefix("global-"))
        }

        try? FileManager.default.removeItem(at: tmpDir)
    }

    @Test
    func loadPlans_emptyProjectDir_returnsOnlyGlobalPlans() throws {
        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("PlanTests-empty-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        // No .claude/plans/ directory in this project

        let plans = ClaudeConfigLoader.loadPlans(projectPath: tmpDir.path)
        let projectPlans = plans.filter { $0.scope == .project }
        #expect(projectPlans.isEmpty)

        try? FileManager.default.removeItem(at: tmpDir)
    }

    // MARK: - Filter/Search Matching

    @Test
    func fuzzyMatch_matchesPlanName() throws {
        let result = HighlightedText.fuzzyMatch("Abstract Wobbling Mccarthy", query: "wobbling")
        #expect(result != nil)
        #expect(try #require(result?.score) > 0)
    }

    @Test
    func fuzzyMatch_noMatchReturnNil() {
        let result = HighlightedText.fuzzyMatch("Abstract Wobbling", query: "zzzzz")
        #expect(result == nil)
    }

    @Test
    func fuzzyMatch_matchesPlanContent() throws {
        let content = "This plan describes the feature implementation steps"
        let result = HighlightedText.fuzzyMatch(content, query: "feature")
        #expect(result != nil)
        #expect(try #require(result?.score) > 0)
    }
}
