import MarkdownUI
import SwiftUI

struct SessionDetailView: View {
    let session: Session

    private static let pageSize = 20

    @State
    private var visibleCount: Int = SessionDetailView.pageSize

    @State
    private var showDeleteConfirmation = false

    @State
    private var headerToast: AttributedString?

    @State
    private var resumeTapped = false

    @State
    private var copyTapped = false

    @State
    private var revealTapped = false

    @Environment(AppState.self)
    private var appState

    @Environment(\.provider)
    private var provider

    var body: some View {
        VStack(spacing: 0) {
            sessionHeader
            messagesList
            StatusBarView(isSessionEnded: true)
        }
        .background(LumnoTheme.Colors.bgApp)
        .confirmationDialog(
            "Delete session?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                appState.deleteSession(session)
            }
        } message: {
            Text("This will permanently delete the session file. This action cannot be undone.")
        }
        .onChange(of: session.id) {
            visibleCount = Self.pageSize
        }
    }

    // MARK: - Header

    private var sessionHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.title)
                .font(LumnoTheme.Typography.subheading)
                .foregroundStyle(LumnoTheme.Colors.textPrimary)
                .lineLimit(2)

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

                if session.totalTokens > 0 {
                    Text("\(session.totalTokens.formattedTokens) tokens")
                        .font(LumnoTheme.Typography.tiny)
                        .foregroundStyle(LumnoTheme.Colors.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LumnoTheme.Colors.blue.opacity(0.1))
                        )
                }

                Text("\(session.timeAgo) · \(session.turnCount) turns")
                    .font(LumnoTheme.Typography.small)
                    .foregroundStyle(LumnoTheme.Colors.textTertiary)

                Spacer()

                headerButton(
                    resumeTapped ? "Copied" : "Resume",
                    icon: resumeTapped ? "checkmark" : "arrow.uturn.forward",
                    active: resumeTapped
                ) {
                    resumeSession()
                }
                headerIconButton(
                    copyTapped ? "checkmark" : "doc.on.doc",
                    tooltip: "Copy File Name",
                    active: copyTapped
                ) {
                    copyFileName()
                }
                headerIconButton(
                    revealTapped ? "checkmark" : "folder",
                    tooltip: "Show in Finder",
                    active: revealTapped
                ) {
                    revealInFinder()
                }
                headerIconButton("trash", tooltip: "Delete", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }

            if let toast = headerToast {
                Text(toast)
                    .font(LumnoTheme.Typography.tiny)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(LumnoTheme.Colors.green)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, LumnoTheme.Spacing.xxxl)
        .padding(.vertical, LumnoTheme.Spacing.lg)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.3)
        }
    }

    // MARK: - Header Helpers

    private func headerButton(
        _ title: String,
        icon: String,
        role: ButtonRole? = nil,
        active: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        let color = active
            ? LumnoTheme.Colors.green
            : role == .destructive ? LumnoTheme.Colors.red : LumnoTheme.Colors.textSecondary

        return Button(role: role, action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .contentTransition(.symbolEffect(.replace))
                Text(title)
                    .font(LumnoTheme.Typography.tiny)
                    .contentTransition(.numericText())
            }
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                    .stroke(
                        active ? LumnoTheme.Colors.green.opacity(0.3) : role == .destructive
                            ? LumnoTheme.Colors.red.opacity(0.3) : LumnoTheme.Colors.border
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: active)
    }

    private func headerIconButton(
        _ icon: String,
        tooltip: String,
        role: ButtonRole? = nil,
        active: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        let color = active
            ? LumnoTheme.Colors.green
            : role == .destructive ? LumnoTheme.Colors.red : LumnoTheme.Colors.textSecondary

        return Button(role: role, action: action) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .contentTransition(.symbolEffect(.replace))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                        .stroke(
                            active ? LumnoTheme.Colors.green.opacity(0.3) : role == .destructive
                                ? LumnoTheme.Colors.red.opacity(0.3) : LumnoTheme.Colors.border
                        )
                )
        }
        .buttonStyle(.plain)
        .help(tooltip)
        .animation(.easeInOut(duration: 0.2), value: active)
    }

    private func resumeSession() {
        let command = "\(provider.cliPath) --resume \(session.id)"
        let cdCommand = "cd \(session.projectPath.shellEscaped) && \(command)"

        TerminalLauncher.launch(command: cdCommand, clipboardText: command)

        resumeTapped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            resumeTapped = false
        }
        showToast("Copied `\(command)`\nPaste it on your terminal")
    }

    private func copyFileName() {
        guard let url = session.fileURL else { return }
        let name = url.lastPathComponent
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(name, forType: .string)

        copyTapped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            copyTapped = false
        }
        showToast("Copied `\(name)`")
    }

    private func showToast(_ message: String) {
        let lines = message.components(separatedBy: "\n")
        var result = (try? AttributedString(markdown: lines[0])) ?? AttributedString(lines[0])
        for line in lines.dropFirst() {
            result.append(AttributedString("\n"))
            let parsed = (try? AttributedString(markdown: line)) ?? AttributedString(line)
            result.append(parsed)
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            headerToast = result
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation(.easeInOut(duration: 0.25)) {
                headerToast = nil
            }
        }
    }

    private func revealInFinder() {
        guard let url = session.fileURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([url])

        revealTapped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            revealTapped = false
        }
    }

    // MARK: - Messages

    private var messagesList: some View {
        GeometryReader { geo in
            ScrollView {
                if session.messages.isEmpty {
                    emptyState
                } else {
                    let bubbleWidth = (geo.size.width - LumnoTheme.Spacing.xxxl * 2) * 0.75
                    let visible = Array(session.messages.prefix(visibleCount).enumerated())
                    let hasMore = visibleCount < session.messages.count
                    let toolResults = Self.buildToolResultLookup(session.messages)

                    LazyVStack(spacing: LumnoTheme.Spacing.lg) {
                        ForEach(visible, id: \.offset) { index, message in
                            BubbleRow(
                                message: message,
                                turnNumber: index + 1,
                                maxBubbleWidth: bubbleWidth,
                                toolResults: toolResults
                            )
                        }

                        if hasMore {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, LumnoTheme.Spacing.lg)
                                .onAppear {
                                    visibleCount += Self.pageSize
                                }
                        }
                    }
                    .padding(LumnoTheme.Spacing.xxxl)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: LumnoTheme.Spacing.md) {
            Image(systemName: "text.bubble")
                .font(.system(size: 32))
                .foregroundStyle(LumnoTheme.Colors.textTertiary)

            Text("No messages to display")
                .font(LumnoTheme.Typography.bodyMedium)
                .foregroundStyle(LumnoTheme.Colors.textSecondary)

            if let preview = session.preview {
                Text(preview)
                    .font(LumnoTheme.Typography.caption)
                    .foregroundStyle(LumnoTheme.Colors.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineLimit(6)
                    .frame(maxWidth: 400)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private static func buildToolResultLookup(_ messages: [Message]) -> [String: ToolResult] {
        var lookup: [String: ToolResult] = [:]
        for message in messages where message.role == .user {
            for result in message.toolResultBlocks {
                lookup[result.toolUseId] = result
            }
        }
        return lookup
    }
}

// MARK: - Bubble Row

private struct BubbleRow: View {
    let message: Message
    let turnNumber: Int
    let maxBubbleWidth: CGFloat
    let toolResults: [String: ToolResult]

    @Environment(\.provider)
    private var provider

    var body: some View {
        switch message.role {
        case .user:
            UserBubble(
                message: message,
                turnNumber: turnNumber,
                maxBubbleWidth: maxBubbleWidth
            )
        case .assistant:
            AssistantBubble(
                message: message,
                turnNumber: turnNumber,
                maxBubbleWidth: maxBubbleWidth,
                provider: provider,
                toolResults: toolResults
            )
        case .system:
            EmptyView()
        }
    }
}

// MARK: - User Bubble (right-aligned)

private struct UserBubble: View {
    let message: Message
    let turnNumber: Int
    let maxBubbleWidth: CGFloat

    @State
    private var isFormatted = true

    var body: some View {
        let parsed = SystemContentParser.parse(message.textContent)

        HStack {
            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: LumnoTheme.Spacing.sm) {
                    Text("You")
                        .font(LumnoTheme.Typography.smallBold)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)

                    Text(message.timestamp, style: .time)
                        .font(LumnoTheme.Typography.tiny)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)

                    Text("#\(turnNumber)")
                        .font(LumnoTheme.Typography.tiny)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary.opacity(0.6))
                }
                .padding(.bottom, LumnoTheme.Spacing.sm)

                if !parsed.userText.isEmpty {
                    if isFormatted {
                        Markdown(parsed.userText)
                            .markdownTheme(.lumno)
                            .textSelection(.enabled)
                    } else {
                        Text(parsed.userText)
                            .font(LumnoTheme.Typography.body)
                            .foregroundStyle(LumnoTheme.Colors.textPrimary)
                            .lineSpacing(4)
                            .textSelection(.enabled)
                    }
                } else if !message.toolResultBlocks.isEmpty {
                    ForEach(message.toolResultBlocks) { result in
                        ToolResultBlock(result: result)
                    }
                }

                if !parsed.systemBlocks.isEmpty {
                    SystemContentView(blocks: parsed.systemBlocks)
                }
            }
            .padding(14)
            .frame(width: maxBubbleWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: LumnoTheme.Radius.md)
                    .fill(LumnoTheme.Colors.bgElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: LumnoTheme.Radius.md)
                            .stroke(LumnoTheme.Colors.border)
                    )
            )
            .bubbleActions(text: copyableText(parsed: parsed), isFormatted: $isFormatted)
        }
    }

    private func copyableText(parsed: SystemContentParser.Result) -> String {
        if !parsed.userText.isEmpty {
            return parsed.userText
        }
        return message.toolResultBlocks
            .map(\.content)
            .joined(separator: "\n\n")
    }
}

