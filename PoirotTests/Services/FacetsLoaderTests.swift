@testable import Poirot
import Foundation
import Testing

@Suite("FacetsLoader")
struct FacetsLoaderTests {
    // MARK: - Helpers

    private func makeTempFacetsDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("poirot-facets-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func writeFacetsFile(
        in dir: URL,
        sessionId: String,
        goal: String = "Test goal",
        outcome: String = "success",
        helpfulness: String = "very_helpful",
        sessionType: String = "single_task",
        summary: String = "Test summary"
    ) throws {
        let json = """
        {
          "underlying_goal": "\(goal)",
          "goal_categories": {"testing": 1},
          "outcome": "\(outcome)",
          "user_satisfaction_counts": {},
          "claude_helpfulness": "\(helpfulness)",
          "session_type": "\(sessionType)",
          "friction_counts": {},
          "friction_detail": "",
          "primary_success": "none",
          "brief_summary": "\(summary)",
          "session_id": "\(sessionId)"
        }
        """
        let fileURL = dir.appendingPathComponent("\(sessionId).json")
        try json.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    // MARK: - loadFacets

    @Test
    func loadFacets_nonExistentPath_returnsNil() {
        let loader = FacetsLoader(claudeFacetsPath: "/nonexistent/path/\(UUID().uuidString)")
        let result = loader.loadFacets(for: "some-session-id")
        #expect(result == nil)
    }

    @Test
    func loadFacets_existingFile_returnsFacets() throws {
        let dir = try makeTempFacetsDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let sessionId = "abc-1234"
        try writeFacetsFile(in: dir, sessionId: sessionId, goal: "Refactor auth")

        let loader = FacetsLoader(claudeFacetsPath: dir.path)
        let result = loader.loadFacets(for: sessionId)

        #expect(result != nil)
        #expect(result?.sessionId == sessionId)
        #expect(result?.underlyingGoal == "Refactor auth")
    }

    @Test
    func loadFacets_missingFile_returnsNil() throws {
        let dir = try makeTempFacetsDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        try writeFacetsFile(in: dir, sessionId: "other-session")

        let loader = FacetsLoader(claudeFacetsPath: dir.path)
        let result = loader.loadFacets(for: "nonexistent-session")
        #expect(result == nil)
    }

    @Test
    func loadFacets_invalidJSON_returnsNil() throws {
        let dir = try makeTempFacetsDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let fileURL = dir.appendingPathComponent("bad-session.json")
        try "not valid json".write(to: fileURL, atomically: true, encoding: .utf8)

        let loader = FacetsLoader(claudeFacetsPath: dir.path)
        let result = loader.loadFacets(for: "bad-session")
        #expect(result == nil)
    }

    // MARK: - loadAllFacets

    @Test
    func loadAllFacets_nonExistentPath_returnsEmpty() {
        let loader = FacetsLoader(claudeFacetsPath: "/nonexistent/path/\(UUID().uuidString)")
        let result = loader.loadAllFacets()
        #expect(result.isEmpty)
    }

    @Test
    func loadAllFacets_emptyDirectory_returnsEmpty() throws {
        let dir = try makeTempFacetsDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let loader = FacetsLoader(claudeFacetsPath: dir.path)
        let result = loader.loadAllFacets()
        #expect(result.isEmpty)
    }

    @Test
    func loadAllFacets_multipleFiles_returnsAll() throws {
        let dir = try makeTempFacetsDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        try writeFacetsFile(in: dir, sessionId: "session-1", goal: "Goal 1")
        try writeFacetsFile(in: dir, sessionId: "session-2", goal: "Goal 2")
        try writeFacetsFile(in: dir, sessionId: "session-3", goal: "Goal 3")

        let loader = FacetsLoader(claudeFacetsPath: dir.path)
        let result = loader.loadAllFacets()

        #expect(result.count == 3)
        #expect(result["session-1"]?.underlyingGoal == "Goal 1")
        #expect(result["session-2"]?.underlyingGoal == "Goal 2")
        #expect(result["session-3"]?.underlyingGoal == "Goal 3")
    }

    @Test
    func loadAllFacets_skipsInvalidFiles() throws {
        let dir = try makeTempFacetsDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        try writeFacetsFile(in: dir, sessionId: "good-session", goal: "Good goal")
        let badURL = dir.appendingPathComponent("bad-session.json")
        try "not json".write(to: badURL, atomically: true, encoding: .utf8)

        let loader = FacetsLoader(claudeFacetsPath: dir.path)
        let result = loader.loadAllFacets()

        #expect(result.count == 1)
        #expect(result["good-session"] != nil)
    }

    @Test
    func loadAllFacets_skipsNonJSONFiles() throws {
        let dir = try makeTempFacetsDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        try writeFacetsFile(in: dir, sessionId: "good-session")
        let txtURL = dir.appendingPathComponent("readme.txt")
        try "not a facets file".write(to: txtURL, atomically: true, encoding: .utf8)

        let loader = FacetsLoader(claudeFacetsPath: dir.path)
        let result = loader.loadAllFacets()

        #expect(result.count == 1)
    }

    @Test
    func loadAllFacets_keyedBySessionId() throws {
        let dir = try makeTempFacetsDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let sessionId = "00163b58-3b30-49fa-af28-052f06724f50"
        try writeFacetsFile(in: dir, sessionId: sessionId, goal: "UUID session")

        let loader = FacetsLoader(claudeFacetsPath: dir.path)
        let result = loader.loadAllFacets()

        #expect(result[sessionId] != nil)
        #expect(result[sessionId]?.underlyingGoal == "UUID session")
    }
}
