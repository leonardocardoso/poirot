nonisolated protocol FileHistoryLoading: Sendable {
    func loadFileHistory(for sessionId: String, projectPath: String) -> [FileHistoryEntry]
    func loadFileContent(for sessionId: String, backupFileName: String) -> String?
}
