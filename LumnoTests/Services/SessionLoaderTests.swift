import Testing
import Foundation
@testable import Lumno

@Suite("SessionLoader")
struct SessionLoaderTests {

    @Test func discoverProjects_nonExistentPath_returnsEmpty() throws {
        let loader = SessionLoader(claudeProjectsPath: "/nonexistent/path/\(UUID().uuidString)")
        let projects = try loader.discoverProjects()
        #expect(projects.isEmpty)
    }

    @Test func discoverProjects_emptyDirectory_returnsEmpty() throws {
        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("lumno-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects.isEmpty)
    }

    @Test func discoverProjects_withSubdirectories_returnsProjects() throws {
        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("lumno-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        try FileManager.default.createDirectory(
            at: tmpDir.appendingPathComponent("project-alpha"),
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: tmpDir.appendingPathComponent("project-beta"),
            withIntermediateDirectories: true
        )

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects.count == 2)

        let names = Set(projects.map(\.name))
        #expect(names.contains("project-alpha"))
        #expect(names.contains("project-beta"))
    }

    @Test func discoverProjects_skipsFiles_onlyIncludesDirectories() throws {
        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("lumno-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        try FileManager.default.createDirectory(
            at: tmpDir.appendingPathComponent("real-project"),
            withIntermediateDirectories: true
        )
        FileManager.default.createFile(
            atPath: tmpDir.appendingPathComponent("not-a-project.txt").path,
            contents: Data("hello".utf8)
        )

        let loader = SessionLoader(claudeProjectsPath: tmpDir.path)
        let projects = try loader.discoverProjects()
        #expect(projects.count == 1)
        #expect(projects[0].name == "real-project")
    }
}
