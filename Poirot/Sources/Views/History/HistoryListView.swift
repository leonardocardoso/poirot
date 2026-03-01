import SwiftUI

struct HistoryListView: View {
    @Environment(AppState.self)
    private var appState

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @State
    private var entries: [HistoryEntry] = []

    @State
    private var isLoaded = false

    @State
    private var isRevealed = false

    @State
    private var filterQuery = ""

    @State
    private var selectedProject: String?

    @State
    private var selectedEntry: HistoryEntry?

    @State
    private var fileWatcher: FileWatcher?

    private static let screenID = NavigationItem.history.id
    private static let pageSize = 30

    @State
    private var visibleCount: Int = HistoryListView.pageSize

    // MARK: - Computed

    private var allProjects: [String] {
        var seen = Set<String>()
        var projects: [String] = []
        for entry in entries where seen.insert(entry.project).inserted {
            projects.append(entry.project)
        }
        return projects
    }

    private var filteredEntries: [HistoryEntry] {
        var result = entries

        // Filter by project
        if let project = selectedProject {
            result = result.filter { $0.project == project }
        }

        // Filter by search query
        let q = filterQuery.trimmingCharacters(in: .whitespaces)
        if !q.isEmpty {
            result = result
                .compactMap { entry -> (HistoryEntry, Int)? in
                    let displayScore = HighlightedText.fuzzyMatch(entry.display, query: q)?.score ?? 0
                    let projectScore = HighlightedText.fuzzyMatch(entry.projectName, query: q)?.score ?? 0
                    let best = max(displayScore, projectScore)
                    return best > 0 ? (entry, best) : nil
                }
                .sorted { $0.1 > $1.1 }
                .map(\.0)
        }

        return result
    }

    private var groupedEntries: [(group: HistoryDateGroup, entries: [HistoryEntry])] {
        let visible = Array(filteredEntries.prefix(visibleCount))
        let grouped = Dictionary(grouping: visible) { HistoryDateGroup.group(for: $0.timestamp) }

        return HistoryDateGroup.allCases.compactMap { group in
            guard let items = grouped[group], !items.isEmpty else { return nil }
            return (group: group, entries: items)
        }
    }

    private var countText: String {
        let total = entries.count
        let filtered = filteredEntries.count
        if selectedProject != nil || !filterQuery.isEmpty {
            return "\(filtered) of \(total) \(total == 1 ? "prompt" : "prompts")"
        }
        return "\(total) \(total == 1 ? "prompt" : "prompts")"
    }

    // MARK: - Body

