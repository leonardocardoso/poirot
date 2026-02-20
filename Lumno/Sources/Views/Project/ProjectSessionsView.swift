import SwiftUI

struct ProjectSessionsView: View {
    let project: Project
    @Environment(AppState.self)
    private var appState
    @State
    private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            sessionsContent
        }
        .background(LumnoTheme.Colors.bgApp)
        .task(id: project.id) {
            isRevealed = false
            try? await Task.sleep(for: .milliseconds(50))
            withAnimation(.easeOut(duration: 0.4)) {
                isRevealed = true
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(project.name)
                .font(LumnoTheme.Typography.title)
                .foregroundStyle(LumnoTheme.Colors.textPrimary)

            Text("\(project.sessions.count) \(project.sessions.count == 1 ? "session" : "sessions")")
                .font(LumnoTheme.Typography.caption)
                .foregroundStyle(LumnoTheme.Colors.textTertiary)

            Spacer()

            layoutToggle
        }
        .padding(.horizontal, LumnoTheme.Spacing.xxl)
        .padding(.top, LumnoTheme.Spacing.xl)
        .padding(.bottom, LumnoTheme.Spacing.lg)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var layoutToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                appState.sessionLayout = appState.sessionLayout == .grid ? .list : .grid
            }
        } label: {
            Image(systemName: appState.sessionLayout == .grid ? "list.bullet" : "square.grid.2x2")
                .font(.system(size: 13))
                .foregroundStyle(LumnoTheme.Colors.textSecondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sessions Content

    @ViewBuilder
    private var sessionsContent: some View {
        if appState.sessionLayout == .grid {
            sessionsGrid
        } else {
            sessionsList
        }
    }

    // MARK: - Grid (Masonry)

    private var sessionsGrid: some View {
        ScrollView {
            HStack(alignment: .top, spacing: LumnoTheme.Spacing.lg) {
                ForEach(0 ..< 2, id: \.self) { column in
                    LazyVStack(spacing: LumnoTheme.Spacing.lg) {
                        ForEach(sessionsForColumn(column), id: \.element.id) { index, session in
                            SessionCard(session: session)
                                .shimmerReveal(
                                    isRevealed: isRevealed,
                                    delay: Double(min(index, 7)) * 0.04,
                                    cornerRadius: LumnoTheme.Radius.md
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, LumnoTheme.Spacing.xxl)
            .padding(.top, LumnoTheme.Spacing.lg)
            .padding(.bottom, LumnoTheme.Spacing.xxl)
        }
    }

    private func sessionsForColumn(_ column: Int) -> [(offset: Int, element: Session)] {
        Array(project.sessions.enumerated()).filter { $0.offset % 2 == column }
    }

    // MARK: - List

    private var sessionsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: LumnoTheme.Spacing.md) {
                ForEach(Array(project.sessions.enumerated()), id: \.element.id) { index, session in
                    SessionListRow(session: session)
                        .shimmerReveal(
                            isRevealed: isRevealed,
                            delay: Double(min(index, 9)) * 0.03,
                            cornerRadius: LumnoTheme.Radius.md
                        )
                }
            }
            .padding(.horizontal, LumnoTheme.Spacing.xxl)
            .padding(.top, LumnoTheme.Spacing.lg)
            .padding(.bottom, LumnoTheme.Spacing.xxl)
        }
    }
}

// MARK: - Session Card (Grid)

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
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                }

                SessionBadgeRow(session: session)
                    .padding(.top, LumnoTheme.Spacing.xs)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .sessionCardChrome(isHovered: isHovered, isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Session List Row

private struct SessionListRow: View {
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
                    .lineLimit(1)

                if let preview = session.preview {
                    Text(preview)
                        .font(LumnoTheme.Typography.caption)
                        .foregroundStyle(LumnoTheme.Colors.textSecondary)
                        .lineLimit(2)
                }

                SessionBadgeRow(session: session)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(LumnoTheme.Spacing.lg)
            .sessionCardChrome(isHovered: isHovered, isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Shared Badge Row

private struct SessionBadgeRow: View {
    let session: Session

    var body: some View {
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

            badge(
                "\(session.turnCount) \(session.turnCount == 1 ? "turn" : "turns")",
                fg: LumnoTheme.Colors.textTertiary,
                bg: LumnoTheme.Colors.bgElevated
            )

            Spacer(minLength: 0)

            Text(session.timeAgo)
                .font(LumnoTheme.Typography.tiny)
                .foregroundStyle(LumnoTheme.Colors.textTertiary)
                .lineLimit(1)
        }
    }

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

// MARK: - Card Chrome

private extension View {
    func sessionCardChrome(isHovered: Bool, isSelected: Bool) -> some View {
        self
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
}
