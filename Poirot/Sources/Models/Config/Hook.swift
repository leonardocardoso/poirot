import Foundation

// MARK: - Hook Event

enum HookEvent: String, CaseIterable, Sendable, Identifiable {
    case preToolUse = "PreToolUse"
    case postToolUse = "PostToolUse"
    case postToolUseFailure = "PostToolUseFailure"
    case permissionRequest = "PermissionRequest"
    case sessionStart = "SessionStart"
    case sessionEnd = "SessionEnd"
    case userPromptSubmit = "UserPromptSubmit"
    case notification = "Notification"
    case subagentStart = "SubagentStart"
    case subagentStop = "SubagentStop"
    case stop = "Stop"
    case teammateIdle = "TeammateIdle"
    case taskCompleted = "TaskCompleted"
    case instructionsLoaded = "InstructionsLoaded"
    case configChange = "ConfigChange"
    case worktreeCreate = "WorktreeCreate"
    case worktreeRemove = "WorktreeRemove"
    case preCompact = "PreCompact"

    var id: String { rawValue }

    var label: String { rawValue }

    var description: String {
        switch self {
        case .preToolUse: "Before a tool call executes (can block)"
        case .postToolUse: "After a tool call succeeds"
        case .postToolUseFailure: "After a tool call fails"
        case .permissionRequest: "When a permission dialog appears"
        case .sessionStart: "When a session begins or resumes"
        case .sessionEnd: "When a session terminates"
        case .userPromptSubmit: "When a prompt is submitted"
        case .notification: "When a notification is sent"
        case .subagentStart: "When a subagent is spawned"
        case .subagentStop: "When a subagent finishes"
        case .stop: "When Claude finishes responding"
        case .teammateIdle: "When a teammate is about to go idle"
        case .taskCompleted: "When a task is marked completed"
        case .instructionsLoaded: "When CLAUDE.md or rules are loaded"
        case .configChange: "When a config file changes"
        case .worktreeCreate: "When a worktree is being created"
        case .worktreeRemove: "When a worktree is being removed"
        case .preCompact: "Before context compaction"
        }
    }

    var supportsMatcher: Bool {
        switch self {
        case .preToolUse, .postToolUse, .postToolUseFailure, .permissionRequest,
             .sessionStart, .sessionEnd, .notification, .subagentStart, .subagentStop,
             .configChange, .preCompact:
            true
        case .userPromptSubmit, .stop, .teammateIdle, .taskCompleted,
             .worktreeCreate, .worktreeRemove, .instructionsLoaded:
            false
        }
    }

    var icon: String {
        switch self {
        case .preToolUse: "hand.raised"
        case .postToolUse: "checkmark.circle"
        case .postToolUseFailure: "xmark.circle"
        case .permissionRequest: "lock.shield"
        case .sessionStart: "play.circle"
        case .sessionEnd: "stop.circle"
        case .userPromptSubmit: "text.bubble"
        case .notification: "bell"
        case .subagentStart: "person.badge.plus"
        case .subagentStop: "person.badge.minus"
        case .stop: "stop.fill"
        case .teammateIdle: "person.crop.circle.badge.clock"
        case .taskCompleted: "checkmark.seal"
        case .instructionsLoaded: "doc.text"
        case .configChange: "gearshape"
        case .worktreeCreate: "plus.rectangle.on.folder"
        case .worktreeRemove: "minus.rectangle"
        case .preCompact: "arrow.down.right.and.arrow.up.left"
        }
    }
}

// MARK: - Hook Handler Type

enum HookHandlerType: String, CaseIterable, Sendable {
    case command
    case http

    var label: String {
        switch self {
        case .command: "Command"
        case .http: "HTTP"
        }
    }
}

// MARK: - Hook Handler

struct HookHandler: Sendable, Equatable {
    var type: HookHandlerType
    var command: String?
    var url: String?
    var timeout: Int?
    var statusMessage: String?

    var displayCommand: String {
        switch type {
        case .command: command ?? ""
        case .http: url ?? ""
        }
    }

    var defaultTimeout: Int {
        switch type {
        case .command: 600
        case .http: 30
        }
    }
}

// MARK: - Hook Matcher Group

struct HookMatcherGroup: Sendable, Equatable {
    var matcher: String?
    var handlers: [HookHandler]
}

// MARK: - Hook Entry (flattened for display)

struct HookEntry: Identifiable, Sendable {
    let id: String
    let event: HookEvent
    let matcherGroupIndex: Int
    let matcherGroup: HookMatcherGroup
    let scope: ConfigScope

    var matcher: String? { matcherGroup.matcher }
    var handlers: [HookHandler] { matcherGroup.handlers }
    var handlerCount: Int { handlers.count }

    var firstHandler: HookHandler? { handlers.first }
}
