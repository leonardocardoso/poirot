@testable import Poirot
import Foundation
import Testing

@Suite("StatsCache Model")
struct StatsCacheTests {
    // MARK: - Test JSON

    private static let validJSON = """
    {
      "version": 2,
      "lastComputedDate": "2026-02-17",
      "dailyActivity": [
        {
          "date": "2026-01-01",
          "messageCount": 18255,
          "sessionCount": 11,
          "toolCallCount": 5324
        },
        {
          "date": "2026-01-02",
          "messageCount": 360,
          "sessionCount": 1,
          "toolCallCount": 100
        }
      ],
      "dailyModelTokens": [
        {
          "date": "2026-01-01",
          "tokensByModel": {
            "claude-opus-4-5-20251101": 2269186
          }
        },
        {
          "date": "2026-01-12",
          "tokensByModel": {
            "claude-opus-4-5-20251101": 196417,
            "claude-sonnet-4-5-20250929": 99944
          }
        }
      ],
      "modelUsage": {
        "claude-opus-4-5-20251101": {
          "inputTokens": 4020186,
          "outputTokens": 3833943,
          "cacheReadInputTokens": 7246318082,
          "cacheCreationInputTokens": 325882562,
          "webSearchRequests": 0,
          "costUSD": 0,
          "contextWindow": 0,
          "maxOutputTokens": 0
        },
        "claude-opus-4-6": {
          "inputTokens": 592180,
          "outputTokens": 1778001,
          "cacheReadInputTokens": 2323328386,
          "cacheCreationInputTokens": 103861546,
          "webSearchRequests": 0,
          "costUSD": 0,
          "contextWindow": 0,
          "maxOutputTokens": 0
        }
      },
      "totalSessions": 466,
      "totalMessages": 322626,
      "longestSession": {
        "sessionId": "ce55f01b-e4f4-4c6a-934e-f95ba536935f",
        "duration": 321972719,
        "messageCount": 1504,
        "timestamp": "2026-01-13T19:55:30.879Z"
      },
      "firstSessionDate": "2025-12-31T19:57:52.149Z",
      "hourCounts": {
        "0": 3,
        "11": 52,
        "23": 16
      },
      "totalSpeculationTimeSavedMs": 0
    }
    """

    // MARK: - Decoding

    @Test
    func decode_fullJSON_succeeds() throws {
        let data = Data(Self.validJSON.utf8)
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        #expect(stats.version == 2)
        #expect(stats.lastComputedDate == "2026-02-17")
        #expect(stats.totalSessions == 466)
        #expect(stats.totalMessages == 322_626)
        #expect(stats.totalSpeculationTimeSavedMs == 0)
    }

    @Test
    func decode_dailyActivity_parsesCorrectly() throws {
        let data = Data(Self.validJSON.utf8)
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        #expect(stats.dailyActivity.count == 2)
        #expect(stats.dailyActivity[0].date == "2026-01-01")
        #expect(stats.dailyActivity[0].messageCount == 18255)
        #expect(stats.dailyActivity[0].sessionCount == 11)
        #expect(stats.dailyActivity[0].toolCallCount == 5324)
    }

    @Test
    func decode_dailyModelTokens_parsesMultiModel() throws {
        let data = Data(Self.validJSON.utf8)
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        #expect(stats.dailyModelTokens.count == 2)
        let multiModel = stats.dailyModelTokens[1]
        #expect(multiModel.tokensByModel.count == 2)
        #expect(multiModel.tokensByModel["claude-opus-4-5-20251101"] == 196_417)
        #expect(multiModel.tokensByModel["claude-sonnet-4-5-20250929"] == 99944)
    }

    @Test
    func decode_modelUsage_parsesTokenCounts() throws {
        let data = Data(Self.validJSON.utf8)
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        #expect(stats.modelUsage.count == 2)
        let opus = try #require(stats.modelUsage["claude-opus-4-5-20251101"])
        #expect(opus.inputTokens == 4_020_186)
        #expect(opus.outputTokens == 3_833_943)
        #expect(opus.cacheReadInputTokens == 7_246_318_082)
        #expect(opus.cacheCreationInputTokens == 325_882_562)
    }

    @Test
    func decode_longestSession_parsesAllFields() throws {
        let data = Data(Self.validJSON.utf8)
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        #expect(stats.longestSession.sessionId == "ce55f01b-e4f4-4c6a-934e-f95ba536935f")
        #expect(stats.longestSession.duration == 321_972_719)
        #expect(stats.longestSession.messageCount == 1504)
    }

    @Test
    func decode_hourCounts_parsesStringKeys() throws {
        let data = Data(Self.validJSON.utf8)
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        #expect(stats.hourCounts["0"] == 3)
        #expect(stats.hourCounts["11"] == 52)
        #expect(stats.hourCounts["23"] == 16)
    }

    // MARK: - Computed Helpers

    @Test
    func longestSessionFormatted_showsHoursAndMinutes() throws {
        let data = Data(Self.validJSON.utf8)
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        // 321972719 ms = ~89h 26m
        #expect(stats.longestSessionFormatted == "89h 26m")
    }

    @Test
    func sortedHourCounts_sortsAscending() throws {
        let data = Data(Self.validJSON.utf8)
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        let sorted = stats.sortedHourCounts
        #expect(sorted.count == 3)
        #expect(sorted[0].hour == 0)
        #expect(sorted[1].hour == 11)
        #expect(sorted[2].hour == 23)
    }

    @Test
    func totalOutputTokens_sumsAcrossModels() throws {
        let data = Data(Self.validJSON.utf8)
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        #expect(stats.totalOutputTokens == 3_833_943 + 1_778_001)
    }

    @Test
    func friendlyModelName_mapsKnownModels() {
        #expect(StatsCache.friendlyModelName("claude-opus-4-6") == "Opus 4.6")
        #expect(StatsCache.friendlyModelName("claude-opus-4-5-20251101") == "Opus 4.5")
        #expect(StatsCache.friendlyModelName("claude-sonnet-4-5-20250929") == "Sonnet 4.5")
        #expect(StatsCache.friendlyModelName("unknown-model") == "unknown-model")
    }

    @Test
    func firstSessionParsedDate_parsesISO8601() throws {
        let data = Data(Self.validJSON.utf8)
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        let date = try #require(stats.firstSessionParsedDate)
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 31)
    }

    @Test
    func totalToolCalls_sumsAcrossDays() throws {
        let data = Data(Self.validJSON.utf8)
        let stats = try JSONDecoder().decode(StatsCache.self, from: data)

        #expect(stats.totalToolCalls == 5324 + 100)
    }

    // MARK: - StatsCacheLoader

    @Test
    func loader_missingFile_returnsNil() {
        let result = StatsCacheLoader.load(from: "/nonexistent/path/stats-cache.json")
        #expect(result == nil)
    }
}
