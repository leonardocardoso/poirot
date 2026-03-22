@testable import Poirot
import SnapshotTesting
import SwiftUI
import Testing

@Suite("File History Screenshots")
struct ScreenshotTests_FileHistory {
    private let isRecording = false

    private static let baseDate = Date(timeIntervalSince1970: 1_771_598_200)

    private static let session = Session(
        id: "file-history-001",
        projectPath: "/Users/leo/Dev/closedclaw",
        messages: ScreenshotData.conversationMessages,
        startedAt: baseDate,
        model: "claude-opus-4-6",
        totalTokens: 11700
    )

    private static let entries: [FileHistoryEntry] = [
        FileHistoryEntry(fileName: "extensions/alert-triage/src/index.ts", versions: [
            FileVersion(
                fileName: "extensions/alert-triage/src/index.ts",
                sessionId: "file-history-001",
                version: 1,
                backupTime: baseDate.addingTimeInterval(60),
                contentHash: "a1b2c3",
                backupFileName: "a1b2c3@v1"
            ),
            FileVersion(
                fileName: "extensions/alert-triage/src/index.ts",
                sessionId: "file-history-001",
                version: 2,
                backupTime: baseDate.addingTimeInterval(300),
                contentHash: "d4e5f6",
                backupFileName: "d4e5f6@v2"
            ),
        ]),
        FileHistoryEntry(fileName: "extensions/alert-triage/src/read-slack-tool.ts", versions: [
            FileVersion(
                fileName: "extensions/alert-triage/src/read-slack-tool.ts",
                sessionId: "file-history-001",
                version: 1,
                backupTime: baseDate.addingTimeInterval(120),
                contentHash: "g7h8i9",
                backupFileName: "g7h8i9@v1"
            ),
            FileVersion(
                fileName: "extensions/alert-triage/src/read-slack-tool.ts",
                sessionId: "file-history-001",
                version: 2,
                backupTime: baseDate.addingTimeInterval(240),
                contentHash: "j1k2l3",
                backupFileName: "j1k2l3@v2"
            ),
            FileVersion(
                fileName: "extensions/alert-triage/src/read-slack-tool.ts",
                sessionId: "file-history-001",
                version: 3,
                backupTime: baseDate.addingTimeInterval(480),
                contentHash: "m4n5o6",
                backupFileName: "m4n5o6@v3"
            ),
        ]),
        FileHistoryEntry(fileName: "extensions/alert-triage/src/setup-cron-tool.ts", versions: [
            FileVersion(
                fileName: "extensions/alert-triage/src/setup-cron-tool.ts",
                sessionId: "file-history-001",
                version: 1,
                backupTime: baseDate.addingTimeInterval(180),
                contentHash: "p7q8r9",
                backupFileName: "p7q8r9@v1"
            ),
            FileVersion(
                fileName: "extensions/alert-triage/src/setup-cron-tool.ts",
                sessionId: "file-history-001",
                version: 2,
                backupTime: baseDate.addingTimeInterval(420),
                contentHash: "s1t2u3",
                backupFileName: "s1t2u3@v2"
            ),
        ]),
    ]

