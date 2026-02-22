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
        .background(PoirotTheme.Colors.bgApp)
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
                .font(PoirotTheme.Typography.title)
                .foregroundStyle(PoirotTheme.Colors.textPrimary)

            Text("\(project.sessions.count) \(project.sessions.count == 1 ? "session" : "sessions")")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)

            Spacer()

            layoutToggle
        }
        .padding(.horizontal, PoirotTheme.Spacing.xxl)
        .padding(.top, PoirotTheme.Spacing.xl)
        .padding(.bottom, PoirotTheme.Spacing.lg)
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
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
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
            HStack(alignment: .top, spacing: PoirotTheme.Spacing.lg) {
                ForEach(0 ..< 2, id: \.self) { column in
                    LazyVStack(spacing: PoirotTheme.Spacing.lg) {
                        ForEach(sessionsForColumn(column), id: \.element.id) { index, session in
                            SessionCard(session: session)
                                .shimmerReveal(
                                    isRevealed: isRevealed,
                                    delay: Double(min(index, 7)) * 0.04,
                                    cornerRadius: PoirotTheme.Radius.md
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, PoirotTheme.Spacing.xxl)
            .padding(.top, PoirotTheme.Spacing.lg)
            .padding(.bottom, PoirotTheme.Spacing.xxl)
        }
    }

    private func sessionsForColumn(_ column: Int) -> [(offset: Int, element: Session)] {
        Array(project.sessions.enumerated()).filter { $0.offset % 2 == column }
    }

    // MARK: - List

    private var sessionsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: PoirotTheme.Spacing.md) {
                ForEach(Array(project.sessions.enumerated()), id: \.element.id) { index, session in
                    SessionListRow(session: session)
                        .shimmerReveal(
                            isRevealed: isRevealed,
                            delay: Double(min(index, 9)) * 0.03,
                            cornerRadius: PoirotTheme.Radius.md
                        )
                }
            }
            .padding(.horizontal, PoirotTheme.Spacing.xxl)
            .padding(.top, PoirotTheme.Spacing.lg)
            .padding(.bottom, PoirotTheme.Spacing.xxl)
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
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
                Text(session.title)
                    .font(PoirotTheme.Typography.bodyMedium)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let preview = session.preview {
                    Text(preview)
                        .font(PoirotTheme.Typography.caption)
                        .foregroundStyle(PoirotTheme.Colors.textSecondary)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                }

                SessionBadgeRow(session: session)
                    .padding(.top, PoirotTheme.Spacing.xs)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .cardChrome(isHovered: isHovered, isSelected: isSelected)
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
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
                Text(session.title)
                    .font(PoirotTheme.Typography.bodyMedium)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)
                    .lineLimit(1)

                if let preview = session.preview {
                    Text(preview)
                        .font(PoirotTheme.Typography.caption)
                        .foregroundStyle(PoirotTheme.Colors.textSecondary)
                        .lineLimit(2)
                }

                SessionBadgeRow(session: session)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(PoirotTheme.Spacing.lg)
            .cardChrome(isHovered: isHovered, isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Shared Badge Row

private struct SessionBadgeRow: View {
    let session: Session

    var body: some View {
        HStack(spacing: PoirotTheme.Spacing.sm) {
            if let model = session.model {
                badge(formatModel(model), fg: PoirotTheme.Colors.accent, bg: PoirotTheme.Colors.accentDim)
            }

            if session.totalTokens > 0 {
                badge(
                    "\(formatTokens(session.totalTokens)) tk",
                    fg: PoirotTheme.Colors.blue,
                    bg: PoirotTheme.Colors.blue.opacity(0.15)
                )
            }

            badge(
                "\(session.turnCount) \(session.turnCount == 1 ? "turn" : "turns")",
                fg: PoirotTheme.Colors.textTertiary,
                bg: PoirotTheme.Colors.bgElevated
            )

            Spacer(minLength: 0)

            Text(session.timeAgo)
                .font(PoirotTheme.Typography.tiny)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                .lineLimit(1)
        }
    }

    private func badge(_ text: String, fg: Color, bg: Color) -> some View {
        Text(text)
            .font(PoirotTheme.Typography.tiny)
            .foregroundStyle(fg)
            .padding(.horizontal, PoirotTheme.Spacing.sm)
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
