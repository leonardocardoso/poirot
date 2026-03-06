@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("Config Screen Screenshots")
struct ScreenshotTests_ConfigScreens {
    private let isRecording = false

    private var provider: ClaudeCodeProvider { ClaudeCodeProvider() }

    private func configItem(id: String) -> ConfigurationItem {
        provider.configurationItems.first { $0.id == id }!
    }

    // MARK: - Config List Views

    @Test
    func testCommandsList() async throws {
        try await snapshotView(
            withEnvironment(
                CommandsListView(item: configItem(id: "commands")),
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testCommandsList",
            record: isRecording,
            delay: 2,
            colorScheme: .light
        )
    }

    @Test
    func testSkillsList() async throws {
        try await snapshotView(
            withEnvironment(
                SkillsListView(item: configItem(id: "skills")),
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testSkillsList",
            record: isRecording,
            delay: 2
        )
    }

    @Test
    func testMCPServersList() async throws {
        try await snapshotView(
            withEnvironment(
                MCPServersListView(item: configItem(id: "mcpServers")),
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testMCPServersList",
            record: isRecording,
            delay: 2,
            colorScheme: .light
        )
    }

    @Test
    func testModelsList() async throws {
        try await snapshotView(
            withEnvironment(
                ModelsListView(item: configItem(id: "models")),
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testModelsList",
            record: isRecording,
            delay: 2
        )
    }

    @Test
    func testSubAgentsList() async throws {
        try await snapshotView(
            withEnvironment(
                SubAgentsListView(item: configItem(id: "subAgents")),
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testSubAgentsList",
            record: isRecording,
            delay: 2,
            colorScheme: .light
        )
    }

    @Test
    func testPluginsList() async throws {
        try await snapshotView(
            withEnvironment(
                PluginsListView(item: configItem(id: "plugins")),
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testPluginsList",
            record: isRecording,
            delay: 2
        )
    }

    @Test
    func testHooksList() async throws {
        let state = makeAppState(configProjectPath: "/Users/leonardocardoso/Dev/git/business/lumno")
        try await snapshotView(
            withEnvironment(
                HooksListView(item: configItem(id: "hooks")),
                state: state,
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testHooksList",
            record: isRecording,
            delay: 2
        )
    }

    @Test
    func testOutputStylesList() async throws {
        try await snapshotView(
            withEnvironment(
                OutputStylesListView(item: configItem(id: "outputStyles")),
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testOutputStylesList",
            record: isRecording,
            delay: 2,
            colorScheme: .light
        )
    }

    // MARK: - Config List Views (with project selected)

    @Test
    func testCommandsListWithProject() async throws {
        let state = makeAppState(configProjectPath: "/Users/leonardocardoso/Dev/git/business/lumno")
        try await snapshotView(
            withEnvironment(
                CommandsListView(item: configItem(id: "commands")),
                state: state,
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testCommandsListWithProject",
            record: isRecording,
            delay: 2
        )
    }

    @Test
    func testSkillsListWithProject() async throws {
        let state = makeAppState(configProjectPath: "/Users/leonardocardoso/Dev/git/business/lumno")
        try await snapshotView(
            withEnvironment(
                SkillsListView(item: configItem(id: "skills")),
                state: state,
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testSkillsListWithProject",
            record: isRecording,
            delay: 2
        )
    }

    @Test
    func testMCPServersListWithProject() async throws {
        let state = makeAppState(configProjectPath: "/Users/leonardocardoso/Dev/git/business/lumno")
        try await snapshotView(
            withEnvironment(
                MCPServersListView(item: configItem(id: "mcpServers")),
                state: state,
                provider: provider
            ),
            size: ScreenshotSize.mainContent,
            named: "testMCPServersListWithProject",
            record: isRecording,
            delay: 2
        )
    }

    // MARK: - Config Screen Header

    @Test
    func testConfigScreenHeader() {
        snapshotView(
            withEnvironment(
                ConfigScreenHeader(
                    item: configItem(id: "commands"),
                    dynamicCount: "12"
                ),
                provider: provider
            ),
            size: ScreenshotSize.componentHeader,
            named: "testConfigScreenHeader",
            record: isRecording
        )
    }

    // MARK: - Config Empty State

    @Test
    func testConfigEmptyState() {
        snapshotView(
            ConfigEmptyState(
                icon: "apple.terminal",
                message: "No commands found",
                hint: "Add commands to ~/.claude/commands/"
            ),
            size: ScreenshotSize.emptyState,
            named: "testConfigEmptyState",
            record: isRecording
        )
    }

    // MARK: - Config Empty State (MCP Servers)

    @Test
    func testConfigEmptyStateMCP() {
        snapshotView(
            ConfigEmptyState(
                icon: "powerplug",
                message: "No MCP servers configured",
                hint: "Add servers to ~/.claude/settings.json"
            ),
            size: ScreenshotSize.emptyState,
            named: "testConfigEmptyStateMCP",
            record: isRecording
        )
    }
}
