nonisolated protocol HistoryLoading: Sendable {
    func loadAll() -> [HistoryEntry]
    func entryCount() -> Int
    func delete(entry: HistoryEntry)
    @discardableResult
    func deleteOlderThan(days: Int) -> Int
}
