@testable import Poirot
import Foundation
import Testing

@Suite("DebugLogEntry")
struct DebugLogEntryTests {
    @Test
    func levelRawValues() {
        #expect(DebugLogEntry.Level.debug.rawValue == "DEBUG")
        #expect(DebugLogEntry.Level.warn.rawValue == "WARN")
        #expect(DebugLogEntry.Level.error.rawValue == "ERROR")
    }

    @Test
    func levelLabels() {
        #expect(DebugLogEntry.Level.debug.label == "DEBUG")
        #expect(DebugLogEntry.Level.warn.label == "WARN")
        #expect(DebugLogEntry.Level.error.label == "ERROR")
    }

    @Test
    func allCases_containsThreeLevels() {
        #expect(DebugLogEntry.Level.allCases.count == 3)
    }

    @Test
    func identifiable_usesIndex() {
        let entry = DebugLogEntry(
            id: 42,
            timestamp: Date(),
            level: .debug,
            message: "Test"
        )
        #expect(entry.id == 42)
    }

    @Test
    func hashable_sameIdAreEqual() {
        let date = Date()
        let entryA = DebugLogEntry(
            id: 1,
            timestamp: date,
            level: .debug,
            message: "A"
        )
        let entryB = DebugLogEntry(
            id: 1,
            timestamp: date,
            level: .debug,
            message: "A"
        )
        #expect(entryA == entryB)
    }

    @Test
    func hashable_differentIdAreNotEqual() {
        let date = Date()
        let entryA = DebugLogEntry(
            id: 1,
            timestamp: date,
            level: .debug,
            message: "A"
        )
        let entryB = DebugLogEntry(
            id: 2,
            timestamp: date,
            level: .debug,
            message: "A"
        )
        #expect(entryA != entryB)
    }
}
