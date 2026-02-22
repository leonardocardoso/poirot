protocol SessionLoading: Sendable {
    var claudeProjectsPath: String { get }
    func discoverProjects() throws -> [Project]
}