    var body: some View {
        Group {
            if let entry = selectedEntry {
                HistoryDetailView(
                    entry: entry,
                    filterQuery: filterQuery,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedEntry = nil
                        }
                    },
                    onCopy: { copyPrompt(entry) }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                listContent
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
    }

    // MARK: - List Content

    private var listContent: some View {
        VStack(spacing: 0) {
            header

            if !isLoaded {
                ConfigSkeletonView(layout: appState.configLayout(for: Self.screenID))
            } else if entries.isEmpty {
                ConfigEmptyState(
                    icon: "clock.arrow.circlepath",
                    message: "No history found",
                    hint: "~/.claude/history.jsonl"
                )
            } else if filteredEntries.isEmpty {
                ConfigEmptyState(
                    icon: "magnifyingglass",
                    message: "No prompts match your search",
                    hint: "Try a different search term or project"
                )
            } else {
                historyContent
            }
        }
        .background(PoirotTheme.Colors.bgApp)
        .toolbar {
            HistoryToolbarContent(
                screenID: Self.screenID,
                filterQuery: $filterQuery,
                selectedProject: $selectedProject,
                allProjects: allProjects
            )
        }
        .task {
            await loadHistory()
        }
        .onAppear {
            guard fileWatcher == nil else { return }
            let historyPath = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".claude/history.jsonl").path
            let watcher = FileWatcher {
                Task {
                    await loadHistory()
                }
            }
            watcher.start(path: historyPath)
            fileWatcher = watcher
        }
        .onDisappear {
            fileWatcher?.stop()
            fileWatcher = nil
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            HStack(spacing: PoirotTheme.Spacing.md) {
                Image(systemName: NavigationItem.history.systemImage)
                    .font(PoirotTheme.Typography.headingSmall)
                    .foregroundStyle(PoirotTheme.Colors.accent)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                            .fill(PoirotTheme.Colors.accent.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                    Text("History")
                        .font(PoirotTheme.Typography.heading)
                        .foregroundStyle(PoirotTheme.Colors.textPrimary)

                    Text(countText)
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .padding(.horizontal, PoirotTheme.Spacing.sm)
                        .padding(.vertical, PoirotTheme.Spacing.xxs)
                        .background(
                            Capsule().fill(PoirotTheme.Colors.bgElevated)
                        )
                }

                Spacer()
            }

            Text("Your Claude Code prompt history across all projects")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
                .lineSpacing(PoirotTheme.Spacing.xxs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, PoirotTheme.Spacing.xxxl)
        .padding(.vertical, PoirotTheme.Spacing.xl)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.3)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var historyContent: some View {
        if appState.configLayout(for: Self.screenID) == .grid {
            historyGrid
        } else {
            historyList
        }
    }

    private var historyGrid: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: PoirotTheme.Spacing.lg) {
                ForEach(groupedEntries, id: \.group) { group, groupEntries in
                    dateGroupHeader(group)

                    let enumerated = Array(groupEntries.enumerated())
                    let columns = balancedColumns(from: enumerated)

                    HStack(alignment: .top, spacing: PoirotTheme.Spacing.lg) {
                        ForEach(0 ..< 2, id: \.self) { column in
                            LazyVStack(spacing: PoirotTheme.Spacing.md) {
                                ForEach(columns[column], id: \.element.id) { index, entry in
                                    HistoryCard(
                                        entry: entry,
                                        filterQuery: filterQuery,
                                        onTap: { selectEntry(entry) },
                                        onCopy: { copyPrompt(entry) }
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
            .padding(.horizontal, PoirotTheme.Spacing.xxxl)
            .padding(.top, PoirotTheme.Spacing.lg)
            .padding(.bottom, PoirotTheme.Spacing.xxl)
        }
        .scrollIndicators(.never)
    }

    private var historyList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
                ForEach(groupedEntries, id: \.group) { group, groupEntries in
                    dateGroupHeader(group)

                    ForEach(Array(groupEntries.enumerated()), id: \.element.id) { index, entry in
                        HistoryCard(
                            entry: entry,
                            filterQuery: filterQuery,
                            onTap: { selectEntry(entry) },
                            onCopy: { copyPrompt(entry) }
                        )
                        .shimmerReveal(
                            isRevealed: isRevealed,
                            delay: Double(min(index, 9)) * 0.03,
                            cornerRadius: PoirotTheme.Radius.md
                        )
                        .onAppear {
                            loadMoreIfNeeded(entry: entry)
                        }
                    }
                }
            }
            .padding(.horizontal, PoirotTheme.Spacing.xxxl)
            .padding(.top, PoirotTheme.Spacing.lg)
            .padding(.bottom, PoirotTheme.Spacing.xxl)
        }
        .scrollIndicators(.never)
    }

    private func dateGroupHeader(_ group: HistoryDateGroup) -> some View {
        HStack(spacing: PoirotTheme.Spacing.sm) {
            Text(group.title.uppercased())
                .font(PoirotTheme.Typography.sectionHeader)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                .tracking(0.5)

            Rectangle()
                .fill(PoirotTheme.Colors.border)
                .frame(height: 1)
        }
        .padding(.top, PoirotTheme.Spacing.md)
        .padding(.bottom, PoirotTheme.Spacing.xs)
    }

    // MARK: - Helpers

    private func balancedColumns(
        from items: [(offset: Int, element: HistoryEntry)]
    ) -> [[(offset: Int, element: HistoryEntry)]] {
        var columns: [[(offset: Int, element: HistoryEntry)]] = [[], []]
        var heights: [Int] = [0, 0]

        for item in items {
            let lineCount = item.element.display.components(separatedBy: .newlines).count
            let weight = max(2, min(lineCount, 5))
            let shorter = heights[0] <= heights[1] ? 0 : 1
            columns[shorter].append(item)
            heights[shorter] += weight
        }

        return columns
    }

    private func selectEntry(_ entry: HistoryEntry) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedEntry = entry
        }
    }

