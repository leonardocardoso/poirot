import SwiftUI

struct SubAgentsListView: View {
    let item: ConfigurationItem
    @State
    private var isRevealed = false
    @State
    private var filterQuery = ""

    @Environment(AppState.self)
    private var appState

    private var filteredAgents: [SubAgent] {
        let q = filterQuery.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return SubAgent.builtIn }
        return SubAgent.builtIn.filter { agent in
            HighlightedText.fuzzyMatch(agent.name, query: q) != nil
                || HighlightedText.fuzzyMatch(agent.description, query: q) != nil
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ConfigScreenHeader(
                item: item,
                dynamicCount: "\(SubAgent.builtIn.count) \(SubAgent.builtIn.count == 1 ? "agent" : "agents")",
                screenID: item.id,
                showLayoutToggle: true
            )

            if !SubAgent.builtIn.isEmpty {
                ConfigFilterField(searchQuery: $filterQuery)
            }

            if filteredAgents.isEmpty, !filterQuery.isEmpty {
                ConfigEmptyState(
                    icon: "magnifyingglass",
                    message: "No agents match \"\(filterQuery)\"",
                    hint: "Try a different search term"
                )
            } else {
                configContent
            }
        }
        .background(PoirotTheme.Colors.bgApp)
        .task {
            isRevealed = false
            try? await Task.sleep(for: .milliseconds(50))
            withAnimation(.easeOut(duration: 0.4)) {
                isRevealed = true
            }
        }
    }

    @ViewBuilder
    private var configContent: some View {
        if appState.configLayout(for: item.id) == .grid {
            configGrid
        } else {
            configList
        }
    }

    private var configGrid: some View {
        ScrollView {
            VStack(spacing: 0) {
                infoBanner

                HStack(alignment: .top, spacing: PoirotTheme.Spacing.lg) {
                    ForEach(0 ..< 2, id: \.self) { column in
                        LazyVStack(spacing: PoirotTheme.Spacing.lg) {
                            ForEach(agentsForColumn(column), id: \.element.id) { index, agent in
                                SubAgentCard(agent: agent)
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
    }

    private func agentsForColumn(_ column: Int) -> [(offset: Int, element: SubAgent)] {
        Array(filteredAgents.enumerated()).filter { $0.offset % 2 == column }
    }

    private var configList: some View {
        ScrollView {
            VStack(spacing: 0) {
                infoBanner

                LazyVStack(spacing: PoirotTheme.Spacing.md) {
                    ForEach(Array(filteredAgents.enumerated()), id: \.element.id) { index, agent in
                        SubAgentCard(agent: agent)
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

    private var infoBanner: some View {
        HStack(spacing: PoirotTheme.Spacing.sm) {
            Image(systemName: "info.circle")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.blue)

            Text("Sub-agents are built-in to Claude Code. Create Commands or Skills for custom agent configurations.")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PoirotTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .fill(PoirotTheme.Colors.blue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                        .strokeBorder(PoirotTheme.Colors.blue.opacity(0.1))
                )
        )
        .padding(.horizontal, PoirotTheme.Spacing.xxl)
        .padding(.top, PoirotTheme.Spacing.lg)
        .padding(.bottom, PoirotTheme.Spacing.sm)
    }
}

// MARK: - Sub-agent Card

private struct SubAgentCard: View {
    let agent: SubAgent

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            HStack(spacing: PoirotTheme.Spacing.sm) {
                Image(systemName: agent.icon)
                    .font(PoirotTheme.Typography.body)
                    .foregroundStyle(PoirotTheme.Colors.orange)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                            .fill(PoirotTheme.Colors.orange.opacity(0.15))
                    )

                Text(agent.name)
                    .font(PoirotTheme.Typography.bodyMedium)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)
            }

            Text(agent.description)
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: PoirotTheme.Spacing.xs) {
                ForEach(agent.tools, id: \.self) { tool in
                    Text(tool)
                        .font(PoirotTheme.Typography.codeSmall)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .padding(.horizontal, PoirotTheme.Spacing.sm)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                                .fill(PoirotTheme.Colors.bgElevated)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PoirotTheme.Spacing.lg)
        .cardChrome(isHovered: false)
    }
}
