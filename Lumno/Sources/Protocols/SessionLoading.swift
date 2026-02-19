import SwiftMockKit

@Mockable
protocol SessionLoading: Sendable {
    func discoverProjects() throws -> [Project]
}