    private func copyPrompt(_ entry: HistoryEntry) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(entry.display, forType: .string)
        appState.showToast("Copied prompt to clipboard")
    }

    private func loadMoreIfNeeded(entry: HistoryEntry) {
        let allFiltered = filteredEntries
        guard let index = allFiltered.firstIndex(of: entry) else { return }
        guard index >= visibleCount - 5,
              visibleCount < allFiltered.count
        else { return }
        visibleCount += Self.pageSize
    }

    private func loadHistory() async {
        let result = await Task.detached {
            HistoryLoader().loadAll()
        }.value

        entries = result
        syncSidebarCount()

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

    private func syncSidebarCount() {
        appState.sidebarCounts[NavigationItem.history.id] = entries.count
    }
}

// MARK: - History Card

private struct HistoryCard: View {
    let entry: HistoryEntry
    var filterQuery: String = ""
    let onTap: () -> Void
    let onCopy: () -> Void

    @State
    private var isHovered = false

    @State
    private var copyTapped = false

    var body: some View {
        Button { onTap() } label: {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
                HStack(spacing: PoirotTheme.Spacing.sm) {
                    Text(HighlightedText.fuzzyAttributedString(entry.snippet, query: filterQuery))
                        .font(PoirotTheme.Typography.bodyMedium)
                        .foregroundStyle(PoirotTheme.Colors.textPrimary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Button {
                        onCopy()
                        copyTapped = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copyTapped = false }
                    } label: {
                        Image(systemName: copyTapped ? "checkmark" : "doc.on.doc")
                            .font(PoirotTheme.Typography.tiny)
                            .foregroundStyle(PoirotTheme.Colors.textTertiary)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                    .help("Copy Prompt")
                }

                HStack(spacing: PoirotTheme.Spacing.sm) {
                    Label {
                        Text(HighlightedText.fuzzyAttributedString(entry.projectName, query: filterQuery))
                    } icon: {
                        Image(systemName: "shippingbox")
                    }
                    .font(PoirotTheme.Typography.code)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    .lineLimit(1)
                    .padding(.horizontal, PoirotTheme.Spacing.sm)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                            .fill(PoirotTheme.Colors.bgElevated)
                    )

                    Spacer()

                    Text(entry.timeAgo)
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(PoirotTheme.Spacing.lg)
            .cardChrome(isHovered: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - History Detail View

private struct HistoryDetailView: View {
    let entry: HistoryEntry
    var filterQuery: String = ""
    let onBack: () -> Void
    let onCopy: () -> Void

    @State
    private var copyTapped = false

    var body: some View {
        VStack(spacing: 0) {
            detailHeader
            Divider().opacity(0.3)
            detailContent
        }
        .background(PoirotTheme.Colors.bgApp)
    }

    private var detailHeader: some View {
        HStack(spacing: PoirotTheme.Spacing.md) {
            Button { onBack() } label: {
                Image(systemName: "chevron.left")
                    .font(PoirotTheme.Typography.captionMedium)
                    .foregroundStyle(PoirotTheme.Colors.textSecondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                Text("Prompt Detail")
                    .font(PoirotTheme.Typography.heading)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                HStack(spacing: PoirotTheme.Spacing.sm) {
                    Label(entry.projectName, systemImage: "shippingbox")
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)

                    Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(PoirotTheme.Typography.tiny)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }
            }

            Spacer()

            Button {
                onCopy()
                copyTapped = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copyTapped = false }
            } label: {
                Label(
                    copyTapped ? "Copied" : "Copy Prompt",
                    systemImage: copyTapped ? "checkmark" : "doc.on.doc"
                )
                .font(PoirotTheme.Typography.captionMedium)
                .foregroundStyle(copyTapped ? PoirotTheme.Colors.green : PoirotTheme.Colors.accent)
                .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, PoirotTheme.Spacing.md)
            .padding(.vertical, PoirotTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                    .fill(PoirotTheme.Colors.bgCard)
            )
        }
        .padding(.horizontal, PoirotTheme.Spacing.xxxl)
        .padding(.vertical, PoirotTheme.Spacing.xl)
    }

    private var detailContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.lg) {
                Text(entry.display)
                    .font(PoirotTheme.Typography.body)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(PoirotTheme.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                            .fill(PoirotTheme.Colors.bgCard)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                            .strokeBorder(PoirotTheme.Colors.border, lineWidth: 1)
                    )

                if !entry.pastedContents.isEmpty {
                    VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
                        Text("Pasted Contents")
                            .font(PoirotTheme.Typography.bodyMedium)
                            .foregroundStyle(PoirotTheme.Colors.textSecondary)

                        ForEach(Array(entry.pastedContents.keys.sorted()), id: \.self) { key in
                            if let value = entry.pastedContents[key] {
                                VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xs) {
                                    Text(key)
                                        .font(PoirotTheme.Typography.code)
                                        .foregroundStyle(PoirotTheme.Colors.textTertiary)

                                    Text(value)
                                        .font(PoirotTheme.Typography.code)
                                        .foregroundStyle(PoirotTheme.Colors.textPrimary)
                                        .textSelection(.enabled)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(PoirotTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: PoirotTheme.Radius.sm)
                                        .fill(PoirotTheme.Colors.bgElevated)
                                )
                            }
                        }
                    }
                }

                metadataSection
            }
            .padding(.horizontal, PoirotTheme.Spacing.xxxl)
            .padding(.vertical, PoirotTheme.Spacing.lg)
        }
        .scrollIndicators(.never)
    }

    private var metadataSection: some View {
        HStack(spacing: PoirotTheme.Spacing.lg) {
            metadataItem(icon: "shippingbox", label: "Project", value: entry.projectName)
            metadataItem(icon: "folder", label: "Path", value: entry.project)
            metadataItem(
                icon: "clock",
                label: "Time",
                value: entry.timestamp.formatted(date: .abbreviated, time: .shortened)
            )
        }
        .padding(PoirotTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .fill(PoirotTheme.Colors.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .strokeBorder(PoirotTheme.Colors.border, lineWidth: 1)
        )
    }

    private func metadataItem(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
            Label(label, systemImage: icon)
                .font(PoirotTheme.Typography.tiny)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)

            Text(value)
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textPrimary)
                .lineLimit(1)
                .textSelection(.enabled)
        }
    }
}

