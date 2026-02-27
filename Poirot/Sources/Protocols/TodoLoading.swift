protocol TodoLoading: Sendable {
    var claudeTodosPath: String { get }
    func loadTodos(for sessionId: String) -> [SessionTodo]
    func deleteTodos(for sessionId: String)
}
