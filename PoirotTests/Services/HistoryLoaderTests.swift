@testable import Poirot
import Foundation
import Testing

@Suite("HistoryLoader")
struct HistoryLoaderTests {
    // MARK: - Helpers

    private func makeTempFile(content: String) throws -> String {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("poirot-history-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let filePath = dir.appendingPathComponent("history.jsonl").path
        try content.write(toFile: filePath, atomically: true, encoding: .utf8)
        return filePath
    }

    private func cleanup(_ path: String) {
        let dir = (path as NSString).deletingLastPathComponent
        try? FileManager.default.removeItem(atPath: dir)
    }

    // MARK: - loadAll

    @Test
    func loadAll_nonExistentFile_returnsEmpty() {
        let loader = HistoryLoader(historyFilePath: "/nonexistent/\(UUID().uuidString)")
        let entries = loader.loadAll()
        #expect(entries.isEmpty)
    }

    @Test
    func loadAll_emptyFile_returnsEmpty() throws {
        let path = try makeTempFile(content: "")
        defer { cleanup(path) }

        let loader = HistoryLoader(historyFilePath: path)
        let entries = loader.loadAll()
        #expect(entries.isEmpty)
    }

    @Test
    func loadAll_singleEntry_parsesCorrectly() throws {
        let json = """
        {"display":"hello world","pastedContents":{},"timestamp":1700000000000,"project":"/Users/test/my-project"}
        """
        let path = try makeTempFile(content: json)
        defer { cleanup(path) }

        let loader = HistoryLoader(historyFilePath: path)
        let entries = loader.loadAll()
        #expect(entries.count == 1)
        #expect(entries[0].display == "hello world")
        #expect(entries[0].project == "/Users/test/my-project")
        #expect(entries[0].projectName == "my-project")
    }

    @Test
    func loadAll_multipleEntries_sortedByTimestampDescending() throws {
        let json = """
        {"display":"first","pastedContents":{},"timestamp":1700000000000,"project":"/a"}
        {"display":"second","pastedContents":{},"timestamp":1700000002000,"project":"/b"}
        {"display":"third","pastedContents":{},"timestamp":1700000001000,"project":"/c"}
        """
        let path = try makeTempFile(content: json)
        defer { cleanup(path) }

        let loader = HistoryLoader(historyFilePath: path)
        let entries = loader.loadAll()
        #expect(entries.count == 3)
        #expect(entries[0].display == "second")
        #expect(entries[1].display == "third")
        #expect(entries[2].display == "first")
    }

    @Test
    func loadAll_skipsInvalidLines() throws {
        let json = """
        {"display":"valid","pastedContents":{},"timestamp":1700000000000,"project":"/a"}
        not valid json
        {"display":"also valid","pastedContents":{},"timestamp":1700000001000,"project":"/b"}
        """
        let path = try makeTempFile(content: json)
        defer { cleanup(path) }

        let loader = HistoryLoader(historyFilePath: path)
        let entries = loader.loadAll()
        #expect(entries.count == 2)
    }

    @Test
    func loadAll_handlesPastedContents() throws {
        let json = """
        {"display":"test","pastedContents":{"file.txt":"contents here"},"timestamp":1700000000000,"project":"/a"}
        """
        let path = try makeTempFile(content: json)
        defer { cleanup(path) }

        let loader = HistoryLoader(historyFilePath: path)
        let entries = loader.loadAll()
        #expect(entries.count == 1)
        #expect(entries[0].pastedContents["file.txt"] == "contents here")
    }

    @Test
    func loadAll_handlesNullPastedContents() throws {
        let json = """
        {"display":"test","pastedContents":null,"timestamp":1700000000000,"project":"/a"}
        """
        let path = try makeTempFile(content: json)
        defer { cleanup(path) }

        let loader = HistoryLoader(historyFilePath: path)
        let entries = loader.loadAll()
        #expect(entries.count == 1)
        #expect(entries[0].pastedContents.isEmpty)
    }

    @Test
    func loadAll_timestampConvertedFromMilliseconds() throws {
        // 1700000000000ms = 1700000000s = 2023-11-14T22:13:20Z
        let json = """
        {"display":"test","pastedContents":{},"timestamp":1700000000000,"project":"/a"}
        """
        let path = try makeTempFile(content: json)
        defer { cleanup(path) }

        let loader = HistoryLoader(historyFilePath: path)
        let entries = loader.loadAll()
        #expect(entries.count == 1)

        let expectedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let diff = abs(entries[0].timestamp.timeIntervalSince(expectedDate))
        #expect(diff < 1.0)
    }

    // MARK: - entryCount

    @Test
    func entryCount_nonExistentFile_returnsZero() {
        let loader = HistoryLoader(historyFilePath: "/nonexistent/\(UUID().uuidString)")
        #expect(loader.entryCount() == 0)
    }

    @Test
    func entryCount_matchesLineCount() throws {
        let json = """
        {"display":"a","pastedContents":{},"timestamp":1700000000000,"project":"/a"}
        {"display":"b","pastedContents":{},"timestamp":1700000001000,"project":"/b"}
        {"display":"c","pastedContents":{},"timestamp":1700000002000,"project":"/c"}
        """
        let path = try makeTempFile(content: json)
        defer { cleanup(path) }

        let loader = HistoryLoader(historyFilePath: path)
        #expect(loader.entryCount() == 3)
    }

    // MARK: - uniqueProjects

    @Test
    func uniqueProjects_returnsDistinctPaths() throws {
        let json = """
        {"display":"a","pastedContents":{},"timestamp":1700000002000,"project":"/project-a"}
        {"display":"b","pastedContents":{},"timestamp":1700000001000,"project":"/project-b"}
        {"display":"c","pastedContents":{},"timestamp":1700000000000,"project":"/project-a"}
        """
        let path = try makeTempFile(content: json)
        defer { cleanup(path) }

        let loader = HistoryLoader(historyFilePath: path)
        let projects = loader.uniqueProjects()
        #expect(projects.count == 2)
        // Ordered by first appearance (entries sorted by timestamp desc)
        #expect(projects[0] == "/project-a")
        #expect(projects[1] == "/project-b")
    }

    @Test
    func uniqueProjects_nonExistentFile_returnsEmpty() {
        let loader = HistoryLoader(historyFilePath: "/nonexistent/\(UUID().uuidString)")
        #expect(loader.uniqueProjects().isEmpty)
    }
}
