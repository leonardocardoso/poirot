@testable import Poirot
import Foundation

// MARK: - Screenshot Mock Data Factory

enum ScreenshotData {
    // MARK: - Timestamps (fixed for deterministic snapshots)

    // 2026-02-20 14:30:00 UTC — a fixed reference point so snapshots are stable
    private static let baseDate = Date(timeIntervalSince1970: 1_771_598_200)
    private static func hoursAgo(_ h: Int) -> Date { baseDate.addingTimeInterval(-Double(h) * 3600) }
    private static func minutesAgo(_ m: Int) -> Date { baseDate.addingTimeInterval(-Double(m) * 60) }

    // MARK: - Projects

    static let projects: [Project] = [
        Project(
            id: "-Users-leo-Dev-poirot",
            name: "poirot",
            path: "/Users/leo/Dev/poirot",
            sessions: [conversationSession, toolBlocksSession, thinkingSession, editDiffSession, writeToolSession]
        ),
        Project(
            id: "-Users-leo-Dev-reellette-ios",
            name: "reellette-ios",
            path: "/Users/leo/Dev/reellette-ios",
            sessions: [serverSession, migrationSession, taskToolSession]
        ),
        Project(
            id: "-Users-leo-Dev-swift-openapi",
            name: "swift-openapi",
            path: "/Users/leo/Dev/swift-openapi",
            sessions: [pipelineSession, errorToolSession]
        ),
        Project(
            id: "-Users-leo-Dev-ignio-web",
            name: "ignio-web",
            path: "/Users/leo/Dev/ignio-web",
            sessions: [longContentSession]
        ),
    ]

    // MARK: - Conversation Session (rich multi-turn)

    static let conversationSession = Session(
        id: "conv-001",
        projectPath: "/Users/leo/Dev/poirot",
        messages: conversationMessages,
        startedAt: minutesAgo(45),
        model: "claude-opus-4-6",
        totalTokens: 34200
    )

