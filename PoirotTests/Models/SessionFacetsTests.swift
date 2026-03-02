@testable import Poirot
import Foundation
import Testing

@Suite("SessionFacets")
struct SessionFacetsTests {
    // MARK: - Decoding

    @Test
    func decodesFullJSON() throws {
        let json = """
        {
          "underlying_goal": "Refactor auth to JWT",
          "goal_categories": {"refactoring": 2, "security": 1},
          "outcome": "success",
          "user_satisfaction_counts": {"likely_satisfied": 1},
          "claude_helpfulness": "very_helpful",
          "session_type": "feature_implementation",
          "friction_counts": {"tool_failures": 1, "misunderstandings": 0},
          "friction_detail": "One tool call timed out",
          "primary_success": "multi_file_changes",
          "brief_summary": "Migrated session auth from cookies to JWT.",
          "session_id": "abc-123"
        }
        """
        let data = Data(json.utf8)
        let facets = try JSONDecoder().decode(SessionFacets.self, from: data)

        #expect(facets.sessionId == "abc-123")
        #expect(facets.underlyingGoal == "Refactor auth to JWT")
        #expect(facets.goalCategories == ["refactoring": 2, "security": 1])
        #expect(facets.outcome == "success")
        #expect(facets.claudeHelpfulness == "very_helpful")
        #expect(facets.sessionType == "feature_implementation")
        #expect(facets.frictionCounts == ["tool_failures": 1, "misunderstandings": 0])
        #expect(facets.frictionDetail == "One tool call timed out")
        #expect(facets.primarySuccess == "multi_file_changes")
        #expect(facets.briefSummary == "Migrated session auth from cookies to JWT.")
        #expect(facets.userSatisfactionCounts == ["likely_satisfied": 1])
    }

    @Test
    func decodesEmptyDictionaries() throws {
        let json = """
        {
          "underlying_goal": "Quick question",
          "goal_categories": {},
          "outcome": "success",
          "user_satisfaction_counts": {},
          "claude_helpfulness": "very_helpful",
          "session_type": "single_task",
          "friction_counts": {},
          "friction_detail": "",
          "primary_success": "none",
          "brief_summary": "Answered a question.",
          "session_id": "def-456"
        }
        """
        let data = Data(json.utf8)
        let facets = try JSONDecoder().decode(SessionFacets.self, from: data)

        #expect(facets.goalCategories.isEmpty)
        #expect(facets.frictionCounts.isEmpty)
        #expect(facets.totalFrictionCount == 0)
    }

    // MARK: - Identifiable / Hashable

    @Test
    func id_matchesSessionId() throws {
        let json = """
        {
          "underlying_goal": "Test",
          "goal_categories": {},
          "outcome": "success",
          "user_satisfaction_counts": {},
          "claude_helpfulness": "very_helpful",
          "session_type": "single_task",
          "friction_counts": {},
          "friction_detail": "",
          "primary_success": "none",
          "brief_summary": "Test",
          "session_id": "test-id-789"
        }
        """
        let data = Data(json.utf8)
        let facets = try JSONDecoder().decode(SessionFacets.self, from: data)

        #expect(facets.id == "test-id-789")
    }

    // MARK: - Display Helpers

    @Test
    func sortedGoalCategories_orderedByCountDescending() throws {
        let facets = try makeFacets(goalCategories: ["security": 1, "refactoring": 3, "testing": 2])
        let sorted = facets.sortedGoalCategories

        #expect(sorted.count == 3)
        #expect(sorted[0].name == "refactoring")
        #expect(sorted[0].count == 3)
        #expect(sorted[1].name == "testing")
        #expect(sorted[2].name == "security")
    }

    @Test
    func totalFrictionCount_sumsValues() throws {
        let facets = try makeFacets(frictionCounts: ["tool_failures": 2, "misunderstandings": 1])
        #expect(facets.totalFrictionCount == 3)
    }

    @Test
    func sortedFrictionItems_filtersZeroValues() throws {
        let facets = try makeFacets(frictionCounts: ["tool_failures": 2, "misunderstandings": 0, "buggy_code": 1])
        let sorted = facets.sortedFrictionItems

        #expect(sorted.count == 2)
        #expect(sorted[0].name == "tool_failures")
        #expect(sorted[1].name == "buggy_code")
    }

    @Test
    func outcomeLabel_mapsKnownValues() throws {
        #expect(try makeFacets(outcome: "success").outcomeLabel == "Success")
        #expect(try makeFacets(outcome: "partially_achieved").outcomeLabel == "Partial")
        #expect(try makeFacets(outcome: "unclear_from_transcript").outcomeLabel == "Unclear")
        #expect(try makeFacets(outcome: "failure").outcomeLabel == "Failed")
        #expect(try makeFacets(outcome: "some_other").outcomeLabel == "Some Other")
    }

    @Test
    func helpfulnessLabel_mapsKnownValues() throws {
        #expect(try makeFacets(helpfulness: "very_helpful").helpfulnessLabel == "Very Helpful")
        #expect(try makeFacets(helpfulness: "slightly_helpful").helpfulnessLabel == "Slightly Helpful")
        #expect(try makeFacets(helpfulness: "not_helpful").helpfulnessLabel == "Not Helpful")
        #expect(try makeFacets(helpfulness: "harmful").helpfulnessLabel == "Harmful")
    }

    @Test
    func sessionTypeLabel_formatsUnderscores() throws {
        let facets = try makeFacets(sessionType: "feature_implementation")
        #expect(facets.sessionTypeLabel == "Feature Implementation")
    }

    @Test
    func categoryLabel_formatsUnderscores() {
        #expect(SessionFacets.categoryLabel("fix_bugs") == "Fix Bugs")
        #expect(SessionFacets.categoryLabel("write_tests") == "Write Tests")
    }

    @Test
    func frictionLabel_formatsUnderscores() {
        #expect(SessionFacets.frictionLabel("tool_failures") == "Tool Failures")
        #expect(SessionFacets.frictionLabel("buggy_code") == "Buggy Code")
    }

    // MARK: - Helpers

    private func makeFacets(
        outcome: String = "success",
        helpfulness: String = "very_helpful",
        sessionType: String = "single_task",
        goalCategories: [String: Int] = [:],
        frictionCounts: [String: Int] = [:]
    ) throws -> SessionFacets {
        var goalCatsJSON = "{"
        goalCatsJSON += goalCategories.map { "\"\($0.key)\": \($0.value)" }.joined(separator: ", ")
        goalCatsJSON += "}"

        var frictionJSON = "{"
        frictionJSON += frictionCounts.map { "\"\($0.key)\": \($0.value)" }.joined(separator: ", ")
        frictionJSON += "}"

        let json = """
        {
          "underlying_goal": "Test goal",
          "goal_categories": \(goalCatsJSON),
          "outcome": "\(outcome)",
          "user_satisfaction_counts": {},
          "claude_helpfulness": "\(helpfulness)",
          "session_type": "\(sessionType)",
          "friction_counts": \(frictionJSON),
          "friction_detail": "",
          "primary_success": "none",
          "brief_summary": "Test summary",
          "session_id": "test-\(UUID().uuidString)"
        }
        """
        return try JSONDecoder().decode(SessionFacets.self, from: Data(json.utf8))
    }
}