// MARK: - Tool Result Block (inside user bubbles)

private struct ToolResultBlock: View {
    let result: ToolResult

    @State
    private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: LumnoTheme.Spacing.sm) {
                    Image(systemName: result.isError ? "exclamationmark.triangle" : "checkmark.circle")
                        .font(.system(size: 11))
                        .foregroundStyle(result.isError ? LumnoTheme.Colors.red : LumnoTheme.Colors.green)

                    Text("Tool result")
                        .font(LumnoTheme.Typography.smallBold)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)

                    Spacer()

                    Text(result.isError ? "ERROR" : "OK")
                        .font(.system(size: 10, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(result.isError ? LumnoTheme.Colors.red : LumnoTheme.Colors.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    (result.isError ? LumnoTheme.Colors.red : LumnoTheme.Colors.green)
                                        .opacity(0.1)
                                )
                        )

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)

            if isExpanded, !result.content.isEmpty {
                Divider().opacity(0.3)

                ScrollView(.horizontal, showsIndicators: false) {
                    Text(result.content)
                        .font(LumnoTheme.Typography.code)
                        .foregroundStyle(
                            result.isError
                                ? LumnoTheme.Colors.red.opacity(0.8)
                                : LumnoTheme.Colors.textSecondary
                        )
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)
                .background(LumnoTheme.Colors.bgCode)
            }
        }
        .background(LumnoTheme.Colors.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                .stroke(result.isError ? LumnoTheme.Colors.red.opacity(0.2) : LumnoTheme.Colors.border)
        )
    }
}

