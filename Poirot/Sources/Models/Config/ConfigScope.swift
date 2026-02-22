import Foundation

/// Indicates whether a config item comes from global or project-level scope.
enum ConfigScope: String, Sendable {
    case global  // ~/.claude/
    case project // <project>/.claude/
}
