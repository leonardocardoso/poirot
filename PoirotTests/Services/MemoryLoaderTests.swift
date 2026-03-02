@testable import Poirot
import Foundation
import Testing

@Suite("MemoryLoader")
struct MemoryLoaderTests {
    // MARK: - Load Memory Files

    @Test
    func loadMemoryFiles_returnsEmptyForMissingDirectory() {
        let files = ClaudeConfigLoader.loadMemoryFiles(
            projectDirName: "nonexistent-project-\(UUID().uuidString)"
        )
        #expect(files.isEmpty)
    }

    @Test
    func loadMemoryFiles_loadsMarkdownFiles() throws {
        let (projectDir, memoryDir) = try createTempMemoryDir()
        defer { try? FileManager.default.removeItem(at: projectDir) }

        try "# Main Memory".write(
            to: memoryDir.appendingPathComponent("MEMORY.md"),
            atomically: true, encoding: .utf8
        )
        try "# Debugging tips".write(
            to: memoryDir.appendingPathComponent("debugging.md"),
            atomically: true, encoding: .utf8
        )
        // Non-md file should be ignored
        try "not markdown".write(
            to: memoryDir.appendingPathComponent("notes.txt"),
            atomically: true, encoding: .utf8
        )

        let dirName = projectDir.lastPathComponent
        let files = ClaudeConfigLoader.loadMemoryFiles(projectDirName: dirName)

        #expect(files.count == 2)
        // MEMORY.md should be first (sorted to top)
        #expect(files.first?.isMain == true)
        #expect(files.first?.name == "MEMORY")
        #expect(files.first?.content == "# Main Memory")
    }

    @Test
    func loadMemoryFiles_memoryMdSortedFirst() throws {
        let (projectDir, memoryDir) = try createTempMemoryDir()
        defer { try? FileManager.default.removeItem(at: projectDir) }

        try "# Patterns".write(
            to: memoryDir.appendingPathComponent("patterns.md"),
            atomically: true, encoding: .utf8
        )
        try "# Main".write(
            to: memoryDir.appendingPathComponent("MEMORY.md"),
            atomically: true, encoding: .utf8
        )
        try "# Architecture".write(
            to: memoryDir.appendingPathComponent("architecture.md"),
            atomically: true, encoding: .utf8
        )

        let dirName = projectDir.lastPathComponent
        let files = ClaudeConfigLoader.loadMemoryFiles(projectDirName: dirName)

        #expect(files.count == 3)
        #expect(files[0].filename == "MEMORY.md")
        #expect(files[0].isMain == true)
        // Remaining files sorted alphabetically
        #expect(files[1].name == "Architecture")
        #expect(files[2].name == "Patterns")
    }

    @Test
    func loadMemoryFiles_setsProjectID() throws {
        let (projectDir, memoryDir) = try createTempMemoryDir()
        defer { try? FileManager.default.removeItem(at: projectDir) }

        try "# Test".write(
            to: memoryDir.appendingPathComponent("test.md"),
            atomically: true, encoding: .utf8
        )

        let dirName = projectDir.lastPathComponent
        let files = ClaudeConfigLoader.loadMemoryFiles(projectDirName: dirName)

        #expect(files.first?.projectID == dirName)
    }

    // MARK: - Helpers

    private func createTempMemoryDir() throws -> (projectDir: URL, memoryDir: URL) {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let projectDir = home
            .appendingPathComponent(".claude/projects")
            .appendingPathComponent("test-memory-\(UUID().uuidString)")
        let memoryDir = projectDir.appendingPathComponent("memory")
        try FileManager.default.createDirectory(at: memoryDir, withIntermediateDirectories: true)
        return (projectDir, memoryDir)
    }
}