    // swiftlint:disable function_body_length
    private static let fileContents: [String: String] = {
        let oldIndex = """
        import type { AnyAgentTool } from "../../core/types";
        import type { OpenClawPluginApi } from "../../core/plugin-api";
        import type { AlertTriagePluginConfig } from "./types";
        import { createAlertIngestTool } from "./alert-ingest-tool";
        import { createAlertListTool } from "./alert-list-tool";
        import { createMcpHealthCheckTool } from "./mcp-health-check-tool";
        import { createAlertTriageSetupCronTool } from "./setup-cron-tool";
        import { createAlertTriageTool } from "./alert-triage-tool";

        const alertTriagePlugin = {
            id: "alert-triage",
            name: "Alert Triage: Prod Alerts to GitHub Issues",
            description:
                "Production alert monitoring and triage automation. " +
                "Ingests alerts from monitoring systems, triages them " +
                "using AI analysis, and creates GitHub issues.",
        """

        let newIndex = """
        import type { AnyAgentTool } from "../../core/types";
        import type { OpenClawPluginApi } from "../../core/plugin-api";
        import type { AlertTriagePluginConfig } from "./types";
        import { createAlertIngestTool } from "./alert-ingest-tool";
        import { createAlertListTool } from "./alert-list-tool";
        import { createMcpHealthCheckTool } from "./mcp-health-check-tool";
        import { createReadSlackTool } from "./read-slack-tool";
        import { createAlertTriageSetupCronTool } from "./setup-cron-tool";
        import { createAlertTriageTool } from "./alert-triage-tool";

        const alertTriagePlugin = {
            id: "alert-triage",
            name: "Alert Triage: Prod Alerts to GitHub Issues",
            description:
                "Production alert monitoring and triage automation. " +
                "Ingests alerts from monitoring systems, triages them " +
                "using AI analysis, and creates GitHub issues.",
        """

        let slackV1 = """
        import { z } from "zod";
        import type { AnyAgentTool } from "../../core/types";

        export function createReadSlackTool(): AnyAgentTool {
            return {
                name: "read_slack_channel",
                description: "Read recent messages from a Slack channel",
                inputSchema: z.object({
                    channel: z.string().describe("Slack channel name or ID"),
                    limit: z.number().optional().default(20),
                }),
                async execute({ channel, limit }) {
                    const response = await fetch(
                        `https://slack.com/api/conversations.history`,
                        {
                            headers: {
                                Authorization: `Bearer ${process.env.SLACK_TOKEN}`,
                            },
                        }
                    );
                    return response.json();
                },
            };
        }
        """

        let slackV2 = """
        import { z } from "zod";
        import type { AnyAgentTool } from "../../core/types";
        import { SlackClient } from "../shared/slack-client";

        export function createReadSlackTool(): AnyAgentTool {
            return {
                name: "read_slack_channel",
                description: "Read recent messages from a Slack channel",
                inputSchema: z.object({
                    channel: z.string().describe("Slack channel name or ID"),
                    limit: z.number().optional().default(20),
                    since: z.string().optional().describe("ISO timestamp"),
                }),
                async execute({ channel, limit, since }) {
                    const client = new SlackClient();
                    const messages = await client.getHistory(channel, {
                        limit,
                        oldest: since,
                    });
                    return { messages, count: messages.length };
                },
            };
        }
        """

        let slackV3 = """
        import { z } from "zod";
        import type { AnyAgentTool } from "../../core/types";
        import { SlackClient } from "../shared/slack-client";
        import { logger } from "../../core/logger";

        export function createReadSlackTool(): AnyAgentTool {
            return {
                name: "read_slack_channel",
                description: "Read recent messages from a Slack channel with filtering",
                inputSchema: z.object({
                    channel: z.string().describe("Slack channel name or ID"),
                    limit: z.number().optional().default(20),
                    since: z.string().optional().describe("ISO timestamp"),
                    includeThreads: z.boolean().optional().default(false),
                }),
                async execute({ channel, limit, since, includeThreads }) {
                    logger.debug(`Reading ${limit} messages from #${channel}`);
                    const client = new SlackClient();
                    const messages = await client.getHistory(channel, {
                        limit,
                        oldest: since,
                        includeReplies: includeThreads,
                    });
                    logger.info(`Fetched ${messages.length} messages from #${channel}`);
                    return { messages, count: messages.length, channel };
                },
            };
        }
        """

        let cronV1 = """
        import { z } from "zod";
        import type { AnyAgentTool } from "../../core/types";

        export function createAlertTriageSetupCronTool(): AnyAgentTool {
            return {
                name: "setup_alert_cron",
                description: "Set up a cron job for periodic alert triage",
                inputSchema: z.object({
                    schedule: z.string().describe("Cron expression"),
                    channels: z.array(z.string()),
                }),
                async execute({ schedule, channels }) {
                    // Register cron with scheduler
                    return { scheduled: true, nextRun: new Date() };
                },
            };
        }
        """

        let cronV2 = """
        import { z } from "zod";
        import type { AnyAgentTool } from "../../core/types";
        import { CronScheduler } from "../../core/scheduler";

        export function createAlertTriageSetupCronTool(): AnyAgentTool {
            return {
                name: "setup_alert_cron",
                description: "Set up a cron job for periodic alert triage",
                inputSchema: z.object({
                    schedule: z.string().describe("Cron expression"),
                    channels: z.array(z.string()),
                    severity: z.enum(["all", "critical", "warning"]).default("all"),
                }),
                async execute({ schedule, channels, severity }) {
                    const scheduler = CronScheduler.shared();
                    const job = await scheduler.register({
                        expression: schedule,
                        handler: "alert-triage",
                        config: { channels, minSeverity: severity },
                    });
                    return { scheduled: true, jobId: job.id, nextRun: job.nextRun };
                },
            };
        }
        """

        return [
            "file-history-001/a1b2c3@v1": oldIndex,
            "file-history-001/d4e5f6@v2": newIndex,
            "file-history-001/g7h8i9@v1": slackV1,
            "file-history-001/j1k2l3@v2": slackV2,
            "file-history-001/m4n5o6@v3": slackV3,
            "file-history-001/p7q8r9@v1": cronV1,
            "file-history-001/s1t2u3@v2": cronV2,
        ]
    }()
    // swiftlint:enable function_body_length

    private struct MockFileHistoryLoader: FileHistoryLoading {
        let entries: [FileHistoryEntry]
        let fileContents: [String: String]

        func loadFileHistory(for _: String, projectPath _: String) -> [FileHistoryEntry] {
            entries
        }

        func loadFileContent(for sessionId: String, backupFileName: String) -> String? {
            fileContents["\(sessionId)/\(backupFileName)"]
        }
    }

    private var mockLoader: MockFileHistoryLoader {
        MockFileHistoryLoader(entries: Self.entries, fileContents: Self.fileContents)
    }

    @Test
    func testFileHistory() async throws {
        let state = makeAppState(
            selectedSession: Self.session
        )
        state.isShowingFileHistory = true

        try await snapshotView(
            compositeAppView(state: state) {
                FileHistoryView(session: Self.session)
                    .environment(\.fileHistoryLoader, mockLoader)
            },
            size: ScreenshotSize.fullApp,
            named: "testFileHistory",
            record: isRecording,
            delay: 2
        )
    }
}