    static let conversationMessages: [Message] = [
        Message(
            id: "m1",
            role: .user,
            content: [
                .text(
                    "The sidebar doesn't show session counts next to each project. Add a badge with the session count, and make it match the accent color when the project is selected."
                ),
            ],
            timestamp: minutesAgo(45),
            model: nil,
            tokenUsage: nil
        ),
        Message(
            id: "m2",
            role: .assistant,
            content: [
                .thinking("""
                The user wants session count badges in the sidebar next to project names. Looking at the SidebarView, each project is rendered via ProjectRow. I need to:

                1. Read the current SidebarView to understand the layout
                2. Add a badge showing session count (project.sessions.count)
                3. Use PoirotTheme.Colors.accent when the project is selected, secondary otherwise
                4. Keep it compact — probably a small rounded rect with the count text

                Let me check the existing sidebar implementation first.
                """),
                .text("""
                I'll add session count badges to each project row in the sidebar. The badge will use accent color when selected:

                ```swift
                Text("\\(project.sessions.count)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? PoirotTheme.Colors.accent : .secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isSelected ? PoirotTheme.Colors.accent.opacity(0.15) : Color.secondary.opacity(0.1))
                    )
                ```

                Let me start by reading the current implementation.
                """),
            ],
            timestamp: minutesAgo(44),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 1800, output: 920)
        ),
        Message(
            id: "m3",
            role: .assistant,
            content: [
                .toolUse(ToolUse(
                    id: "tu1",
                    name: "Read",
                    input: ["file_path": "Poirot/Sources/Views/Components/SidebarView.swift"]
                )),
            ],
            timestamp: minutesAgo(43),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 400, output: 180)
        ),
        Message(
            id: "m3-result",
            role: .user,
            content: [
                .toolResult(ToolResult(
                    id: "tr1",
                    toolUseId: "tu1",
                    content: """
                    import SwiftUI

                    struct SidebarView: View {
                        @Environment(AppState.self) private var appState
                        @Environment(\\.provider) private var provider

                        var body: some View {
                            VStack(spacing: 0) {
                                navItems
                                Divider()
                                searchBar
                                projectsList
                            }
                            .background(PoirotTheme.Colors.bgSidebar)
                        }

                        private var projectsList: some View {
                            ScrollView {
                                LazyVStack(spacing: 2) {
                                    ForEach(appState.filteredSortedProjects) { project in
                                        ProjectRow(project: project)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    """,
                    isError: false
                )),
            ],
            timestamp: minutesAgo(43),
            model: nil,
            tokenUsage: nil
        ),
        Message(
            id: "m4",
            role: .assistant,
            content: [
                .text(
                    "I can see the sidebar structure. The `ProjectRow` renders each project. I'll add a session count badge to the trailing edge of each row."
                ),
                .toolUse(ToolUse(
                    id: "tu2",
                    name: "Edit",
                    input: [
                        "file_path": "Poirot/Sources/Views/Components/SidebarView.swift",
                        "old_string": "Text(project.name)\n                .font(.system(size: 13, weight: .medium))\n                .lineLimit(1)",
                        "new_string": "Text(project.name)\n                .font(.system(size: 13, weight: .medium))\n                .lineLimit(1)\n            Spacer()\n            Text(\"\\(project.sessions.count)\")\n                .font(.system(size: 11, weight: .semibold))\n                .foregroundStyle(isSelected ? PoirotTheme.Colors.accent : .secondary)\n                .padding(.horizontal, 6)\n                .padding(.vertical, 2)\n                .background(\n                    Capsule()\n                        .fill(isSelected ? PoirotTheme.Colors.accent.opacity(0.15) : Color.secondary.opacity(0.1))\n                )",
                    ]
                )),
            ],
            timestamp: minutesAgo(42),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 3200, output: 1400)
        ),
        Message(
            id: "m4-result",
            role: .user,
            content: [
                .toolResult(ToolResult(
                    id: "tr2",
                    toolUseId: "tu2",
                    content: "Successfully edited Poirot/Sources/Views/Components/SidebarView.swift",
                    isError: false
                )),
            ],
            timestamp: minutesAgo(42),
            model: nil,
            tokenUsage: nil
        ),
        Message(
            id: "m5",
            role: .assistant,
            content: [
                .toolUse(ToolUse(
                    id: "tu3",
                    name: "Bash",
                    input: [
                        "command": "cd /Users/leo/Dev/poirot && xcodebuild build -scheme Poirot -destination 'platform=macOS' 2>&1 | tail -5",
                    ]
                )),
            ],
            timestamp: minutesAgo(41),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 800, output: 220)
        ),
        Message(
            id: "m5-result",
            role: .user,
            content: [
                .toolResult(ToolResult(
                    id: "tr3",
                    toolUseId: "tu3",
                    content: "CompileSwiftSources normal arm64 com.apple.xcode.tools.swift.compiler\nLd /Users/leo/Library/Developer/Xcode/DerivedData/Poirot-abcdef/Build/Products/Debug/Poirot.app\nGenerateDSYMFile Poirot.app.dSYM\n** BUILD SUCCEEDED **",
                    isError: false
                )),
            ],
            timestamp: minutesAgo(41),
            model: nil,
            tokenUsage: nil
        ),
        Message(
            id: "m6",
            role: .assistant,
            content: [
                .text("""
                Done! The session count badge is now visible next to each project name in the sidebar:

                - Shows the count in a compact capsule shape
                - Uses the golden accent color when the project is selected
                - Falls back to secondary (gray) when not selected
                - Build succeeds with no warnings

                The badge uses `Capsule()` with a subtle fill for the background, matching the existing design system.
                """),
            ],
            timestamp: minutesAgo(40),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 4100, output: 580)
        ),
    ]

    // MARK: - Tool Blocks Session

    static let toolBlocksSession = Session(
        id: "tool-001",
        projectPath: "/Users/leo/Dev/poirot",
        messages: toolBlocksMessages,
        startedAt: hoursAgo(2),
        model: "claude-sonnet-4-6",
        totalTokens: 21400
    )

    static let toolBlocksMessages: [Message] = [
        Message(
            id: "t1",
            role: .user,
            content: [.text("Add a keyboard shortcut Cmd+T to toggle the tool filter bar in the session detail view")],
            timestamp: hoursAgo(2),
            model: nil,
            tokenUsage: nil
        ),
        Message(
            id: "t2",
            role: .assistant,
            content: [
                .text(
                    "I'll add the `Cmd+T` keyboard shortcut to toggle the tool filter. Let me find where shortcuts are registered."
                ),
                .toolUse(ToolUse(
                    id: "tu-grep",
                    name: "Grep",
                    input: ["pattern": "keyboardShortcut.*command", "path": "Poirot/Sources"]
                )),
                .toolUse(ToolUse(
                    id: "tu-glob",
                    name: "Glob",
                    input: ["pattern": "Poirot/Sources/**/*Shortcut*.swift"]
                )),
            ],
            timestamp: hoursAgo(2),
            model: "claude-sonnet-4-6",
            tokenUsage: TokenUsage(input: 900, output: 380)
        ),
        Message(
            id: "t2-result",
            role: .user,
            content: [
                .toolResult(ToolResult(
                    id: "tr-grep",
                    toolUseId: "tu-grep",
                    content: """
                    Poirot/Sources/App/ContentView.swift:29:            .keyboardShortcut(for: .search) {
                    Poirot/Sources/App/ContentView.swift:32:            .keyboardShortcut(for: .find) {
                    Poirot/Sources/App/ContentView.swift:40:            .keyboardShortcut(for: "[") {
                    Poirot/Sources/App/ContentView.swift:43:            .keyboardShortcut(for: "]") {
                    Poirot/Sources/Views/Session/SessionDetailView.swift:88:            .keyboardShortcut(.escape, modifiers: [])
                    """,
                    isError: false
                )),
                .toolResult(ToolResult(
                    id: "tr-glob",
                    toolUseId: "tu-glob",
                    content: """
                    Poirot/Sources/App/ContentView.swift
                    """,
                    isError: false
                )),
            ],
            timestamp: hoursAgo(2),
            model: nil,
            tokenUsage: nil
        ),
        Message(
            id: "t3",
            role: .assistant,
            content: [
                .text(
                    "The shortcuts are defined in `ContentView.swift` using the `.keyboardShortcut(for:)` helper. I'll add `Cmd+T` there."
                ),
                .toolUse(ToolUse(
                    id: "tu-edit",
                    name: "Edit",
                    input: [
                        "file_path": "Poirot/Sources/App/ContentView.swift",
                        "old_string": ".keyboardShortcut(for: \"]\") {\n                appState.navigateForward()\n            }",
                        "new_string": ".keyboardShortcut(for: \"]\") {\n                appState.navigateForward()\n            }\n            .keyboardShortcut(for: \"t\") {\n                if appState.selectedSession != nil {\n                    appState.isToolFilterActive.toggle()\n                    if !appState.isToolFilterActive {\n                        appState.activeToolFilters.removeAll()\n                    }\n                }\n            }",
                    ]
                )),
            ],
            timestamp: hoursAgo(2),
            model: "claude-sonnet-4-6",
            tokenUsage: TokenUsage(input: 2100, output: 750)
        ),
        Message(
            id: "t3-result",
            role: .user,
            content: [
                .toolResult(ToolResult(
                    id: "tr-edit",
                    toolUseId: "tu-edit",
                    content: "Successfully edited Poirot/Sources/App/ContentView.swift",
                    isError: false
                )),
            ],
            timestamp: hoursAgo(2),
            model: nil,
            tokenUsage: nil
        ),
        Message(
            id: "t4",
            role: .assistant,
            content: [
                .text(
                    "`Cmd+T` now toggles the tool filter bar. When toggled off, it also clears the active filters. The shortcut only activates when a session is selected."
                ),
            ],
            timestamp: hoursAgo(2),
            model: "claude-sonnet-4-6",
            tokenUsage: TokenUsage(input: 2800, output: 280)
        ),
    ]

    // MARK: - Thinking Session

    static let thinkingSession = Session(
        id: "think-001",
        projectPath: "/Users/leo/Dev/poirot",
        messages: thinkingMessages,
        startedAt: hoursAgo(5),
        model: "claude-opus-4-6",
        totalTokens: 38600
    )

    static let thinkingMessages: [Message] = [
        Message(
            id: "th1",
            role: .user,
            content: [.text("Session loading is slow when there are 100+ sessions per project. Can we optimize it?")],
            timestamp: hoursAgo(5),
            model: nil,
            tokenUsage: nil
        ),
        Message(
            id: "th2",
            role: .assistant,
            content: [
                .thinking("""
                The user is reporting performance issues with session loading. Let me trace through the current implementation:

                Current flow in SessionLoader:
                1. `projectDirectoryURLs()` scans ~/.claude/projects/ for subdirectories
                2. For each directory, `loadProject()` calls `sessionsForProject()`
                3. `sessionsForProject()` iterates every .jsonl file and calls `TranscriptParser.parse()`
                4. `TranscriptParser.parse()` reads the ENTIRE file line-by-line, deserializes every JSON object
                5. Each line becomes a Message with content blocks, token usage, etc.

                The problem: For a project with 100 sessions averaging 2MB each, we're reading ~200MB of JSON and constructing thousands of Message objects — all before the user sees anything.

                Bottleneck analysis:
                - **File I/O**: ~40% — sequential reads of large .jsonl files
                - **JSON decoding**: ~35% — JSONDecoder for each line
                - **Object allocation**: ~25% — Message, ToolUse, ToolResult instances

                Best approach: Two-phase loading
                Phase 1 (fast): Read only the first 5 lines of each .jsonl for metadata (session ID, timestamp, model, first user message for title). This is what the sidebar needs.
                Phase 2 (lazy): Full parse only when the user actually opens a session.

                This means I need to split `TranscriptParser` into:
                - `parseSummary(fileURL:) -> SessionSummary` — reads first few lines
                - `parseFull(fileURL:) -> Session` — existing full parse

                Combined with batch loading (groups of 5 projects at a time), this should make the sidebar appear near-instantly.
                """),
                .text("""
                Looking at the current `SessionLoader` and `TranscriptParser`, I can see the bottleneck clearly:

                ## Performance Analysis

                Every session file (~2MB average) is fully parsed on launch. For 100+ sessions, that's **200+ MB of JSON** decoded before anything renders.

                ## Recommended Approach: Two-Phase Loading

                ### Phase 1 — Fast Metadata Scan
                Read only the first 5 lines of each `.jsonl` for the sidebar summary (title, timestamp, model, turn count). This gives us **~50x speedup** for initial load.

                ```swift
                func parseSummary(fileURL: URL) -> SessionSummary {
                    // Read first 5 lines only — enough for metadata
                    let head = readLines(fileURL, count: 5)
                    return SessionSummary(
                        id: extractSessionId(head),
                        title: extractFirstUserMessage(head),
                        startedAt: extractTimestamp(head),
                        model: extractModel(head)
                    )
                }
                ```

                ### Phase 2 — Lazy Full Parse
                Only parse the complete transcript when the user selects a session. Cache the 50 most recent.

                ### Phase 3 — Batch Loading
                Load projects in groups of 5, updating the UI between batches for progressive rendering.

                Shall I implement this?
                """),
            ],
            timestamp: hoursAgo(5),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 4800, output: 4200)
        ),
    ]

    // MARK: - Server Session

    static let serverSession = Session(
        id: "server-001",
        projectPath: "/Users/leo/Dev/reellette-ios",
        messages: [
            Message(
                id: "s1",
                role: .user,
                content: [
                    .text(
                        "Add pull-to-refresh on the Discover feed using async/await and the new SwiftUI refreshable modifier"
                    ),
                ],
                timestamp: hoursAgo(8),
                model: nil,
                tokenUsage: nil
            ),
            Message(
                id: "s2",
                role: .assistant,
                content: [
                    .text(
                        "I'll add pull-to-refresh to the Discover feed using `.refreshable`. Let me read the current view first."
                    ),
                ],
                timestamp: hoursAgo(8),
                model: "claude-opus-4-6",
                tokenUsage: TokenUsage(input: 720, output: 380)
            ),
        ],
        startedAt: hoursAgo(8),
        model: "claude-opus-4-6",
        totalTokens: 9200
    )

    // MARK: - Migration Session

    static let migrationSession = Session(
        id: "migration-001",
        projectPath: "/Users/leo/Dev/reellette-ios",
        messages: [
            Message(
                id: "mg1",
                role: .user,
                content: [.text("Migrate the Catalog module from RxSwift to Combine + async/await")],
                timestamp: hoursAgo(12),
                model: nil,
                tokenUsage: nil
            ),
        ],
        startedAt: hoursAgo(12),
        model: "claude-sonnet-4-6",
        totalTokens: 6100
    )

    // MARK: - Pipeline Session

    static let pipelineSession = Session(
        id: "pipeline-001",
        projectPath: "/Users/leo/Dev/swift-openapi",
        messages: [
            Message(
                id: "p1",
                role: .user,
                content: [.text("Generate OpenAPI spec from the Vapor routes and add Swagger UI middleware")],
                timestamp: hoursAgo(24),
                model: nil,
                tokenUsage: nil
            ),
        ],
        startedAt: hoursAgo(24),
        model: "claude-opus-4-6",
        totalTokens: 17800
    )

    // MARK: - Write Tool Session

    static let writeToolSession = Session(
        id: "write-001",
        projectPath: "/Users/leo/Dev/poirot",
        messages: [
            Message(
                id: "w1",
                role: .user,
                content: [
                    .text(
                        "Create a FileWatcher service that monitors ~/.claude/projects/ for new session files and triggers a refresh"
                    ),
                ],
                timestamp: minutesAgo(30),
                model: nil,
                tokenUsage: nil
            ),
            Message(
                id: "w2",
                role: .assistant,
                content: [
                    .text(
                        "I'll create a `FileWatcher` using `DispatchSource.makeFileSystemObjectSource` to monitor the projects directory."
                    ),
                    .toolUse(ToolUse(
                        id: "tu-write",
                        name: "Write",
                        input: [
                            "file_path": "Poirot/Sources/Services/FileWatcher.swift",
                            "content": "import Foundation\n\nfinal class FileWatcher: @unchecked Sendable {\n    private var source: DispatchSourceFileSystemObject?\n    private let callback: () -> Void\n\n    init(onChange callback: @escaping () -> Void) {\n        self.callback = callback\n    }\n\n    func start(path: String) {\n        let fd = open(path, O_EVTONLY)\n        guard fd >= 0 else { return }\n\n        let source = DispatchSource.makeFileSystemObjectSource(\n            fileDescriptor: fd,\n            eventMask: [.write, .rename],\n            queue: .global(qos: .utility)\n        )\n        source.setEventHandler { [weak self] in\n            DispatchQueue.main.async {\n                self?.callback()\n            }\n        }\n        source.setCancelHandler { close(fd) }\n        source.resume()\n        self.source = source\n    }\n\n    func stop() {\n        source?.cancel()\n        source = nil\n    }\n}",
                        ]
                    )),
                ],
                timestamp: minutesAgo(29),
                model: "claude-opus-4-6",
                tokenUsage: TokenUsage(input: 920, output: 640)
            ),
            Message(
                id: "w2-result",
                role: .user,
                content: [
                    .toolResult(ToolResult(
                        id: "tr-write",
                        toolUseId: "tu-write",
                        content: "Successfully wrote to Poirot/Sources/Services/FileWatcher.swift",
                        isError: false
                    )),
                ],
                timestamp: minutesAgo(29),
                model: nil,
                tokenUsage: nil
            ),
        ],
        startedAt: minutesAgo(30),
        model: "claude-opus-4-6",
        totalTokens: 5600
    )

    // MARK: - Task Tool Session

    static let taskToolSession = Session(
        id: "task-001",
        projectPath: "/Users/leo/Dev/reellette-ios",
        messages: [
            Message(
                id: "tk1",
                role: .user,
                content: [
                    .text(
                        "Audit the codebase for any accessibility issues — missing labels, small tap targets, missing VoiceOver hints"
                    ),
                ],
                timestamp: minutesAgo(60),
                model: nil,
                tokenUsage: nil
            ),
            Message(
                id: "tk2",
                role: .assistant,
                content: [
                    .text("I'll launch a sub-agent to do a thorough accessibility audit across the codebase."),
                    .toolUse(ToolUse(
                        id: "tu-task",
                        name: "Task",
                        input: [
                            "description": "Accessibility audit",
                            "prompt": "Scan all SwiftUI views for missing accessibilityLabel, accessibilityHint, small tap targets (< 44pt), and missing VoiceOver support. Report findings grouped by severity.",
                        ]
                    )),
                ],
                timestamp: minutesAgo(59),
                model: "claude-opus-4-6",
                tokenUsage: TokenUsage(input: 680, output: 420)
            ),
            Message(
                id: "tk2-result",
                role: .user,
                content: [
                    .toolResult(ToolResult(
                        id: "tr-task",
                        toolUseId: "tu-task",
                        content: """
                        Accessibility Audit Complete — 14 issues found

                        Critical (3):
                        - DiscoverCard.swift:42 — Image-only button missing accessibilityLabel
                        - ProfileView.swift:118 — Custom gesture has no accessibility alternative
                        - SearchBar.swift:28 — Clear button tap target is 32x32 (< 44pt minimum)

                        Warning (6):
                        - CatalogRow.swift:55 — Missing accessibilityHint for swipe actions
                        - SettingsToggle.swift:23 — Toggle missing accessibilityValue
                        - NavigationBar.swift:67 — Back button uses icon without label
                        - FeedCell.swift:89 — Dynamic type not respected (fixed font size)
                        - OnboardingStep.swift:34 — Animation not gated by reduceMotion
                        - PlayerControls.swift:71 — Slider missing accessibilityAdjustableAction

                        Info (5):
                        - Decorative images missing .accessibilityHidden(true)
                        """,
                        isError: false
                    )),
                ],
                timestamp: minutesAgo(55),
                model: nil,
                tokenUsage: nil
            ),
        ],
        startedAt: minutesAgo(60),
        model: "claude-opus-4-6",
        totalTokens: 14200
    )

    // MARK: - Error Tool Session

    static let errorToolSession = Session(
        id: "error-001",
        projectPath: "/Users/leo/Dev/swift-openapi",
        messages: [
            Message(
                id: "e1",
                role: .user,
                content: [.text("Run the test suite and fix any failures")],
                timestamp: minutesAgo(20),
                model: nil,
                tokenUsage: nil
            ),
            Message(
                id: "e2",
                role: .assistant,
                content: [
                    .text("I'll run the tests first to see what's failing."),
                    .toolUse(ToolUse(
                        id: "tu-bash-err",
                        name: "Bash",
                        input: ["command": "swift test 2>&1 | tail -12"]
                    )),
                ],
                timestamp: minutesAgo(19),
                model: "claude-sonnet-4-6",
                tokenUsage: TokenUsage(input: 520, output: 280)
            ),
            Message(
                id: "e2-result",
                role: .user,
                content: [
                    .toolResult(ToolResult(
                        id: "tr-bash-err",
                        toolUseId: "tu-bash-err",
                        content: """
                        Test Suite 'OpenAPIGeneratorTests' started at 2026-02-20 14:10:22
                        Test Case 'testGenerateRoutes' started
                        /Users/leo/Dev/swift-openapi/Tests/GeneratorTests.swift:42: error: testGenerateRoutes
                            #expect(routes.count == 8) failed: (routes.count → 6) == 8
                        Test Case 'testGenerateRoutes' failed (0.012 seconds)
                        Test Case 'testSchemaValidation' started
                        /Users/leo/Dev/swift-openapi/Tests/GeneratorTests.swift:67: error: testSchemaValidation
                            #expect(schema.properties["email"] != nil) failed
                        Test Case 'testSchemaValidation' failed (0.003 seconds)
                        Test Suite 'OpenAPIGeneratorTests' failed
                             Executed 5 tests, with 2 failures in 0.089 (0.091) seconds
                        """,
                        isError: true
                    )),
                ],
                timestamp: minutesAgo(19),
                model: nil,
                tokenUsage: nil
            ),
            Message(
                id: "e3",
                role: .assistant,
                content: [
                    .text(
                        "Two test failures. Let me read the test file and the route generator to understand what changed."
                    ),
                    .toolUse(ToolUse(
                        id: "tu-read-err",
                        name: "Read",
                        input: ["file_path": "/Users/leo/Dev/swift-openapi/Sources/RouteCollector.swift"]
                    )),
                ],
                timestamp: minutesAgo(18),
                model: "claude-sonnet-4-6",
                tokenUsage: TokenUsage(input: 920, output: 240)
            ),
            Message(
                id: "e3-result",
                role: .user,
                content: [
                    .toolResult(ToolResult(
                        id: "tr-read-err",
                        toolUseId: "tu-read-err",
                        content: "Error: File not found at path /Users/leo/Dev/swift-openapi/Sources/RouteCollector.swift",
                        isError: true
                    )),
                ],
                timestamp: minutesAgo(18),
                model: nil,
                tokenUsage: nil
            ),
        ],
        startedAt: minutesAgo(20),
        model: "claude-sonnet-4-6",
        totalTokens: 7200
    )

    // MARK: - Edit Diff Session

    static let editDiffSession = Session(
        id: "diff-001",
        projectPath: "/Users/leo/Dev/poirot",
        messages: [
            Message(
                id: "d1",
                role: .user,
                content: [.text("Refactor the TranscriptParser to use async/await instead of completion handlers")],
                timestamp: minutesAgo(35),
                model: nil,
                tokenUsage: nil
            ),
            Message(
                id: "d2",
                role: .assistant,
                content: [
                    .text("I'll convert the completion-based API to async/await for cleaner call sites."),
                    .toolUse(ToolUse(
                        id: "tu-edit-diff",
                        name: "Edit",
                        input: [
                            "file_path": "Poirot/Sources/Services/TranscriptParser.swift",
                            "old_string": "func parse(\n    fileURL: URL,\n    projectPath: String,\n    completion: @escaping (Session?) -> Void\n) {\n    DispatchQueue.global(qos: .userInitiated).async {\n        let session = self.parseSync(fileURL: fileURL, projectPath: projectPath)\n        DispatchQueue.main.async {\n            completion(session)\n        }\n    }\n}",
                            "new_string": "func parse(\n    fileURL: URL,\n    projectPath: String,\n    sessionId: String,\n    indexStartedAt: Date?\n) -> Session? {\n    parseSync(\n        fileURL: fileURL,\n        projectPath: projectPath,\n        sessionId: sessionId,\n        indexStartedAt: indexStartedAt\n    )\n}",
                        ]
                    )),
                ],
                timestamp: minutesAgo(34),
                model: "claude-opus-4-6",
                tokenUsage: TokenUsage(input: 1800, output: 1050)
            ),
            Message(
                id: "d2-result",
                role: .user,
                content: [
                    .toolResult(ToolResult(
                        id: "tr-edit-diff",
                        toolUseId: "tu-edit-diff",
                        content: "Successfully edited Poirot/Sources/Services/TranscriptParser.swift",
                        isError: false
                    )),
                ],
                timestamp: minutesAgo(34),
                model: nil,
                tokenUsage: nil
            ),
        ],
        startedAt: minutesAgo(35),
        model: "claude-opus-4-6",
        totalTokens: 9400
    )

    // MARK: - Long Content Session

    static let longContentSession: Session = {
        var lines = ["Running xcodebuild test -scheme Poirot -destination 'platform=macOS'...\n"]
        let testNames = [
            "testSessionParsing", "testMessageDecoding", "testToolUseParsing",
            "testThinkingBlockExtraction", "testTokenUsageAggregation", "testProjectDiscovery",
            "testBatchLoading", "testCacheEviction", "testSearchFiltering", "testFuzzyMatch",
            "testSidebarCounts", "testConfigParsing", "testMCPServerLoading", "testSkillsDiscovery",
            "testCommandsRendering", "testOutputStyleApplication", "testSubAgentDetection",
            "testPluginLoading", "testModelEnumeration", "testThemeColors",
        ]
        for (i, name) in testNames.enumerated() {
            let duration = 10 + (i * 7) % 200
            lines.append("  Test Case '\(name)' passed (\(Double(duration) / 1000.0) seconds)")
        }
        for i in 21 ... 68 {
            let name = "testSnapshot_\(String(format: "%03d", i))"
            let duration = 50 + (i * 13) % 400
            lines.append("  Test Case '\(name)' passed (\(Double(duration) / 1000.0) seconds)")
        }
        lines.append("\nTest Suite 'All tests' passed")
        lines.append("  Executed 68 tests, with 0 failures in 4.821 (5.003) seconds")
        let longOutput = lines.joined(separator: "\n")

        return Session(
            id: "long-001",
            projectPath: "/Users/leo/Dev/ignio-web",
            messages: [
                Message(
                    id: "l1",
                    role: .user,
                    content: [.text("Run the full test suite and show me the results")],
                    timestamp: minutesAgo(15),
                    model: nil,
                    tokenUsage: nil
                ),
                Message(
                    id: "l2",
                    role: .assistant,
                    content: [
                        .toolUse(ToolUse(
                            id: "tu-bash-long",
                            name: "Bash",
                            input: ["command": "xcodebuild test -scheme Poirot -destination 'platform=macOS' 2>&1"]
                        )),
                    ],
                    timestamp: minutesAgo(14),
                    model: "claude-sonnet-4-6",
                    tokenUsage: TokenUsage(input: 420, output: 180)
                ),
                Message(
                    id: "l2-result",
                    role: .user,
                    content: [
                        .toolResult(ToolResult(
                            id: "tr-bash-long",
                            toolUseId: "tu-bash-long",
                            content: longOutput,
                            isError: false
                        )),
                    ],
                    timestamp: minutesAgo(14),
                    model: nil,
                    tokenUsage: nil
                ),
            ],
            startedAt: minutesAgo(15),
            model: "claude-sonnet-4-6",
            totalTokens: 11200
        )
    }()

    // MARK: - All Tool Types Session

    static let allToolTypesSession = Session(
        id: "alltools-001",
        projectPath: "/Users/leo/Dev/poirot",
        messages: allToolTypesMessages,
        startedAt: minutesAgo(50),
        model: "claude-opus-4-6",
        totalTokens: 26400
    )

    static let allToolTypesMessages: [Message] = [
        Message(
            id: "at1",
            role: .user,
            content: [
                .text("Add a toast notification system that shows success/error/info messages with auto-dismiss"),
            ],
            timestamp: minutesAgo(50),
            model: nil,
            tokenUsage: nil
        ),
        // Read tool
        Message(
            id: "at2",
            role: .assistant,
            content: [
                .toolUse(ToolUse(
                    id: "tu-at-read",
                    name: "Read",
                    input: ["file_path": "Poirot/Sources/App/AppState.swift"]
                )),
            ],
            timestamp: minutesAgo(49),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 340, output: 140)
        ),
        Message(
            id: "at2-result",
            role: .user,
            content: [
                .toolResult(ToolResult(
                    id: "tr-at-read",
                    toolUseId: "tu-at-read",
                    content: "import SwiftUI\nimport Observation\n\n@Observable\nfinal class AppState {\n    var projects: [Project] = []\n    var selectedSession: Session?\n    var selectedNav: NavigationItem = .sessions\n    var isLoadingProjects = false\n    var isSearchPresented = false\n    var selectedProject: String?\n    // ...\n}",
                    isError: false
                )),
            ],
            timestamp: minutesAgo(49),
            model: nil,
            tokenUsage: nil
        ),
        // Write tool
        Message(
            id: "at3",
            role: .assistant,
            content: [
                .toolUse(ToolUse(
                    id: "tu-at-write",
                    name: "Write",
                    input: [
                        "file_path": "Poirot/Sources/Views/Components/ToastOverlay.swift",
                        "content": "import SwiftUI\n\nstruct ToastOverlay: View {\n    @Environment(AppState.self) private var appState\n\n    var body: some View {\n        if let toast = appState.toastQueue.first {\n            ToastView(toast: toast)\n                .transition(.move(edge: .top).combined(with: .opacity))\n                .onAppear {\n                    Task {\n                        try? await Task.sleep(for: .seconds(3))\n                        withAnimation { appState.dismissToast() }\n                    }\n                }\n        }\n    }\n}",
                    ]
                )),
            ],
            timestamp: minutesAgo(48),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 480, output: 320)
        ),
        Message(
            id: "at3-result",
            role: .user,
            content: [
                .toolResult(ToolResult(
                    id: "tr-at-write",
                    toolUseId: "tu-at-write",
                    content: "Successfully wrote to Poirot/Sources/Views/Components/ToastOverlay.swift",
                    isError: false
                )),
            ],
            timestamp: minutesAgo(48),
            model: nil,
            tokenUsage: nil
        ),
        // Edit tool
        Message(
            id: "at4",
            role: .assistant,
            content: [
                .toolUse(ToolUse(
                    id: "tu-at-edit",
                    name: "Edit",
                    input: [
                        "file_path": "Poirot/Sources/App/AppState.swift",
                        "old_string": "var isSearchPresented = false",
                        "new_string": "var isSearchPresented = false\n    var toastQueue: [Toast] = []\n\n    func showToast(_ message: String, icon: String, style: Toast.Style) {\n        let toast = Toast(message: message, icon: icon, style: style)\n        toastQueue.append(toast)\n    }",
                    ]
                )),
            ],
            timestamp: minutesAgo(47),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 560, output: 340)
        ),
        Message(
            id: "at4-result",
            role: .user,
            content: [
                .toolResult(ToolResult(
                    id: "tr-at-edit",
                    toolUseId: "tu-at-edit",
                    content: "Successfully edited Poirot/Sources/App/AppState.swift",
                    isError: false
                )),
            ],
            timestamp: minutesAgo(47),
            model: nil,
            tokenUsage: nil
        ),
        // Bash tool
        Message(
            id: "at5",
            role: .assistant,
            content: [
                .toolUse(ToolUse(
                    id: "tu-at-bash",
                    name: "Bash",
                    input: [
                        "command": "cd /Users/leo/Dev/poirot && xcodebuild build -scheme Poirot -destination 'platform=macOS' 2>&1 | tail -3",
                    ]
                )),
            ],
            timestamp: minutesAgo(46),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 320, output: 160)
        ),
        Message(
            id: "at5-result",
            role: .user,
            content: [
                .toolResult(ToolResult(
                    id: "tr-at-bash",
                    toolUseId: "tu-at-bash",
                    content: "Ld /Users/leo/Library/Developer/Xcode/DerivedData/Poirot-abc123/Build/Products/Debug/Poirot.app\nGenerateDSYMFile Poirot.app.dSYM\n** BUILD SUCCEEDED **",
                    isError: false
                )),
            ],
            timestamp: minutesAgo(46),
            model: nil,
            tokenUsage: nil
        ),
        // Glob tool
        Message(
            id: "at6",
            role: .assistant,
            content: [
                .toolUse(ToolUse(
                    id: "tu-at-glob",
                    name: "Glob",
                    input: ["pattern": "Poirot/Sources/Views/**/*.swift"]
                )),
            ],
            timestamp: minutesAgo(45),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 300, output: 140)
        ),
        Message(
            id: "at6-result",
            role: .user,
            content: [
                .toolResult(ToolResult(
                    id: "tr-at-glob",
                    toolUseId: "tu-at-glob",
                    content: "Poirot/Sources/Views/Components/SidebarView.swift\nPoirot/Sources/Views/Components/ToastOverlay.swift\nPoirot/Sources/Views/Home/HomeView.swift\nPoirot/Sources/Views/Session/SessionDetailView.swift\nPoirot/Sources/Views/Session/ToolBlockView.swift\nPoirot/Sources/Views/Session/ThinkingBlockView.swift\nPoirot/Sources/Views/Config/CommandsListView.swift\nPoirot/Sources/Views/Config/SkillsListView.swift",
                    isError: false
                )),
            ],
            timestamp: minutesAgo(45),
            model: nil,
            tokenUsage: nil
        ),
        // Grep tool
        Message(
            id: "at7",
            role: .assistant,
            content: [
                .toolUse(ToolUse(
                    id: "tu-at-grep",
                    name: "Grep",
                    input: ["pattern": "showToast\\(", "path": "Poirot/Sources"]
                )),
            ],
            timestamp: minutesAgo(44),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 300, output: 140)
        ),
        Message(
            id: "at7-result",
            role: .user,
            content: [
                .toolResult(ToolResult(
                    id: "tr-at-grep",
                    toolUseId: "tu-at-grep",
                    content: "Poirot/Sources/App/AppState.swift:42:    func showToast(_ message: String, icon: String, style: Toast.Style) {\nPoirot/Sources/App/ContentView.swift:98:                appState.showToast(",
                    isError: false
                )),
            ],
            timestamp: minutesAgo(44),
            model: nil,
            tokenUsage: nil
        ),
        // Task tool
        Message(
            id: "at8",
            role: .assistant,
            content: [
                .toolUse(ToolUse(
                    id: "tu-at-task",
                    name: "Task",
                    input: [
                        "description": "Verify toast UI",
                        "prompt": "Check that ToastOverlay renders correctly for success, error, and info styles. Verify auto-dismiss after 3 seconds and animation transitions.",
                    ]
                )),
            ],
            timestamp: minutesAgo(43),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 320, output: 180)
        ),
        Message(
            id: "at8-result",
            role: .user,
            content: [
                .toolResult(ToolResult(
                    id: "tr-at-task",
                    toolUseId: "tu-at-task",
                    content: "Toast UI verification complete:\n- Success style: green tint, checkmark icon, renders correctly\n- Error style: red tint, xmark icon, renders correctly\n- Info style: blue tint, info icon, renders correctly\n- Auto-dismiss: works after 3s delay\n- Transition: slide + opacity combination is smooth",
                    isError: false
                )),
            ],
            timestamp: minutesAgo(43),
            model: nil,
            tokenUsage: nil
        ),
        Message(
            id: "at9",
            role: .assistant,
            content: [
                .text(
                    "The toast notification system is fully implemented and verified. All three styles (success, error, info) render correctly with smooth animations and auto-dismiss."
                ),
            ],
            timestamp: minutesAgo(42),
            model: "claude-opus-4-6",
            tokenUsage: TokenUsage(input: 1400, output: 280)
        ),
    ]

    // MARK: - System Context Session

    static let systemContextSession = Session(
        id: "sysctx-001",
        projectPath: "/Users/leo/Dev/poirot",
        messages: [
            Message(
                id: "sc1",
                role: .user,
                content: [.text("""
                Fix the build error in TranscriptParser.swift.

                <system-reminder>
                The user is working on branch feature/lazy-loading.
                Last build failed with 2 errors in TranscriptParser.swift.
                </system-reminder>
                """)],
                timestamp: minutesAgo(10),
                model: nil,
                tokenUsage: nil
            ),
            Message(
                id: "sc2",
                role: .assistant,
                content: [
                    .text(
                        "I see the build errors on `feature/lazy-loading`. Let me read the parser to find the type mismatches."
                    ),
                    .toolUse(ToolUse(
                        id: "tu-sc-read",
                        name: "Read",
                        input: ["file_path": "Poirot/Sources/Services/TranscriptParser.swift"]
                    )),
                ],
                timestamp: minutesAgo(9),
                model: "claude-opus-4-6",
                tokenUsage: TokenUsage(input: 880, output: 380)
            ),
            Message(
                id: "sc2-result",
                role: .user,
                content: [
                    .toolResult(ToolResult(
                        id: "tr-sc-read",
                        toolUseId: "tu-sc-read",
                        content: "import Foundation\n\nnonisolated struct TranscriptParser {\n    func parse(\n        fileURL: URL,\n        projectPath: String,\n        sessionId: String,\n        indexStartedAt: Date?\n    ) -> Session? {\n        guard let data = try? Data(contentsOf: fileURL) else { return nil }\n        let lines = String(data: data, encoding: .utf8)?.split(separator: \"\\n\") ?? []\n        // ... parse each line as JSON\n        return Session(id: sessionId, projectPath: projectPath, messages: messages)\n    }\n}",
                        isError: false
                    )),
                ],
                timestamp: minutesAgo(9),
                model: nil,
                tokenUsage: nil
            ),
        ],
        startedAt: minutesAgo(10),
        model: "claude-opus-4-6",
        totalTokens: 6800
    )

    // MARK: - Empty Session

    static let emptySession = Session(
        id: "empty-001",
        projectPath: "/Users/leo/Dev/poirot",
        messages: [],
        startedAt: minutesAgo(5),
        model: nil,
        totalTokens: 0
    )

    // MARK: - Static Toast Instances

    // swiftlint:disable force_try
    static let successToast = Toast(
        message: try! AttributedString(markdown: "Session exported to **~/Desktop/session.md**"),
        icon: "checkmark.circle.fill",
        style: .success,
        url: nil
    )

    static let errorToast = Toast(
        message: try! AttributedString(markdown: "Failed to parse session transcript"),
        icon: "xmark.circle.fill",
        style: .error,
        url: nil
    )

    static let infoToast = Toast(
        message: try! AttributedString(markdown: "New version **1.2.0** available\nTap to download from GitHub"),
        icon: "arrow.down.circle.fill",
        style: .info,
        url: URL(string: "https://github.com/LeonardoCardoso/poirot/releases")
    )
    // swiftlint:enable force_try

    // MARK: - Standalone Tool/Result Pairs

    static let readTool = ToolUse(
        id: "standalone-read",
        name: "Read",
        input: ["file_path": "Poirot/Sources/App/ContentView.swift"]
    )

    static let readResult = ToolResult(
        id: "standalone-read-result",
        toolUseId: "standalone-read",
        content: """
        import SwiftUI

        struct ContentView: View {
            @Environment(AppState.self) private var appState
            @Environment(\\.provider) private var provider
            @State private var sidebarVisibility: NavigationSplitViewVisibility = .automatic

            var body: some View {
                NavigationSplitView(columnVisibility: $sidebarVisibility) {
                    SidebarView()
                        .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 300)
                } detail: {
                    detailView
                }
                .navigationSplitViewStyle(.prominentDetail)
            }
        }
        """,
        isError: false
    )

    static let writeTool = ToolUse(
        id: "standalone-write",
        name: "Write",
        input: [
            "file_path": "Poirot/Sources/Services/FileWatcher.swift",
            "content": "import Foundation\n\nfinal class FileWatcher: @unchecked Sendable {\n    private var source: DispatchSourceFileSystemObject?\n    // ...\n}",
        ]
    )

    static let writeResult = ToolResult(
        id: "standalone-write-result",
        toolUseId: "standalone-write",
        content: "Successfully wrote to Poirot/Sources/Services/FileWatcher.swift",
        isError: false
    )

    static let editTool = ToolUse(
        id: "standalone-edit",
        name: "Edit",
        input: [
            "file_path": "Poirot/Sources/Theme/PoirotTheme.swift",
            "old_string": "static let accent = Color.orange",
            "new_string": "static let accent = Color(hex: \"#E8A642\")",
        ]
    )

    static let editResult = ToolResult(
        id: "standalone-edit-result",
        toolUseId: "standalone-edit",
        content: "Successfully edited Poirot/Sources/Theme/PoirotTheme.swift",
        isError: false
    )

    static let bashTool = ToolUse(
        id: "standalone-bash",
        name: "Bash",
        input: ["command": "xcodebuild build -scheme Poirot -destination 'platform=macOS' 2>&1 | tail -3"]
    )

    static let bashResult = ToolResult(
        id: "standalone-bash-result",
        toolUseId: "standalone-bash",
        content: "Ld /Users/leo/Library/Developer/Xcode/DerivedData/Poirot-abc123/Build/Products/Debug/Poirot.app\nGenerateDSYMFile Poirot.app.dSYM\n** BUILD SUCCEEDED **",
        isError: false
    )

    static let bashErrorTool = ToolUse(
        id: "standalone-bash-error",
        name: "Bash",
        input: ["command": "swift test --filter TranscriptParserTests"]
    )

    static let bashErrorResult = ToolResult(
        id: "standalone-bash-error-result",
        toolUseId: "standalone-bash-error",
        content: """
        Test Suite 'TranscriptParserTests' started
        Test Case 'testParseMalformedJSON' started
        /Tests/TranscriptParserTests.swift:42: error: testParseMalformedJSON
            #expect(session != nil) failed: session is nil
        Test Case 'testParseMalformedJSON' failed (0.003 seconds)
        Test Suite 'TranscriptParserTests' failed
             Executed 3 tests, with 1 failure in 0.018 (0.020) seconds
        """,
        isError: true
    )

    static let globTool = ToolUse(
        id: "standalone-glob",
        name: "Glob",
        input: ["pattern": "**/*.swift", "path": "Poirot/Sources"]
    )

    static let globResult = ToolResult(
        id: "standalone-glob-result",
        toolUseId: "standalone-glob",
        content: """
        Poirot/Sources/App/AppState.swift
        Poirot/Sources/App/ContentView.swift
        Poirot/Sources/App/PoirotApp.swift
        Poirot/Sources/Models/Session.swift
        Poirot/Sources/Models/Message.swift
        Poirot/Sources/Models/ToolUse.swift
        Poirot/Sources/Services/TranscriptParser.swift
        Poirot/Sources/Services/SessionLoader.swift
        Poirot/Sources/Services/FileWatcher.swift
        Poirot/Sources/Theme/PoirotTheme.swift
        Poirot/Sources/Views/Components/SidebarView.swift
        Poirot/Sources/Views/Components/ToastOverlay.swift
        Poirot/Sources/Views/Session/SessionDetailView.swift
        Poirot/Sources/Views/Session/ToolBlockView.swift
        """,
        isError: false
    )

    static let grepTool = ToolUse(
        id: "standalone-grep",
        name: "Grep",
        input: ["pattern": "@Observable", "path": "Poirot/Sources"]
    )

    static let grepResult = ToolResult(
        id: "standalone-grep-result",
        toolUseId: "standalone-grep",
        content: """
        Poirot/Sources/App/AppState.swift:4:@Observable
        Poirot/Sources/App/AppState.swift:5:final class AppState {
        """,
        isError: false
    )

    static let taskTool = ToolUse(
        id: "standalone-task",
        name: "Task",
        input: [
            "description": "Run snapshot tests",
            "prompt": "Execute all snapshot tests and report any failures or new baselines needed",
        ]
    )

    static let taskResult = ToolResult(
        id: "standalone-task-result",
        toolUseId: "standalone-task",
        content: "Snapshot test results:\n- 68 tests executed, 68 passed\n- 0 failures, 0 new baselines\n- Total duration: 4.82s\n\nAll snapshots match their reference images.",
        isError: false
    )

    static let unknownTool = ToolUse(
        id: "standalone-unknown",
        name: "mcp__sentry__search_issues",
        input: ["query": "TranscriptParser crash", "project": "poirot"]
    )

    static let unknownResult = ToolResult(
        id: "standalone-unknown-result",
        toolUseId: "standalone-unknown",
        content: "Found 2 issues matching 'TranscriptParser crash':\n1. POIROT-42: Crash on malformed JSONL (resolved)\n2. POIROT-58: OOM on large session files (open)",
        isError: false
    )

    static let noOutputTool = ToolUse(
        id: "standalone-no-output",
        name: "Bash",
        input: ["command": "mkdir -p Poirot/Sources/Services"]
    )

    static let noOutputResult = ToolResult(
        id: "standalone-no-output-result",
        toolUseId: "standalone-no-output",
        content: "",
        isError: false
    )

    // Long content tool for truncation testing
    static let longContentTool = ToolUse(
        id: "standalone-long",
        name: "Bash",
        input: ["command": "xcodebuild test -scheme Poirot -destination 'platform=macOS' 2>&1"]
    )

    static let longContentResult: ToolResult = {
        var lines = ["Test Suite 'All tests' started at 2026-02-20 14:25:00\n"]
        for i in 1 ... 68 {
            let name = "testSnapshot_\(String(format: "%03d", i))"
            let dur = Double(10 + (i * 13) % 400) / 1000.0
            lines.append("  Test Case '\(name)' passed (\(String(format: "%.3f", dur)) seconds)")
        }
        lines.append("\nTest Suite 'All tests' passed")
        lines.append("  Executed 68 tests, with 0 failures in 4.821 (5.003) seconds")
        return ToolResult(
            id: "standalone-long-result",
            toolUseId: "standalone-long",
            content: lines.joined(separator: "\n"),
            isError: false
        )
    }()

    // MARK: - Edit Diff Pairs

    static let simpleDiffOld = "static let accent = Color.orange"
    static let simpleDiffNew = "static let accent = Color(hex: \"#E8A642\")"

    static let multiLineDiffOld = """
    func parse(
        fileURL: URL,
        projectPath: String,
        completion: @escaping (Session?) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let session = self.parseSync(fileURL: fileURL, projectPath: projectPath)
            DispatchQueue.main.async {
                completion(session)
            }
        }
    }
    """

    static let multiLineDiffNew = """
    func parse(
        fileURL: URL,
        projectPath: String,
        sessionId: String,
        indexStartedAt: Date?
    ) -> Session? {
        parseSync(
            fileURL: fileURL,
            projectPath: projectPath,
            sessionId: sessionId,
            indexStartedAt: indexStartedAt
        )
    }
    """

    static let addOnlyDiffOld = """
    struct Toast {
        let message: AttributedString
        let icon: String
    }
    """

    static let addOnlyDiffNew = """
    struct Toast {
        let message: AttributedString
        let icon: String
        let style: Style
        let url: URL?

        enum Style { case success, error, info }
    }
    """

    static let removeOnlyDiffOld = """
    struct SessionLoader {
        let cache: NSCache<NSString, NSData>
        let queue: DispatchQueue
        let semaphore: DispatchSemaphore

        func loadAll() {
            semaphore.wait()
            defer { semaphore.signal() }
            // synchronous full parse
        }
    }
    """

    static let removeOnlyDiffNew = """
    struct SessionLoader {
        func loadAll() async {
            // async batch loading
        }
    }
    """

    // MARK: - Plans Mock Data

    static let plans: [Plan] = [
        Plan(
            id: "plans-browser-enhancement",
            name: "Plans Browser Enhancement",
            content: """
            # Plans Browser Enhancement

            ## Context
            Enhance Plans to be a first-class feature with delete, markdown/raw toggle, per-card actions, \
            universal search integration, and local filter bars.

            ## Steps
            1. Enhance PlanDetailView with markdown/raw toggle
            2. Add delete button on PlanCard
            3. Add copy button on PlanCard
            4. Add Plans to Universal Search
            """,
            fileURL: URL(fileURLWithPath: "/Users/leo/.claude/plans/plans-browser-enhancement.md")
        ),
        Plan(
            id: "authentication-redesign",
            name: "Authentication Redesign",
            content: """
            # Authentication Redesign

            ## Overview
            Migrate from session-based auth to JWT tokens with refresh token rotation.

            ## Architecture
            - Access tokens: 15min TTL
            - Refresh tokens: 7 day TTL with rotation
            - Token storage: Keychain on iOS, HttpOnly cookies on web
            """,
            fileURL: URL(fileURLWithPath: "/Users/leo/.claude/plans/authentication-redesign.md")
        ),
        Plan(
            id: "performance-optimization",
            name: "Performance Optimization",
            content: """
            # Performance Optimization Plan

            ## Targets
            - Reduce cold start time by 40%
            - Improve scroll performance in session list
            - Lazy load transcript blocks
            """,
            fileURL: URL(fileURLWithPath: "/Users/leo/.claude/plans/performance-optimization.md")
        ),
    ]
}
