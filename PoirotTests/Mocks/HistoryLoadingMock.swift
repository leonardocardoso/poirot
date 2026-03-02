@testable import Poirot

nonisolated final class HistoryLoadingMock: HistoryLoading, @unchecked Sendable {
    var entries: [HistoryEntry] = []

    func loadAll() -> [HistoryEntry] {
        entries
    }

    func entryCount() -> Int {
        entries.count
    }

    func delete(entry: HistoryEntry) { }

    @discardableResult
    func deleteOlderThan(days: Int) -> Int { 0 }
}
