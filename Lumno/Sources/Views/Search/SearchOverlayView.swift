import SwiftUI

struct SearchOverlayView: View {
    @Environment(AppState.self) private var appState
    @State private var query = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Modal
            VStack(spacing: 0) {
                searchInput
                Divider().opacity(0.3)
                searchResults
            }
            .frame(width: 580)
            .background(
                RoundedRectangle(cornerRadius: LumnoTheme.Radius.lg)
                    .fill(LumnoTheme.Colors.bgCard)
                    .stroke(LumnoTheme.Colors.border)
            )
            .clipShape(RoundedRectangle(cornerRadius: LumnoTheme.Radius.lg))
            .shadow(color: .black.opacity(0.4), radius: 30)
            .padding(.top, 80)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onAppear { isFocused = true }
        .onKeyPress(.escape) {
            dismiss()
            return .handled
        }
    }

    // MARK: - Search Input

    private var searchInput: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(LumnoTheme.Colors.textTertiary)

            TextField("Search sessions, commands, files...", text: $query)
                .textFieldStyle(.plain)
                .font(LumnoTheme.Typography.subheading)
                .foregroundStyle(LumnoTheme.Colors.textPrimary)
                .focused($isFocused)

            Text("ESC")
                .font(LumnoTheme.Typography.tiny)
                .foregroundStyle(LumnoTheme.Colors.textTertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LumnoTheme.Colors.bgElevated)
                )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    // MARK: - Results

    private var searchResults: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                if query.isEmpty {
                    recentSection
                } else {
                    Text("Results will appear here...")
                        .font(LumnoTheme.Typography.caption)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)
                        .padding(LumnoTheme.Spacing.md)
                }
            }
            .padding(LumnoTheme.Spacing.sm)
        }
        .frame(maxHeight: 360)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("RECENT")
                .font(LumnoTheme.Typography.sectionHeader)
                .foregroundStyle(LumnoTheme.Colors.textTertiary)
                .tracking(0.5)
                .padding(.horizontal, 10)
                .padding(.top, 4)

            Text("Search across all sessions, commands, and file changes")
                .font(LumnoTheme.Typography.caption)
                .foregroundStyle(LumnoTheme.Colors.textTertiary)
                .padding(.horizontal, 10)
                .padding(.vertical, LumnoTheme.Spacing.sm)
        }
    }

    private func dismiss() {
        @Bindable var state = appState
        state.isSearchPresented = false
    }
}
