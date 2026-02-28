@testable import Poirot

final class TodoLoadingMock: TodoLoading, @unchecked Sendable {
    var claudeTodosPath: String = "/tmp/mock-claude-todos"

    // MARK: - loadTodos

    var loadTodosCallsCount = 0
    var loadTodosCalled: Bool { loadTodosCallsCount > 0 }
    var loadTodosReceivedSessionId: String?
    var loadTodosReturnValue: [SessionTodo] = []
    var loadTodosClosure: ((String) -> [SessionTodo])?

    func loadTodos(for sessionId: String) -> [SessionTodo] {
        loadTodosCallsCount += 1
        loadTodosReceivedSessionId = sessionId
        if let closure = loadTodosClosure { return closure(sessionId) }
        return loadTodosReturnValue
    }

    // MARK: - deleteTodos

    var deleteTodosCallsCount = 0
    var deleteTodosCalled: Bool { deleteTodosCallsCount > 0 }
    var deleteTodosReceivedSessionId: String?

    func deleteTodos(for sessionId: String) {
        deleteTodosCallsCount += 1
        deleteTodosReceivedSessionId = sessionId
    }
}