// MARK: - Assistant Bubble (left-aligned)

private struct AssistantBubble: View {
    let message: Message
    let turnNumber: Int
    let maxBubbleWidth: CGFloat
    let provider: any ProviderDescribing
    let toolResults: [String: ToolResult]

    var body: some View {
        VStack(alignment: .leading, spacing: LumnoTheme.Spacing.sm) {
            ForEach(
                Array(message.textAndToolSegments.enumerated()),
                id: \.offset
            ) { index, segment in
                switch segment {
                case let .text(text):
                    HStack(alignment: .top, spacing: 10) {
                        if index == 0 {
                            avatarView
                        } else {
                            Spacer().frame(width: 28)
                        }
                        AssistantTextBubble(
                            text: text,
                            isFirst: index == 0,
                            turnNumber: turnNumber,
                            timestamp: message.timestamp,
                            maxBubbleWidth: maxBubbleWidth,
                            provider: provider
                        )
                        Spacer(minLength: 0)
                    }
                case let .tools(tools):
                    HStack(alignment: .top, spacing: 10) {
                        if index == 0 {
                            avatarView
                        } else {
                            Spacer().frame(width: 28)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(tools) { tool in
                                ToolBlockView(tool: tool, result: toolResults[tool.id])
                            }
                        }
                        .frame(maxWidth: maxBubbleWidth)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    private var avatarView: some View {
        Text(provider.assistantAvatarLetter)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(LumnoTheme.Colors.accent)
            .frame(width: 28, height: 28)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(LumnoTheme.Colors.accentDim)
            )
    }
}

// MARK: - Assistant Text Bubble

private struct AssistantTextBubble: View {
    let text: String
    let isFirst: Bool
    let turnNumber: Int
    let timestamp: Date
    let maxBubbleWidth: CGFloat
    let provider: any ProviderDescribing

    @State
    private var isFormatted = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isFirst {
                HStack(spacing: LumnoTheme.Spacing.sm) {
                    Text(provider.assistantName)
                        .font(LumnoTheme.Typography.smallBold)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)

                    Text(timestamp, style: .time)
                        .font(LumnoTheme.Typography.tiny)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary)

                    Text("#\(turnNumber)")
                        .font(LumnoTheme.Typography.tiny)
                        .foregroundStyle(LumnoTheme.Colors.textTertiary.opacity(0.6))
                }
                .padding(.bottom, LumnoTheme.Spacing.sm)
            }

            if isFormatted {
                Markdown(text)
                    .markdownTheme(.lumno)
                    .textSelection(.enabled)
            } else {
                Text(text)
                    .font(LumnoTheme.Typography.body)
                    .foregroundStyle(LumnoTheme.Colors.textPrimary)
                    .lineSpacing(4)
                    .textSelection(.enabled)
            }
        }
        .padding(14)
        .frame(width: maxBubbleWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: LumnoTheme.Radius.md)
                .fill(LumnoTheme.Colors.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: LumnoTheme.Radius.md)
                        .stroke(LumnoTheme.Colors.border)
                )
        )
        .bubbleActions(text: text, isFormatted: $isFormatted)
    }
}

