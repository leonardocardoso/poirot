@testable import Poirot
import Foundation
import Testing

@Suite("MCPServerStatus")
struct MCPServerStatusTests {
    // MARK: - Enum Properties

    @Test("All status cases have a symbol name")
    func allCasesHaveSymbolName() {
        for status in MCPServerStatus.allCases {
            #expect(!status.symbolName.isEmpty)
        }
    }

    @Test("All status cases have a label")
    func allCasesHaveLabel() {
        for status in MCPServerStatus.allCases {
            #expect(!status.label.isEmpty)
        }
    }

    @Test("All status cases have an accessibility label")
    func allCasesHaveAccessibilityLabel() {
        for status in MCPServerStatus.allCases {
            #expect(!status.accessibilityLabel.isEmpty)
        }
    }

    @Test("Connected status uses circle.fill symbol")
    func connectedSymbol() {
        #expect(MCPServerStatus.connected.symbolName == "circle.fill")
    }

    @Test("NeedsAuth status uses triangle warning symbol")
    func needsAuthSymbol() {
        #expect(
            MCPServerStatus.needsAuth.symbolName == "exclamationmark.triangle.fill"
        )
    }

    @Test("Failed status uses xmark circle symbol")
    func failedSymbol() {
        #expect(MCPServerStatus.failed.symbolName == "xmark.circle.fill")
    }

    @Test("Unreachable status uses bolt horizontal symbol")
    func unreachableSymbol() {
        #expect(
            MCPServerStatus.unreachable.symbolName == "bolt.horizontal.circle.fill"
        )
    }

    @Test("Starting status uses circle.fill symbol")
    func startingSymbol() {
        #expect(MCPServerStatus.starting.symbolName == "circle.fill")
    }

    @Test("Unknown status uses questionmark symbol")
    func unknownSymbol() {
        #expect(
            MCPServerStatus.unknown.symbolName == "questionmark.circle.fill"
        )
    }

    @Test("Status labels are human-readable")
    func statusLabels() {
        #expect(MCPServerStatus.connected.label == "Connected")
        #expect(MCPServerStatus.needsAuth.label == "Needs Auth")
        #expect(MCPServerStatus.failed.label == "Failed")
        #expect(MCPServerStatus.unreachable.label == "Unreachable")
        #expect(MCPServerStatus.starting.label == "Starting")
        #expect(MCPServerStatus.unknown.label == "Unknown")
    }

    @Test("Status raw values match expected strings")
    func statusRawValues() {
        #expect(MCPServerStatus.connected.rawValue == "connected")
        #expect(MCPServerStatus.needsAuth.rawValue == "needsAuth")
        #expect(MCPServerStatus.failed.rawValue == "failed")
        #expect(MCPServerStatus.unreachable.rawValue == "unreachable")
        #expect(MCPServerStatus.starting.rawValue == "starting")
        #expect(MCPServerStatus.unknown.rawValue == "unknown")
    }

    // MARK: - MCPServer Model

    @Test("MCPServer defaults to unknown status")
    func serverDefaultStatus() {
        let server = MCPServer(
            id: "test-server",
            name: "Test",
            rawName: "test",
            tools: [],
            isWildcard: false,
            scope: .global,
            source: .user,
            type: "stdio",
            command: "node",
            args: [],
            env: [:],
            url: nil
        )
        #expect(server.status == .unknown)
    }

    @Test("MCPServer status can be set explicitly")
    func serverExplicitStatus() {
        let server = MCPServer(
            id: "test-server",
            name: "Test",
            rawName: "test",
            tools: [],
            isWildcard: false,
            scope: .global,
            source: .user,
            type: "stdio",
            command: "node",
            args: [],
            env: [:],
            url: nil,
            status: .connected
        )
        #expect(server.status == .connected)
    }

    @Test("MCPServer status is mutable")
    func serverMutableStatus() {
        var server = MCPServer(
            id: "test-server",
            name: "Test",
            rawName: "test",
            tools: [],
            isWildcard: false,
            scope: .global,
            source: .user,
            type: "stdio",
            command: "node",
            args: [],
            env: [:],
            url: nil
        )
        #expect(server.status == .unknown)
        server.status = .needsAuth
        #expect(server.status == .needsAuth)
    }
}
