import Foundation

/// AI-generated session analysis facets from `~/.claude/usage-data/facets/<sessionId>.json`.
nonisolated struct SessionFacets: Codable, Identifiable, Hashable {
    let sessionId: String
    let underlyingGoal: String
    let goalCategories: [String: Int]
    let outcome: String
    let userSatisfactionCounts: [String: Int]
    let claudeHelpfulness: String
    let sessionType: String
    let frictionCounts: [String: Int]
    let frictionDetail: String
    let primarySuccess: String
    let briefSummary: String

    var id: String { sessionId }

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case underlyingGoal = "underlying_goal"
        case goalCategories = "goal_categories"
        case outcome
        case userSatisfactionCounts = "user_satisfaction_counts"
        case claudeHelpfulness = "claude_helpfulness"
        case sessionType = "session_type"
        case frictionCounts = "friction_counts"
        case frictionDetail = "friction_detail"
        case primarySuccess = "primary_success"
        case briefSummary = "brief_summary"
    }

    // MARK: - Display Helpers

    /// Sorted goal categories by count (descending).
    var sortedGoalCategories: [(name: String, count: Int)] {
        goalCategories
            .sorted { $0.value > $1.value }
            .map { (name: $0.key, count: $0.value) }
    }

    /// Total friction event count.
    var totalFrictionCount: Int {
        frictionCounts.values.reduce(0, +)
    }

    /// Sorted friction items by count (descending).
    var sortedFrictionItems: [(name: String, count: Int)] {
        frictionCounts
            .filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
            .map { (name: $0.key, count: $0.value) }
    }

    /// Human-readable outcome label.
    var outcomeLabel: String {
        switch outcome {
        case "success": String(localized: "Success")
        case "partially_achieved": String(localized: "Partial")
        case "unclear_from_transcript": String(localized: "Unclear")
        case "failure": String(localized: "Failed")
        default: outcome.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    /// Human-readable helpfulness label.
    var helpfulnessLabel: String {
        switch claudeHelpfulness {
        case "very_helpful": String(localized: "Very Helpful")
        case "slightly_helpful": String(localized: "Slightly Helpful")
        case "not_helpful": String(localized: "Not Helpful")
        case "harmful": String(localized: "Harmful")
        default: claudeHelpfulness.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    /// Human-readable session type label.
    var sessionTypeLabel: String {
        sessionType.replacingOccurrences(of: "_", with: " ").capitalized
    }

    /// Human-readable category label.
    static func categoryLabel(_ category: String) -> String {
        category.replacingOccurrences(of: "_", with: " ").capitalized
    }

    /// Human-readable friction label.
    static func frictionLabel(_ friction: String) -> String {
        friction.replacingOccurrences(of: "_", with: " ").capitalized
    }
}
