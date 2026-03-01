@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("Facets Screenshots")
struct ScreenshotTests_Facets {
    private let isRecording = false

    @Test
    func testFacetsCardExpanded() {
        let facets = Self.sampleFacets
        snapshotView(
            SessionFacetsCard(facets: facets)
                .padding(PoirotTheme.Spacing.md)
                .frame(maxWidth: .infinity)
                .background(PoirotTheme.Colors.bgApp),
            size: CGSize(width: 700, height: 340),
            named: "testFacetsCardExpanded",
            record: isRecording
        )
    }

    @Test
    func testFacetsCardLight() {
        let facets = Self.sampleFacets
        snapshotView(
            SessionFacetsCard(facets: facets)
                .padding(PoirotTheme.Spacing.md)
                .frame(maxWidth: .infinity)
                .background(PoirotTheme.Colors.bgApp),
            size: CGSize(width: 700, height: 340),
            named: "testFacetsCardLight",
            record: isRecording,
            colorScheme: .light
        )
    }

    @Test
    func testFacetsCardPartialOutcome() {
        let facets = Self.partialFacets
        snapshotView(
            SessionFacetsCard(facets: facets)
                .padding(PoirotTheme.Spacing.md)
                .frame(maxWidth: .infinity)
                .background(PoirotTheme.Colors.bgApp),
            size: CGSize(width: 700, height: 380),
            named: "testFacetsCardPartialOutcome",
            record: isRecording
        )
    }

    // MARK: - Sample Data

    private static let sampleFacets: SessionFacets = {
        let json = """
        {
          "underlying_goal": "Refactor authentication to use JWT tokens with refresh token rotation",
          "goal_categories": {"refactoring": 2, "security": 1, "code_refactoring": 1},
          "outcome": "success",
          "user_satisfaction_counts": {"likely_satisfied": 1},
          "claude_helpfulness": "very_helpful",
          "session_type": "feature_implementation",
          "friction_counts": {},
          "friction_detail": "",
          "primary_success": "multi_file_changes",
          "brief_summary": "Migrated session auth from cookies to JWT with refresh token rotation. Updated middleware, auth routes, and added comprehensive test coverage.",
          "session_id": "screenshot-facets-1"
        }
        """
        return try! JSONDecoder().decode(SessionFacets.self, from: Data(json.utf8)) // swiftlint:disable:this force_try
    }()

    private static let partialFacets: SessionFacets = {
        let json = """
        {
          "underlying_goal": "Fix CI pipeline failures and add missing integration tests",
          "goal_categories": {"fix_bugs": 2, "write_tests": 1, "create_pr": 1},
          "outcome": "partially_achieved",
          "user_satisfaction_counts": {"likely_satisfied": 1},
          "claude_helpfulness": "slightly_helpful",
          "session_type": "multi_task",
          "friction_counts": {"buggy_code": 1, "tool_failures": 2},
          "friction_detail": "Unit tests initially failed due to coverage thresholds not being met, requiring additional test writing.",
          "primary_success": "multi_file_changes",
          "brief_summary": "Fixed most CI pipeline issues and created a PR, but some integration tests still need attention.",
          "session_id": "screenshot-facets-2"
        }
        """
        return try! JSONDecoder().decode(SessionFacets.self, from: Data(json.utf8)) // swiftlint:disable:this force_try
    }()
}
