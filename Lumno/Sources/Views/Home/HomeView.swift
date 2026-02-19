import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            heroSection
            Spacer()
            inputBar
            statusBar
        }
        .background(LumnoTheme.Colors.bgApp)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: LumnoTheme.Spacing.sm) {
            // Logo
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [LumnoTheme.Colors.accent, Color(hex: 0xD4872A)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 64)
                .overlay {
                    Text("L")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(LumnoTheme.Colors.bgApp)
                }
                .shadow(color: LumnoTheme.Colors.accent.opacity(0.3), radius: 20)
                .padding(.bottom, LumnoTheme.Spacing.md)

            Text("Your Claude Code companion")
                .font(LumnoTheme.Typography.title)
                .foregroundStyle(LumnoTheme.Colors.textPrimary)

            Text("Browse sessions, explore diffs, re-run commands")
                .font(LumnoTheme.Typography.subheading)
                .foregroundStyle(LumnoTheme.Colors.textSecondary)

            // Project selector
            Button {
                // TODO: Show project picker
            } label: {
                HStack(spacing: 6) {
                    Text("All Projects")
                        .font(LumnoTheme.Typography.body)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(LumnoTheme.Colors.textSecondary)
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                        .fill(.clear)
                )
            }
            .buttonStyle(.plain)
            .padding(.bottom, LumnoTheme.Spacing.xxl)

            // Suggestion cards
            HStack(spacing: LumnoTheme.Spacing.md) {
                SuggestionCard(
                    icon: "clock",
                    iconColor: LumnoTheme.Colors.blue,
                    text: "Browse your latest coding sessions across all projects"
                )

                SuggestionCard(
                    icon: "magnifyingglass",
                    iconColor: LumnoTheme.Colors.accent,
                    text: "Search across all conversations, commands, and file changes"
                )

                SuggestionCard(
                    icon: "gearshape",
                    iconColor: LumnoTheme.Colors.green,
                    text: "Manage your skills, MCPs, and slash commands"
                )
            }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 10) {
            TextField("Search sessions, run commands, or ask anything...   ⌘K", text: .constant(""))
                .textFieldStyle(.plain)
                .font(LumnoTheme.Typography.body)
                .foregroundStyle(LumnoTheme.Colors.textPrimary)

            HStack {
                HStack(spacing: 4) {
                    TagButton(label: "Opus 4", icon: "sparkle", isAccent: true)
                    TagButton(label: "Attach", icon: "plus")
                    TagButton(label: "Commands", icon: "slash.circle")
                }

                Spacer()

                HStack(spacing: 6) {
                    Button {} label: {
                        Image(systemName: "mic")
                            .font(.system(size: 12))
                            .foregroundStyle(LumnoTheme.Colors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(Circle().stroke(LumnoTheme.Colors.border))
                    }
                    .buttonStyle(.plain)

                    Button {} label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(LumnoTheme.Colors.bgApp)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(LumnoTheme.Colors.accent))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: LumnoTheme.Radius.lg)
                .fill(LumnoTheme.Colors.bgCard)
                .stroke(LumnoTheme.Colors.border)
        )
        .padding(.horizontal, LumnoTheme.Spacing.xxl)
        .padding(.bottom, LumnoTheme.Spacing.xl)
    }

    // MARK: - Status Bar

    private var statusBar: some View {
        StatusBarView()
    }
}

// MARK: - Suggestion Card

private struct SuggestionCard: View {
    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: LumnoTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(iconColor.opacity(0.15))
                )

            Text(text)
                .font(LumnoTheme.Typography.caption)
                .foregroundStyle(LumnoTheme.Colors.textSecondary)
                .lineLimit(3)
        }
        .frame(width: 210, alignment: .leading)
        .padding(LumnoTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: LumnoTheme.Radius.md)
                .fill(LumnoTheme.Colors.bgCard)
                .stroke(LumnoTheme.Colors.border)
        )
    }
}

// MARK: - Tag Button

private struct TagButton: View {
    let label: String
    let icon: String
    var isAccent: Bool = false

    var body: some View {
        Button {} label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(label)
                    .font(LumnoTheme.Typography.small)
            }
            .foregroundStyle(isAccent ? LumnoTheme.Colors.accent : LumnoTheme.Colors.textSecondary)
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isAccent ? LumnoTheme.Colors.accentDim : .clear)
                    .stroke(isAccent ? LumnoTheme.Colors.accent.opacity(0.2) : LumnoTheme.Colors.border)
            )
        }
        .buttonStyle(.plain)
    }
}
