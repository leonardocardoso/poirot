import Charts
import SwiftUI

struct AnalyticsDashboardView: View {
    @State
    private var stats: StatsCache?
    @State
    private var isLoading = true
    @State
    private var loadBounce = 0

    var body: some View {
        Group {
            if isLoading {
                loadingState
            } else if let stats {
                dashboardContent(stats)
            } else {
                emptyState
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PoirotTheme.Colors.bgApp)
        .task {
            await loadStats()
        }
    }

    // MARK: - Loading

    private var loadingState: some View {
        VStack(spacing: PoirotTheme.Spacing.md) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 36))
                .foregroundStyle(PoirotTheme.Colors.accent)
                .symbolEffect(.pulse, isActive: isLoading)

            Text("Loading analytics...")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: PoirotTheme.Spacing.md) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 48))
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                .symbolEffect(.bounce, value: loadBounce)

            Text("No Analytics Data")
                .font(PoirotTheme.Typography.heading)
                .foregroundStyle(PoirotTheme.Colors.textPrimary)

            Text("Stats cache not found at ~/.claude/stats-cache.json")
                .font(PoirotTheme.Typography.caption)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
        }
        .onAppear { loadBounce += 1 }
    }

    // MARK: - Dashboard Content

    private func dashboardContent(_ stats: StatsCache) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxl) {
                header(stats)
                summaryCards(stats)
                dailyActivityChart(stats)
                HStack(alignment: .top, spacing: PoirotTheme.Spacing.lg) {
                    modelUsageChart(stats)
                    hourlyActivityChart(stats)
                }
            }
            .padding(PoirotTheme.Spacing.xxl)
        }
    }

    // MARK: - Header

    private func header(_ stats: StatsCache) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xs) {
                Text("Session Analytics")
                    .font(PoirotTheme.Typography.heading)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                Text("Last computed: \(stats.lastComputedDate)")
                    .font(PoirotTheme.Typography.small)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
            }

            Spacer()

            Button {
                Task { await loadStats() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(PoirotTheme.Typography.caption)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    .symbolEffect(.rotate, value: isLoading)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        }
    }

    // MARK: - Summary Cards

    private func summaryCards(_ stats: StatsCache) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: PoirotTheme.Spacing.md), count: 4), spacing: PoirotTheme.Spacing.md) {
            StatCard(
                title: "Total Sessions",
                value: "\(stats.totalSessions)",
                icon: "rectangle.stack.fill",
                color: PoirotTheme.Colors.accent
            )

            StatCard(
                title: "Total Messages",
                value: Self.formatLargeNumber(stats.totalMessages),
                icon: "message.fill",
                color: PoirotTheme.Colors.blue
            )

            StatCard(
                title: "Longest Session",
                value: stats.longestSessionFormatted,
                subtitle: "\(stats.longestSession.messageCount) messages",
                icon: "timer",
                color: PoirotTheme.Colors.orange
            )

            StatCard(
                title: "First Session",
                value: Self.formatFirstSessionDate(stats.firstSessionParsedDate),
                icon: "calendar",
                color: PoirotTheme.Colors.green
            )
        }
    }

    // MARK: - Daily Activity Chart

    private func dailyActivityChart(_ stats: StatsCache) -> some View {
        ChartCard(title: "Daily Activity", subtitle: "Messages and sessions over time") {
            Chart {
                ForEach(stats.dailyActivity) { day in
                    BarMark(
                        x: .value("Date", Self.parseDate(day.date)),
                        y: .value("Messages", day.messageCount)
                    )
                    .foregroundStyle(PoirotTheme.Colors.accent.opacity(0.8))
                    .cornerRadius(2)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        .foregroundStyle(PoirotTheme.Colors.border)
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .font(PoirotTheme.Typography.micro)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        .foregroundStyle(PoirotTheme.Colors.border)
                    AxisValueLabel()
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .font(PoirotTheme.Typography.micro)
                }
            }
            .chartPlotStyle { plotArea in
                plotArea.background(PoirotTheme.Colors.bgCard.opacity(0.3))
            }
            .frame(height: 220)
        }
    }

    // MARK: - Model Usage Chart

    private func modelUsageChart(_ stats: StatsCache) -> some View {
        let modelData = stats.modelUsage.map { key, value in
            ModelChartEntry(
                model: StatsCache.friendlyModelName(key),
                tokens: value.outputTokens + value.inputTokens
            )
        }
        .sorted { $0.tokens > $1.tokens }

        return ChartCard(title: "Model Usage", subtitle: "Token distribution by model") {
            Chart(modelData, id: \.model) { entry in
                SectorMark(
                    angle: .value("Tokens", entry.tokens),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Model", entry.model))
                .cornerRadius(4)
            }
            .chartForegroundStyleScale(domain: modelData.map(\.model), range: modelColors(count: modelData.count))
            .chartLegend(position: .bottom, alignment: .center, spacing: PoirotTheme.Spacing.sm) {
                HStack(spacing: PoirotTheme.Spacing.md) {
                    ForEach(Array(modelData.enumerated()), id: \.element.model) { index, entry in
                        HStack(spacing: PoirotTheme.Spacing.xs) {
                            Circle()
                                .fill(modelColors(count: modelData.count)[index])
                                .frame(width: 8, height: 8)
                            Text(entry.model)
                                .font(PoirotTheme.Typography.micro)
                                .foregroundStyle(PoirotTheme.Colors.textSecondary)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
    }

    // MARK: - Hourly Activity Chart

    private func hourlyActivityChart(_ stats: StatsCache) -> some View {
        ChartCard(title: "Activity by Hour", subtitle: "Session start times (UTC)") {
            Chart(stats.sortedHourCounts, id: \.hour) { entry in
                BarMark(
                    x: .value("Hour", entry.hour),
                    y: .value("Sessions", entry.count)
                )
                .foregroundStyle(
                    Gradient(colors: [
                        PoirotTheme.Colors.accent.opacity(0.6),
                        PoirotTheme.Colors.accent,
                    ])
                )
                .cornerRadius(3)
            }
            .chartXAxis {
                AxisMarks(values: [0, 6, 12, 18, 23]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        .foregroundStyle(PoirotTheme.Colors.border)
                    AxisValueLabel {
                        if let hour = value.as(Int.self) {
                            Text(Self.formatHour(hour))
                                .font(PoirotTheme.Typography.micro)
                                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        .foregroundStyle(PoirotTheme.Colors.border)
                    AxisValueLabel()
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                        .font(PoirotTheme.Typography.micro)
                }
            }
            .chartPlotStyle { plotArea in
                plotArea.background(PoirotTheme.Colors.bgCard.opacity(0.3))
            }
            .frame(height: 200)
        }
    }

    // MARK: - Helpers

    private func loadStats() async {
        isLoading = true
        let loaded = await Task.detached {
            StatsCacheLoader.load()
        }.value
        stats = loaded
        isLoading = false
    }

    private static func parseDate(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: string) ?? .now
    }

    private static func formatFirstSessionDate(_ date: Date?) -> String {
        guard let date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    private static func formatLargeNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        }
        if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000)
        }
        return "\(number)"
    }

    private static func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour)\(period)"
    }

    private func modelColors(count: Int) -> [Color] {
        let palette: [Color] = [
            PoirotTheme.Colors.accent,
            PoirotTheme.Colors.blue,
            PoirotTheme.Colors.purple,
            PoirotTheme.Colors.teal,
            PoirotTheme.Colors.green,
            PoirotTheme.Colors.orange,
        ]
        return Array(palette.prefix(count))
    }
}

// MARK: - Supporting Types

private struct ModelChartEntry {
    let model: String
    let tokens: Int
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String?
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)

                Spacer()
            }

            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                Text(value)
                    .font(PoirotTheme.Typography.heading)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                Text(title)
                    .font(PoirotTheme.Typography.small)
                    .foregroundStyle(PoirotTheme.Colors.textSecondary)

                if let subtitle {
                    Text(subtitle)
                        .font(PoirotTheme.Typography.micro)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                }
            }
        }
        .padding(PoirotTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .fill(PoirotTheme.Colors.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .stroke(PoirotTheme.Colors.border, lineWidth: 1)
        )
    }
}

// MARK: - Chart Card

private struct ChartCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder
    let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                Text(title)
                    .font(PoirotTheme.Typography.bodyMedium)
                    .foregroundStyle(PoirotTheme.Colors.textPrimary)

                Text(subtitle)
                    .font(PoirotTheme.Typography.small)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
            }

            content
        }
        .padding(PoirotTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .fill(PoirotTheme.Colors.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.md)
                .stroke(PoirotTheme.Colors.border, lineWidth: 1)
        )
    }
}
