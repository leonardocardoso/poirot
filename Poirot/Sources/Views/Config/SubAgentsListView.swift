import SwiftUI
import UniformTypeIdentifiers

struct SubAgentsListView: View {
    let item: ConfigurationItem

    @State
    private var isRevealed = false
    @State
    private var filterQuery = ""
    @State
    private var customAgents: [SubAgent] = []
    @State
    private var showCreateSheet = false
    @State
    private var editingAgent: SubAgent?
    @State
    private var fileWatcher = FileWatcher { }

    @Environment(AppState.self)
    private var appState

    private var allAgents: [SubAgent] {
        SubAgent.builtIn + customAgents
    }

    private var filteredAgents: [SubAgent] {
        let q = filterQuery.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return allAgents }
        return allAgents
            .compactMap { agent -> (SubAgent, Int)? in
                let best = max(
                    HighlightedText.fuzzyMatch(agent.name, query: q)?.score ?? 0,
                    HighlightedText.fuzzyMatch(agent.description, query: q)?.score ?? 0
                )
                return best > 0 ? (agent, best) : nil
            }
            .sorted { $0.1 > $1.1 }
            .map(\.0)
    }

    private var filteredBuiltIn: [SubAgent] {
        filteredAgents.filter(\.isBuiltIn)
    }

    private var filteredCustom: [SubAgent] {
        filteredAgents.filter { !$0.isBuiltIn }
    }

    var body: some View {
        VStack(spacing: 0) {
            ConfigScreenHeader(
                item: item,
                dynamicCount: "\(allAgents.count) \(allAgents.count == 1 ? "agent" : "agents")"
            )

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
        .toolbar {
            ConfigLayoutToolbar(
                screenID: item.id,
                filterQuery: $filterQuery,
                placeholder: "Find in Sub-Agents\u{2026}",
                showAddButton: true
            )

            ToolbarItem(placement: .primaryAction) {
                Button {
                    importAgentFromJSON()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .help("Import Agent from JSON")
            }
        }
        .onChange(of: appState.configAddTrigger) {
            showCreateSheet = true
        }
        .task {
            reloadCustomAgents()
            isRevealed = false
            try? await Task.sleep(for: .milliseconds(50))
            withAnimation(.easeOut(duration: 0.4)) {
                isRevealed = true
            }
        }
        .onAppear {
            fileWatcher = FileWatcher {
                reloadCustomAgents()
            }
            let dir = ClaudeConfigLoader.agentsDir
            try? FileManager.default.createDirectory(
                at: dir,
                withIntermediateDirectories: true
            )
            fileWatcher.start(path: dir.path)
        }
        .onDisappear {
            fileWatcher.stop()
        }
        .sheet(isPresented: $showCreateSheet) {
            SubAgentFormView { agent in
                saveAndReload(agent)
            }
        }
        .sheet(item: $editingAgent) { agent in
            SubAgentFormView(existingAgent: agent) { updated in
                saveAndReload(updated)
            }
        }
    }

    // MARK: - Content

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
            VStack(spacing: PoirotTheme.Spacing.lg) {
                if !filteredBuiltIn.isEmpty {
                    agentSection(title: "Built-in", agents: filteredBuiltIn)
                }
                if !filteredCustom.isEmpty {
                    agentSection(title: "Custom", agents: filteredCustom)
                }
            }
            .padding(.horizontal, PoirotTheme.Spacing.xxxl)
            .padding(.top, PoirotTheme.Spacing.lg)
            .padding(.bottom, PoirotTheme.Spacing.xxl)
        }
        .scrollIndicators(.never)
    }

    private var configList: some View {
        ScrollView {
            VStack(spacing: PoirotTheme.Spacing.lg) {
                if !filteredBuiltIn.isEmpty {
                    agentListSection(title: "Built-in", agents: filteredBuiltIn)
                }
                if !filteredCustom.isEmpty {
                    agentListSection(title: "Custom", agents: filteredCustom)
                }
            }
            .padding(.horizontal, PoirotTheme.Spacing.xxxl)
            .padding(.top, PoirotTheme.Spacing.lg)
            .padding(.bottom, PoirotTheme.Spacing.xxl)
        }
        .scrollIndicators(.never)
    }

    private func agentSection(title: String, agents: [SubAgent]) -> some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            sectionLabel(title)

            HStack(alignment: .top, spacing: PoirotTheme.Spacing.lg) {
                ForEach(0 ..< 2, id: \.self) { column in
                    LazyVStack(spacing: PoirotTheme.Spacing.lg) {
                        ForEach(
                            agentsForColumn(agents, column: column),
                            id: \.element.id
                        ) { index, agent in
                            SubAgentCard(
                                agent: agent,
                                filterQuery: filterQuery,
                                onEdit: { editingAgent = agent },
                                onDuplicate: { duplicateAgent(agent) },
                                onExport: { exportAgentAsJSON(agent) },
                                onDelete: { deleteAgent(agent) }
                            )
                            .shimmerReveal(
                                isRevealed: isRevealed,
                                delay: Double(min(index, 7)) * 0.04,
                                cornerRadius: PoirotTheme.Radius.md
                            )
                        }
                    }
                }
            }
        }
    }

    private func agentListSection(title: String, agents: [SubAgent]) -> some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            sectionLabel(title)

            LazyVStack(spacing: PoirotTheme.Spacing.md) {
                ForEach(Array(agents.enumerated()), id: \.element.id) { index, agent in
                    SubAgentCard(
                        agent: agent,
                        filterQuery: filterQuery,
                        onEdit: { editingAgent = agent },
                        onDuplicate: { duplicateAgent(agent) },
                        onExport: { exportAgentAsJSON(agent) },
                        onDelete: { deleteAgent(agent) }
                    )
                    .shimmerReveal(
                        isRevealed: isRevealed,
                        delay: Double(min(index, 9)) * 0.03,
                        cornerRadius: PoirotTheme.Radius.md
                    )
                }
            }
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(PoirotTheme.Typography.sectionHeader)
            .foregroundStyle(PoirotTheme.Colors.textTertiary)
            .padding(.leading, PoirotTheme.Spacing.xs)
    }

    private func agentsForColumn(_ agents: [SubAgent], column: Int) -> [(offset: Int, element: SubAgent)] {
        Array(agents.enumerated()).filter { $0.offset % 2 == column }
    }

    // MARK: - Actions

    private func reloadCustomAgents() {
        customAgents = ClaudeConfigLoader.loadCustomAgents()
        appState.sidebarCounts[NavigationItem.subAgents.id] = allAgents.count
    }

    private func saveAndReload(_ agent: SubAgent) {
        if let path = ClaudeConfigLoader.saveAgent(agent) {
            reloadCustomAgents()
            let verb = agent.filePath != nil ? "Updated" : "Created"
            appState.showToast("\(verb) \(agent.name)", icon: "checkmark.circle.fill")
            _ = path
        }
    }

    private func deleteAgent(_ agent: SubAgent) {
        guard let path = agent.filePath else { return }
        _ = ClaudeConfigLoader.deleteConfigFile(at: path)
        reloadCustomAgents()
        appState.showToast("Deleted \(agent.name)", icon: "trash", style: .info)
    }

    private func duplicateAgent(_ agent: SubAgent) {
        let duplicate = SubAgent(
            id: UUID().uuidString,
            name: "\(agent.name) Copy",
            icon: "person.crop.circle.badge.plus",
            description: agent.description,
            tools: agent.tools,
            model: agent.model,
            color: agent.color,
            prompt: agent.prompt,
            memory: agent.memory,
            scope: .global
        )
        saveAndReload(duplicate)
    }

    private func exportAgentAsJSON(_ agent: SubAgent) {
        guard let data = ClaudeConfigLoader.exportAgentAsJSON(agent) else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.json]
        let safeName = agent.name
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
        panel.nameFieldStringValue = "\(safeName).json"
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        try? data.write(to: url, options: .atomic)
        appState.showToast("Exported \(agent.name)")
    }

    private func importAgentFromJSON() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.json]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url,
              let data = try? Data(contentsOf: url)
        else { return }

        if let path = ClaudeConfigLoader.importAgentFromJSON(data) {
            reloadCustomAgents()
            appState.showToast("Imported agent", icon: "square.and.arrow.down.fill")
            _ = path
        } else {
            appState.showToast("Invalid agent JSON")
        }
    }
}

