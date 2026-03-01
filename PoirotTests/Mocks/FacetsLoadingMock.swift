@testable import Poirot

final class FacetsLoadingMock: FacetsLoading, @unchecked Sendable {
    var claudeFacetsPath: String = "/tmp/mock-claude-facets"

    // MARK: - loadFacets

    var loadFacetsCallsCount = 0
    var loadFacetsCalled: Bool { loadFacetsCallsCount > 0 }
    var loadFacetsReceivedSessionId: String?
    var loadFacetsReturnValue: SessionFacets?
    var loadFacetsClosure: ((String) -> SessionFacets?)?

    func loadFacets(for sessionId: String) -> SessionFacets? {
        loadFacetsCallsCount += 1
        loadFacetsReceivedSessionId = sessionId
        if let closure = loadFacetsClosure { return closure(sessionId) }
        return loadFacetsReturnValue
    }
}