// MARK: - Bubble Action Buttons

private struct BubbleActionButtons: View {
    let text: String
    @Binding
    var isFormatted: Bool

    @State
    private var copied = false

    var body: some View {
        HStack(spacing: 4) {
            // Format toggle
            BubbleIconButton(
                icon: isFormatted ? "doc.plaintext" : "doc.richtext",
                isActive: isFormatted,
                activeColor: LumnoTheme.Colors.accent
            ) {
                isFormatted.toggle()
            }

            // Copy
            BubbleIconButton(
                icon: copied ? "checkmark" : "doc.on.doc",
                isActive: copied,
                activeColor: LumnoTheme.Colors.green
            ) {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    copied = false
                }
            }
        }
    }
}

private struct BubbleIconButton: View {
    let icon: String
    let isActive: Bool
    let activeColor: Color
    let action: () -> Void

    @State
    private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(isActive ? activeColor : LumnoTheme.Colors.textTertiary)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                        .fill(LumnoTheme.Colors.bgElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: LumnoTheme.Radius.sm)
                                .stroke(isActive ? activeColor.opacity(0.3) : LumnoTheme.Colors.border)
                        )
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .scaleEffect(isHovered ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

private extension View {
    func bubbleActions(text: String, isFormatted: Binding<Bool>) -> some View {
        overlay(alignment: .topTrailing) {
            BubbleActionButtons(text: text, isFormatted: isFormatted)
                .padding(6)
        }
    }
}

// MARK: - Message Content Segments

extension Message {
    enum ContentSegment {
        case text(String)
        case tools([ToolUse])
    }

    var textAndToolSegments: [ContentSegment] {
        var segments: [ContentSegment] = []
        var currentTexts: [String] = []
        var currentTools: [ToolUse] = []

        for block in content {
            switch block {
            case let .text(text):
                if !currentTools.isEmpty {
                    segments.append(.tools(currentTools))
                    currentTools = []
                }
                currentTexts.append(text)
            case let .toolUse(tool):
                if !currentTexts.isEmpty {
                    segments.append(.text(currentTexts.joined(separator: "\n")))
                    currentTexts = []
                }
                currentTools.append(tool)
            case .toolResult, .thinking:
                break
            }
        }

        if !currentTexts.isEmpty {
            segments.append(.text(currentTexts.joined(separator: "\n")))
        }
        if !currentTools.isEmpty {
            segments.append(.tools(currentTools))
        }

        return segments
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

// MARK: - Shell Escaping

extension String {
    var shellEscaped: String {
        "'" + replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
