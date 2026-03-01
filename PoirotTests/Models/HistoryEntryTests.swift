@testable import Poirot
import Foundation
import Testing

@Suite("HistoryEntry")
struct HistoryEntryTests {
    @Test
    func projectName_extractsLastPathComponent() {
        let entry = HistoryEntry(
            id: "1-0",
            display: "test prompt",
            pastedContents: [:],
            timestamp: Date(),
            project: "/Users/test/Dev/my-project"
        )
        #expect(entry.projectName == "my-project")
    }

    @Test
    func snippet_truncatesMultipleLines() {
        let entry = HistoryEntry(
            id: "1-0",
            display: "Line one\nLine two\nLine three\nLine four\nLine five",
            pastedContents: [:],
            timestamp: Date(),
            project: "/test"
        )
        #expect(entry.snippet == "Line one Line two Line three")
    }

    @Test
    func snippet_skipsEmptyLines() {
        let entry = HistoryEntry(
            id: "1-0",
            display: "First\n\n\nSecond",
            pastedContents: [:],
            timestamp: Date(),
            project: "/test"
        )
        #expect(entry.snippet == "First Second")
    }

    @Test
    func timeAgo_returnsRelativeString() {
        let entry = HistoryEntry(
            id: "1-0",
            display: "test",
            pastedContents: [:],
            timestamp: Date(),
            project: "/test"
        )
        // Just verify it returns a non-empty string
        #expect(!entry.timeAgo.isEmpty)
    }

    @Test
    func equality_basedOnId() {
        let entry1 = HistoryEntry(id: "same-id", display: "a", pastedContents: [:], timestamp: Date(), project: "/a")
        let entry2 = HistoryEntry(id: "same-id", display: "b", pastedContents: [:], timestamp: Date(), project: "/b")
        #expect(entry1 == entry2)
    }

    @Test
    func inequality_differentIds() {
        let entry1 = HistoryEntry(id: "id-1", display: "a", pastedContents: [:], timestamp: Date(), project: "/a")
        let entry2 = HistoryEntry(id: "id-2", display: "a", pastedContents: [:], timestamp: Date(), project: "/a")
        #expect(entry1 != entry2)
    }
}

@Suite("HistoryDateGroup")
struct HistoryDateGroupTests {
    @Test
    func today_groupsCorrectly() {
        let group = HistoryDateGroup.group(for: Date())
        #expect(group == .today)
    }

    @Test
    func yesterday_groupsCorrectly() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let group = HistoryDateGroup.group(for: yesterday)
        #expect(group == .yesterday)
    }

    @Test
    func older_groupsDistantPast() {
        let oldDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let group = HistoryDateGroup.group(for: oldDate)
        #expect(group == .older)
    }

    @Test
    func allCases_haveNonEmptyTitles() {
        for dateGroup in HistoryDateGroup.allCases {
            #expect(!dateGroup.title.isEmpty)
        }
    }
}
