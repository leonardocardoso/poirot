@testable import Poirot
import Foundation
import Testing

@Suite("SessionTodo Model")
struct SessionTodoTests {
    @Test
    func decodesCompletedStatus() throws {
        let json = """
        {"content": "Fix the bug", "status": "completed", "activeForm": "Fixing the bug"}
        """
        let todo = try JSONDecoder().decode(SessionTodo.self, from: Data(json.utf8))
        #expect(todo.content == "Fix the bug")
        #expect(todo.status == .completed)
        #expect(todo.activeForm == "Fixing the bug")
    }

    @Test
    func decodesInProgressStatus() throws {
        let json = """
        {"content": "Write tests", "status": "in_progress", "activeForm": "Writing tests"}
        """
        let todo = try JSONDecoder().decode(SessionTodo.self, from: Data(json.utf8))
        #expect(todo.status == .inProgress)
    }

    @Test
    func decodesPendingStatus() throws {
        let json = """
        {"content": "Deploy", "status": "pending", "activeForm": "Deploying"}
        """
        let todo = try JSONDecoder().decode(SessionTodo.self, from: Data(json.utf8))
        #expect(todo.status == .pending)
    }

    @Test
    func decodesArrayOfTodos() throws {
        let json = """
        [
            {"content": "Task A", "status": "completed", "activeForm": "Completing A"},
            {"content": "Task B", "status": "in_progress", "activeForm": "Working on B"},
            {"content": "Task C", "status": "pending", "activeForm": "Starting C"}
        ]
        """
        let todos = try JSONDecoder().decode([SessionTodo].self, from: Data(json.utf8))
        #expect(todos.count == 3)
        #expect(todos[0].status == .completed)
        #expect(todos[1].status == .inProgress)
        #expect(todos[2].status == .pending)
    }

    @Test
    func identifiable_idDerivedFromContent() throws {
        let json = """
        {"content": "Do something", "status": "pending", "activeForm": "Doing something"}
        """
        let todo = try JSONDecoder().decode(SessionTodo.self, from: Data(json.utf8))
        #expect(todo.id == "Do something".hashValue)
    }

    @Test
    func hashable_todosWithSameContentAreEqual() throws {
        let json1 = """
        {"content": "Same task", "status": "completed", "activeForm": "Completing"}
        """
        let json2 = """
        {"content": "Same task", "status": "pending", "activeForm": "Starting"}
        """
        let todo1 = try JSONDecoder().decode(SessionTodo.self, from: Data(json1.utf8))
        let todo2 = try JSONDecoder().decode(SessionTodo.self, from: Data(json2.utf8))
        // Same content means same id, though status differs
        #expect(todo1.id == todo2.id)
    }

    @Test
    func decodesEmptyArray() throws {
        let json = "[]"
        let todos = try JSONDecoder().decode([SessionTodo].self, from: Data(json.utf8))
        #expect(todos.isEmpty)
    }
}
