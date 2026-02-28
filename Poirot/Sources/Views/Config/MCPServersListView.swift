import SwiftUI

struct MCPServersListView: View {
    let item: ConfigurationItem
    @State
    private var servers: [MCPServer] = []
    @State
    private var isRevealed = false
    @State
    private var isLoaded = false
    @State
    private var filterQuery = ""

    @AppStorage("textEditor")
    private var textEditor = PreferredEditor.vscode.rawValue

    @Environment(AppState.self)
    private var appState

    private var editor: PreferredEditor {
        PreferredEditor(rawValue: textEditor) ?? .vscode
    }

    private var filteredServers: [MCPServer] {
        let q = filterQuery.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return servers }
        return servers.filter { server in
            HighlightedText.fuzzyMatch(server.name, query: q) != nil
                || server.tools.contains(where: { HighlightedText.fuzzyMatch($0, query: q) != nil })
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ConfigScreenHeader(
                item: item,
                dynamicCount: "\(servers.count) \(servers.count == 1 ? "server" : "servers")",
                screenID: item.id,
                showLayoutToggle: true,
                showProjectPicker: true
            )

            if !servers.isEmpty {
                ConfigFilterField(searchQuery: $filterQuery)
            }

            if !isLoaded {
                ConfigSkeletonView(
                    layout: appState.configLayout(for: item.id)
                )
            } else if servers.isEmpty {
                ConfigEmptyState(
                    icon: "powerplug",
                    message: "No MCP servers configured",
                    hint: "~/.claude.json"
                )
            } else if filteredServers.isEmpty {
                ConfigEmptyState(
                    icon: "magnifyingglass",
                    message: "No servers match \"\(filterQuery)\"",
                    hint: "Try a different search term"
                )
            } else {
                configContent
            }
        }
        .background(PoirotTheme.Colors.bgApp)
        .task {
            reloadServers()
            if !isLoaded {
                try? await Task.sleep(for: .milliseconds(400))
                withAnimation(.easeOut(duration: 0.35)) {
                    isLoaded = true
                }
            }
            isRevealed = false
            try? await Task.sleep(for: .milliseconds(50))
            withAnimation(.easeOut(duration: 0.4)) {
                isRevealed = true
            }
        }
        .onChange(of: appState.configProjectPath) {
            reloadServers()
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
                            ForEach(serversForColumn(column), id: \.element.id) { index, server in
                                MCPServerCard(
                                    server: server,
                                    onOpenInEditor: { openServerInEditor(server) },
                                    onShowInFinder: { showSettingsInFinder() },
                                    onRemove: { removeServer(server) }
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
                .padding(.horizontal, PoirotTheme.Spacing.xxl)
                .padding(.top, PoirotTheme.Spacing.lg)
                .padding(.bottom, PoirotTheme.Spacing.xxl)
            }
        }
    }

    private func serversForColumn(_ column: Int) -> [(offset: Int, element: MCPServer)] {
        Array(filteredServers.enumerated()).filter { $0.offset % 2 == column }
    }

    private var configList: some View {
        ScrollView {
            VStack(spacing: 0) {
                infoBanner

                LazyVStack(spacing: PoirotTheme.Spacing.md) {
                    ForEach(Array(filteredServers.enumerated()), id: \.element.id) { index, server in
                        MCPServerCard(
                            server: server,
                            onOpenInEditor: { openServerInEditor(server) },
                            onShowInFinder: { showSettingsInFinder() },
                            onRemove: { removeServer(server) }
                        )
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

            Text("Add MCP servers via `claude mcp add` or edit ~/.claude.json directly.")
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

    private func openServerInEditor(_ server: MCPServer) {
        let path = SettingsWriter.claudeConfigFileURL().path
        if let line = SettingsWriter.lineNumber(forMCPServer: server.rawName) {
            EditorLauncher.open(filePath: path, line: line, editor: editor)
        } else {
            EditorLauncher.open(filePath: path, editor: editor)
        }
    }

    private func showSettingsInFinder() {
        let url = SettingsWriter.claudeConfigFileURL()
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    private func removeServer(_ server: MCPServer) {
        Task.detached {
            SettingsWriter.removeMCPServer(serverName: server.rawName)
            SettingsWriter.removeMCPPermissions(serverName: server.rawName)
            await MainActor.run {
                reloadServers()
                appState.showToast("Removed \(server.name)", icon: "trash", style: .info)
            }
        }
    }

    private func reloadServers() {
        servers = ClaudeConfigLoader.loadMCPServers(projectPath: appState.effectiveConfigProjectPath)
    }
}

// MARK: - MCP Server Card

private struct MCPServerCard: View {
    let server: MCPServer
    let onOpenInEditor: () -> Void
    let onShowInFinder: () -> Void
    let onRemove: () -> Void
    @State
    private var isHovered = false
    @State
    private var isExpanded = false
    @State
    private var showDeleteConfirmation = false

    private var transportLabel: String? {
        if let type = server.type {
            return type.uppercased()
        }
        if server.url != nil { return "HTTP" }
        if server.command != nil { return "STDIO" }
        return nil
    }

    private var connectionInfo: String? {
        if let url = server.url { return url }
        if let command = server.command {
            return ([command] + server.args).joined(separator: " ")
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            HStack(spacing: PoirotTheme.Spacing.sm) {
                Circle()
                    .fill(PoirotTheme.Colors.green)
                    .frame(width: 8, height: 8)

                Text(server.name)
                    .font(PoirotTheme.Typography.bodyMedium)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                if let transport = transportLabel {
                    Text(transport)
                        .font(PoirotTheme.Typography.codeSmall)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                                .fill(PoirotTheme.Colors.bgElevated)
                        )
                }

                ConfigScopeBadge(scope: server.scope)

                Spacer()

                Button {
                    onOpenInEditor()
                } label: {
                    Image(systemName: "curlybraces")
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
                .help("Open in editor")

                Button {
                    onShowInFinder()
                } label: {
                    Image(systemName: "folder")
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
                .help("Show in Finder")

                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
                .help("Remove server")
            }

            if let info = connectionInfo {
                Text(info)
                    .font(PoirotTheme.Typography.codeSmall)
                    .foregroundStyle(PoirotTheme.Colors.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            if !server.tools.isEmpty {
                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xs) {
                    let displayTools = isExpanded ? server.tools : Array(server.tools.prefix(5))
                    ForEach(displayTools, id: \.self) { tool in
                        Text(tool)
                            .font(PoirotTheme.Typography.codeSmall)
                            .foregroundStyle(PoirotTheme.Colors.blue)
                            .padding(.horizontal, PoirotTheme.Spacing.sm)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                                    .fill(PoirotTheme.Colors.bgElevated)
                            )
                    }

                    if server.tools.count > 5 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            Text(isExpanded ? "Show less" : "+\(server.tools.count - 5) more")
                                .font(PoirotTheme.Typography.codeSmall)
                                .foregroundStyle(PoirotTheme.Colors.accent)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PoirotTheme.Spacing.lg)
        .cardChrome(isHovered: isHovered)
        .onHover { isHovered = $0 }
        .confirmationDialog(
            "Remove \(server.name)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                onRemove()
            }
        } message: {
            Text(
                // swiftlint:disable:next line_length
                "This will remove the server definition from ~/.claude.json and its tool permissions from settings.json."
            )
        }
    }
}