// MARK: - History Toolbar

private struct HistoryToolbarContent: ToolbarContent {
    let screenID: String
    @Binding
    var filterQuery: String
    @Binding
    var selectedProject: String?
    let allProjects: [String]

    @Environment(AppState.self)
    private var appState

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            projectPicker
                .frame(width: 260)
        }
        ToolbarItemGroup(placement: .primaryAction) {
            ConfigFilterField(searchQuery: $filterQuery, placeholder: "Search prompts\u{2026}")
                .frame(width: 200)

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    appState.toggleConfigLayout(for: screenID)
                }
            } label: {
                Image(systemName: appState.configLayout(for: screenID) == .grid ? "list.bullet" : "square.grid.2x2")
                    .frame(width: 16, height: 16)
                    .contentTransition(.symbolEffect(.replace))
            }
            .help("Toggle layout")
        }
    }

    private var projectPicker: some View {
        Menu {
            Button {
                selectedProject = nil
            } label: {
                if selectedProject == nil {
                    Label("All Projects", systemImage: "checkmark")
                } else {
                    Text("All Projects")
                }
            }

            Divider()

            ForEach(allProjects, id: \.self) { project in
                Button {
                    selectedProject = project
                } label: {
                    let name = (project as NSString).lastPathComponent
                    if selectedProject == project {
                        Label(name, systemImage: "checkmark")
                    } else {
                        Text(name)
                    }
                }
            }
        } label: {
            HStack(spacing: PoirotTheme.Spacing.sm) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(PoirotTheme.Typography.caption)
                    .foregroundStyle(
                        selectedProject != nil
                            ? PoirotTheme.Colors.accent
                            : PoirotTheme.Colors.textTertiary
                    )

                Text(selectedProject.map { ($0 as NSString).lastPathComponent } ?? "All Projects")
                    .font(PoirotTheme.Typography.caption)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, PoirotTheme.Spacing.md)
            .padding(.vertical, PoirotTheme.Spacing.sm)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
    }
}
