import SwiftUI

struct SessionDetailView: View {
    let session: Session

    var body: some View {
        VStack(spacing: 0) {
            sessionHeader
            messagesList
            StatusBarView(isSessionEnded: true)
        }
        .background(LumnoTheme.Colors.bgApp)
    }

    // MARK: - Header

    private var sessionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(LumnoTheme.Typography.subheading)
                    .foregroundStyle(LumnoTheme.Colors.textPrimary)

                HStack(spacing: LumnoTheme.Spacing.sm) {
                    if let model = session.model {
                        Text(model)
                            .font(LumnoTheme.Typography.tiny)
                            .fontWeight(.semibold)
                            .foregroundStyle(LumnoTheme.Colors.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LumnoTheme.Colors.accentDim)
                            )
                    }

                    Text("\(session.totalTokens.formattedTokens) tokens")
                        .font(LumnoTheme.Typography.tiny)
                        .foregroundStyle(LumnoTheme.Colors.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LumnoTheme.Colors.blue.opacity(0.1))
                        )

                    Text("\(session.timeAgo) · \(session.turnCount) turns")
                        .font(LumnoTheme.Typography.small)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)
                }
            }

            Spacer()

            HStack(spacing: 6) {
                Button {} label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.forward")
                            .font(.system(size: 10))
                        Text("Resume")
                            .font(LumnoTheme.Typography.tiny)
                    }
                    .foregroundStyle(LumnoTheme.Colors.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                            .stroke(LumnoTheme.Colors.border)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, LumnoTheme.Spacing.xxxl)
        .padding(.vertical, LumnoTheme.Spacing.lg)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.3)
        }
    }

    // MARK: - Messages

    private var messagesList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: LumnoTheme.Spacing.xl) {
                ForEach(session.messages) { message in
                    MessageRow(message: message)
                }
            }
            .padding(LumnoTheme.Spacing.xxxl)
        }
    }
}

// MARK: - Message Row

private struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack(alignment: .top, spacing: LumnoTheme.Spacing.md) {
            // Avatar
            Text(message.role == .user ? "Y" : "L")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(message.role == .user ? LumnoTheme.Colors.textSecondary : LumnoTheme.Colors.accent)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(message.role == .user ? LumnoTheme.Colors.bgElevated : LumnoTheme.Colors.accentDim)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: LumnoTheme.Spacing.sm) {
                    Text(message.role == .user ? "You" : "Claude")
                        .font(LumnoTheme.Typography.smallBold)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)

                    Text(message.timestamp, style: .time)
                        .font(LumnoTheme.Typography.tiny)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)
                }

                Text(message.textContent)
                    .font(LumnoTheme.Typography.body)
                    .foregroundStyle(LumnoTheme.Colors.textPrimary)
                    .lineSpacing(4)
                    .textSelection(.enabled)

                ForEach(message.toolBlocks) { tool in
                    ToolBlockView(tool: tool)
                }
            }
        }
        .frame(maxWidth: 820, alignment: .leading)
    }
}

// MARK: - Token Formatting

extension Int {
    var formattedTokens: String {
        let value = Double(self)
        if value >= 1000 {
            return String(format: "%.1fk", value / 1000)
        }
        return "\(self)"
    }
}
