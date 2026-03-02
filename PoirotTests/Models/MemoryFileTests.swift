@testable import Poirot
import Foundation
import Testing

@Suite("MemoryFile")
struct MemoryFileTests {
    // MARK: - Display Name

    @Test
    func displayName_memoryMdReturnsMemory() {
        let result = MemoryFile.displayName(from: "MEMORY.md")
        #expect(result == "MEMORY")
    }

    @Test
    func displayName_lowercaseMemoryMdReturnsMemory() {
        let result = MemoryFile.displayName(from: "memory.md")
        #expect(result == "MEMORY")
    }

    @Test
    func displayName_simpleFilename() {
        let result = MemoryFile.displayName(from: "debugging.md")
        #expect(result == "Debugging")
    }

    @Test
    func displayName_hyphenatedFilename() {
        let result = MemoryFile.displayName(from: "code-patterns.md")
        #expect(result == "Code Patterns")
    }

    @Test
    func displayName_underscoredFilename() {
        let result = MemoryFile.displayName(from: "test_patterns.md")
        #expect(result == "Test Patterns")
    }

    @Test
    func displayName_mixedSeparators() {
        let result = MemoryFile.displayName(from: "my-code_style.md")
        #expect(result == "My Code Style")
    }

    // MARK: - isMain

    @Test
    func isMain_trueForMemoryMd() {
        let file = MemoryFile(
            id: "proj-MEMORY.md",
            name: "MEMORY",
            filename: "MEMORY.md",
            content: "# Memory",
            fileURL: URL(fileURLWithPath: "/tmp/MEMORY.md"),
            projectID: "proj"
        )
        #expect(file.isMain)
    }

    @Test
    func isMain_trueForLowercaseMemoryMd() {
        let file = MemoryFile(
            id: "proj-memory.md",
            name: "Memory",
            filename: "memory.md",
            content: "",
            fileURL: URL(fileURLWithPath: "/tmp/memory.md"),
            projectID: "proj"
        )
        #expect(file.isMain)
    }

    @Test
    func isMain_falseForOtherFiles() {
        let file = MemoryFile(
            id: "proj-debugging.md",
            name: "Debugging",
            filename: "debugging.md",
            content: "",
            fileURL: URL(fileURLWithPath: "/tmp/debugging.md"),
            projectID: "proj"
        )
        #expect(!file.isMain)
    }

    // MARK: - Identifiable & Hashable

    @Test
    func identifiable_usesIdProperty() {
        let file = MemoryFile(
            id: "test-id",
            name: "Test",
            filename: "test.md",
            content: "",
            fileURL: URL(fileURLWithPath: "/tmp/test.md"),
            projectID: "proj"
        )
        #expect(file.id == "test-id")
    }

    @Test
    func hashable_equalFilesHaveSameHash() {
        let url = URL(fileURLWithPath: "/tmp/test.md")
        let file1 = MemoryFile(id: "a", name: "A", filename: "a.md", content: "x", fileURL: url, projectID: "p")
        let file2 = MemoryFile(id: "a", name: "A", filename: "a.md", content: "x", fileURL: url, projectID: "p")
        #expect(file1 == file2)
        #expect(file1.hashValue == file2.hashValue)
    }

    @Test
    func hashable_differentFilesAreDifferent() {
        let file1 = MemoryFile(
            id: "a", name: "A", filename: "a.md", content: "x",
            fileURL: URL(fileURLWithPath: "/tmp/a.md"), projectID: "p"
        )
        let file2 = MemoryFile(
            id: "b", name: "B", filename: "b.md", content: "y",
            fileURL: URL(fileURLWithPath: "/tmp/b.md"), projectID: "p"
        )
        #expect(file1 != file2)
    }

    // MARK: - Fuzzy Match

    @Test
    func fuzzyMatch_matchesMemoryName() {
        let result = HighlightedText.fuzzyMatch("Debugging", query: "debug")
        #expect(result != nil)
        #expect(result!.score > 0)
    }

    @Test
    func fuzzyMatch_noMatchReturnsNil() {
        let result = HighlightedText.fuzzyMatch("Debugging", query: "zzzzz")
        #expect(result == nil)
    }

    @Test
    func fuzzyMatch_matchesMemoryContent() {
        let content = "Always use bun instead of npm for this project"
        let result = HighlightedText.fuzzyMatch(content, query: "bun")
        #expect(result != nil)
        #expect(result!.score > 0)
    }
}
