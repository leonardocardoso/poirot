@testable import Poirot

final class SessionLoadingMock: SessionLoading, @unchecked Sendable {
    var claudeProjectsPath: String = "/tmp/mock-claude-projects"

    // MARK: - discoverProjects

    var discoverProjectsCallsCount = 0
    var discoverProjectsCalled: Bool { discoverProjectsCallsCount > 0 }
    var discoverProjectsThrowableError: (any Error)?
    var discoverProjectsReturnValue: [Project] = []
    var discoverProjectsClosure: (() throws -> [Project])?

    func discoverProjects() throws -> [Project] {
        discoverProjectsCallsCount += 1
        if let error = discoverProjectsThrowableError { throw error }
        if let closure = discoverProjectsClosure { return try closure() }
        return discoverProjectsReturnValue
    }
}
