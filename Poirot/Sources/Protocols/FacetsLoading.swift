protocol FacetsLoading: Sendable {
    var claudeFacetsPath: String { get }
    func loadFacets(for sessionId: String) -> SessionFacets?
}