// MARK: - Sub-agent Card

private struct SubAgentCard: View {
    let agent: SubAgent
    var filterQuery: String = ""
    var onEdit: (() -> Void)?
    var onDuplicate: (() -> Void)?
    var onExport: (() -> Void)?
    var onDelete: (() -> Void)?

    @State
    private var isHovered = false
    @State
    private var showDeleteConfirmation = false

    private var iconColor: Color {
        guard let color = agent.color else { return PoirotTheme.Colors.orange }
        switch color {
        case .orange: return PoirotTheme.Colors.orange
        case .red: return PoirotTheme.Colors.red
        case .blue: return PoirotTheme.Colors.blue
        case .green: return PoirotTheme.Colors.green
        case .purple: return PoirotTheme.Colors.purple
        case .teal: return PoirotTheme.Colors.teal
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            HStack(spacing: PoirotTheme.Spacing.sm) {
                Image(systemName: agent.icon)
                    .font(PoirotTheme.Typography.body)
                    .foregroundStyle(iconColor)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                            .fill(iconColor.opacity(0.15))
                    )

                Text(HighlightedText.fuzzyAttributedString(agent.name, query: filterQuery))
                    .font(PoirotTheme.Typography.bodyMedium)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                if let model = agent.model, !model.isEmpty {
                    Text(model)
                        .font(PoirotTheme.Typography.micro)
                        .foregroundStyle(PoirotTheme.Colors.orange)
                        .padding(.horizontal, PoirotTheme.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                                .fill(PoirotTheme.Colors.orange.opacity(0.15))
                        )
                }

                Spacer()

                if !agent.isBuiltIn {
                    Button { onDuplicate?() } label: {
                        Image(systemName: "doc.on.doc")
                            .font(PoirotTheme.Typography.tiny)
                            .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .help("Duplicate")

                    Button { onExport?() } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(PoirotTheme.Typography.tiny)
                            .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .help("Export as JSON")

                    Button { showDeleteConfirmation = true } label: {
                        Image(systemName: "trash")
                            .font(PoirotTheme.Typography.tiny)
                            .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .help("Delete agent")
                } else {
                    Button { onDuplicate?() } label: {
                        Image(systemName: "doc.on.doc")
                            .font(PoirotTheme.Typography.tiny)
                            .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .help("Duplicate")

                    Button { onExport?() } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(PoirotTheme.Typography.tiny)
                            .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .help("Export as JSON")
                }
            }

            Text(HighlightedText.fuzzyAttributedString(agent.description, query: filterQuery))
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            FlowLayout(spacing: PoirotTheme.Spacing.xs) {
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
        .cardChrome(isHovered: isHovered)
        .onHover { isHovered = $0 }
        .contentShape(Rectangle())
        .onTapGesture {
            if !agent.isBuiltIn { onEdit?() }
        }
        .contextMenu { contextMenuItems }
        .confirmationDialog(
            "Delete \(agent.name)?",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) { onDelete?() }
        } message: {
            Text("This will permanently delete the agent file.")
        }
    }

    @ViewBuilder
    private var contextMenuItems: some View {
        if !agent.isBuiltIn {
            Button("Edit\u{2026}") { onEdit?() }
        }

        Button("Duplicate") { onDuplicate?() }
        Button("Export as JSON\u{2026}") { onExport?() }

        if !agent.isBuiltIn {
            Divider()
            Button("Delete\u{2026}", role: .destructive) { showDeleteConfirmation = true }
        }
    }
}
