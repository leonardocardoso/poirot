import SwiftUI

struct ProjectSessionsView: View {
    let project: Project
    @Environment(AppState.self)
    private var appState

    private let columns = [
        GridItem(.flexible(), spacing: LumnoTheme.Spacing.lg),
        GridItem(.flexible(), spacing: LumnoTheme.Spacing.lg),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            sessionsGrid
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
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // MARK: - Sessions Grid

    private var sessionsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: LumnoTheme.Spacing.lg) {
                ForEach(project.sessions) { session in
                    SessionCard(session: session)
                }
            }
            .padding(.horizontal, LumnoTheme.Spacing.xxl)
            .padding(.top, LumnoTheme.Spacing.lg)
            .padding(.bottom, LumnoTheme.Spacing.xxl)
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

    private var isSelected: Bool {
        appState.selectedSession == session
    }

    var body: some View {
        Button {
            appState.selectedSession = session
        } label: {
            VStack(alignment: .leading, spacing: LumnoTheme.Spacing.sm) {
                Text(session.title)
                    .font(LumnoTheme.Typography.bodyMedium)
                    .foregroundStyle(LumnoTheme.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let preview = session.preview {
                    Text(preview)
                        .font(LumnoTheme.Typography.caption)
                        .foregroundStyle(LumnoTheme.Colors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                footer
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: LumnoTheme.Radius.md)
                    .fill(isHovered ? LumnoTheme.Colors.bgCardHover : LumnoTheme.Colors.bgCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: LumnoTheme.Radius.md)
                    .strokeBorder(
                        isSelected
                            ? LumnoTheme.Colors.accent
                            : isHovered
                                ? Color.white.opacity(0.1)
                                : LumnoTheme.Colors.border,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: LumnoTheme.Spacing.sm) {
            if let model = session.model {
                badge(formatModel(model), fg: LumnoTheme.Colors.accent, bg: LumnoTheme.Colors.accentDim)
            }

            if session.totalTokens > 0 {
                badge(
                    "\(formatTokens(session.totalTokens)) tk",
                    fg: LumnoTheme.Colors.blue,
                    bg: LumnoTheme.Colors.blue.opacity(0.15)
                )
            }

            Spacer(minLength: 0)

            Text("\(session.timeAgo) · \(session.turnCount) turns")
                .font(LumnoTheme.Typography.tiny)
                .foregroundStyle(LumnoTheme.Colors.textTertiary)
                .lineLimit(1)
        }
    }

    // MARK: - Badge

    private func badge(_ text: String, fg: Color, bg: Color) -> some View {
        Text(text)
            .font(LumnoTheme.Typography.tiny)
            .foregroundStyle(fg)
            .padding(.horizontal, LumnoTheme.Spacing.sm)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(bg)
            )
    }

    // MARK: - Formatters

    private func formatTokens(_ count: Int) -> String {
        if count >= 1000 {
            let k = Double(count) / 1000.0
            return k.truncatingRemainder(dividingBy: 1) == 0
                ? "\(Int(k))k"
                : String(format: "%.1fk", k)
        }
        return "\(count)"
    }

    private func formatModel(_ model: String) -> String {
        let name = model.replacingOccurrences(of: "claude-", with: "")

        if name.hasPrefix("opus-") {
            let version = name.dropFirst("opus-".count).prefix(while: { $0 != "-" && $0 != "_" })
            return "Opus \(version.replacingOccurrences(of: "-", with: "."))"
        } else if name.hasPrefix("sonnet-") {
            let version = name.dropFirst("sonnet-".count).prefix(while: { $0 != "-" && $0 != "_" })
            return "Sonnet \(version.replacingOccurrences(of: "-", with: "."))"
        } else if name.hasPrefix("haiku-") {
            let version = name.dropFirst("haiku-".count).prefix(while: { $0 != "-" && $0 != "_" })
            return "Haiku \(version.replacingOccurrences(of: "-", with: "."))"
        }

        return model
    }
}
