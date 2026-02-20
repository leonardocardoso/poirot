import SwiftUI

struct ProjectSessionsView: View {
    let project: Project
    @Environment(AppState.self)
    private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            sessionsList
            Spacer(minLength: 0)
        }
        .background(LumnoTheme.Colors.bgApp)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(project.name)
                .font(LumnoTheme.Typography.title)
                .foregroundStyle(LumnoTheme.Colors.textPrimary)

            Text("\(project.sessions.count) sessions")
                .font(LumnoTheme.Typography.caption)
                .foregroundStyle(LumnoTheme.Colors.textTertiary)

            Spacer()
        }
        .padding(.horizontal, LumnoTheme.Spacing.xxl)
        .padding(.top, LumnoTheme.Spacing.xl)
        .padding(.bottom, LumnoTheme.Spacing.lg)
    }

    // MARK: - Sessions List

    private var sessionsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(project.sessions) { session in
                    SessionCard(session: session)
                }
            }
            .padding(.horizontal, LumnoTheme.Spacing.xxl)
        }
    }
}

// MARK: - Session Card

private struct SessionCard: View {
    let session: Session
    @Environment(AppState.self)
    private var appState
    @State
    private var isHovered = false

    var body: some View {
        Button {
            appState.selectedSession = session
        } label: {
            VStack(alignment: .leading, spacing: LumnoTheme.Spacing.sm) {
                Text(session.title)
                    .font(LumnoTheme.Typography.bodyMedium)
                    .foregroundStyle(LumnoTheme.Colors.textPrimary)
                    .lineLimit(2)

                if let preview = session.preview {
                    Text(preview)
                        .font(LumnoTheme.Typography.caption)
                        .foregroundStyle(LumnoTheme.Colors.textSecondary)
                        .lineLimit(2)
                }

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(session.timeAgo)
                        .font(LumnoTheme.Typography.tiny)
                }
                .foregroundStyle(LumnoTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, LumnoTheme.Spacing.lg)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                .fill(isHovered ? LumnoTheme.Colors.bgCardHover : .clear)
                .padding(.horizontal, -LumnoTheme.Spacing.md)
                .padding(.vertical, -LumnoTheme.Spacing.sm)
        )
        .onHover { isHovered = $0 }
        .overlay(alignment: .bottom) {
            Divider()
                .foregroundStyle(LumnoTheme.Colors.border)
        }
    }
}
