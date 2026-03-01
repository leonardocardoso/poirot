import SwiftUI

struct ConfigLayoutToolbar: ToolbarContent {
    let screenID: String
    @Binding
    var filterQuery: String
    var placeholder: String = "Filter\u{2026}"
    var showProjectPicker: Bool = false
    var showAddButton: Bool = false

    @Environment(AppState.self)
    private var appState

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if showProjectPicker {
                ConfigProjectPicker()
                    .frame(width: 260)
            } else {
                Spacer()
            }
        }
        ToolbarItemGroup(placement: .primaryAction) {
            ConfigFilterField(searchQuery: $filterQuery, placeholder: placeholder)
                .frame(width: 200)

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    appState.toggleConfigLayout(for: screenID)
                }
            } label: {
                Image(systemName: appState.configLayout(for: screenID) == .grid ? "list.bullet" : "square.grid.2x2")
                    .frame(width: 16, height: 16)
                    .contentTransition(.symbolEffect(.replace))
            }
            .help("Toggle layout")

            if showAddButton {
                Button {
                    appState.configAddTrigger = UUID()
                } label: {
                    Image(systemName: "plus")
                }
                .help("Create New")
            }
        }
    }
}
