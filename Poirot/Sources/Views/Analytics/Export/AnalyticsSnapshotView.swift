import Charts
import SwiftUI

/// A static, non-interactive version of the analytics dashboard for image export.
struct AnalyticsSnapshotView: View {
    let stats: StatsCache
    let viewModel: AnalyticsViewModel

    private let cardColumns = Array(repeating: GridItem(.flexible(), spacing: PoirotTheme.Spacing.md), count: 4)
    private let cardRowHeight: CGFloat = 110

    var body: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxl) {
            header
            summaryCards

            // Daily Activity (static — no selection binding)
            ChartCard(title: "Daily Activity", subtitle: "Messages and sessions over time") {
                Chart {
                    ForEach(viewModel.filteredDailyActivity) { day in
                        BarMark(
                            x: .value("Date", AnalyticsFormatters.parseDate(day.date)),
                            y: .value("Messages", day.messageCount)
                        )
                        .foregroundStyle(PoirotTheme.Colors.accent.opacity(0.8))
                        .cornerRadius(2)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(
                        by: .day,
                        count: max(viewModel.filteredDailyActivity.count / 8, 7)
                    )) { _ in
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

            HourlyActivityChart(hourCounts: stats.sortedHourCounts)

            staticHeatmap

            // Token Usage (static)
            ChartCard(title: "Token Usage Over Time", subtitle: "Stacked by model") {
                Chart(viewModel.tokenTimeSeriesData) { entry in
                    AreaMark(
                        x: .value("Date", entry.date),
                        y: .value("Tokens", entry.tokens)
                    )
                    .foregroundStyle(by: .value("Model", entry.model))
                    .opacity(0.3)

                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Tokens", entry.tokens)
                    )
                    .foregroundStyle(by: .value("Model", entry.model))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)
                }
                .chartPlotStyle { plotArea in
                    plotArea.background(PoirotTheme.Colors.bgCard.opacity(0.3))
                }
                .frame(height: 220)
            }

            // Tool Calls (static)
            ChartCard(title: "Tool Calls Over Time", subtitle: "Daily tool invocations") {
                Chart(viewModel.filteredDailyActivity) { day in
                    AreaMark(
                        x: .value("Date", AnalyticsFormatters.parseDate(day.date)),
                        y: .value("Calls", day.toolCallCount)
                    )
                    .foregroundStyle(PoirotTheme.Colors.teal.opacity(0.15))

                    LineMark(
                        x: .value("Date", AnalyticsFormatters.parseDate(day.date)),
                        y: .value("Calls", day.toolCallCount)
                    )
                    .foregroundStyle(PoirotTheme.Colors.teal)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)
                }
                .chartPlotStyle { plotArea in
                    plotArea.background(PoirotTheme.Colors.bgCard.opacity(0.3))
                }
                .frame(height: 200)
            }

            HStack(alignment: .top, spacing: PoirotTheme.Spacing.lg) {
                // Model Usage donut (static)
                ChartCard(title: "Model Usage", subtitle: "Token distribution by model") {
                    Chart(stats.modelUsage.sorted(by: {
                        ($0.value.inputTokens + $0.value.outputTokens) > ($1.value.inputTokens + $1.value.outputTokens)
                    }), id: \.key) { model in
                        SectorMark(
                            angle: .value("Tokens", model.value.inputTokens + model.value.outputTokens),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("Model", StatsCache.friendlyModelName(model.key)))
                        .cornerRadius(4)
                    }
                    .frame(height: 200)
                }
                .frame(maxHeight: .infinity)

                CostBreakdownView(
                    entries: viewModel.costBreakdownEntries,
                    totalCost: viewModel.totalCost
                )
                .frame(maxHeight: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(PoirotTheme.Spacing.xxl)
        .background(PoirotTheme.Colors.bgApp)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xs) {
            Text("Session Analytics")
                .font(PoirotTheme.Typography.heading)
                .foregroundStyle(PoirotTheme.Colors.textPrimary)

            Text("Last computed: \(AnalyticsFormatters.formatLocalizedDate(stats.lastComputedDate))")
                .font(PoirotTheme.Typography.small)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
        }
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        LazyVGrid(columns: cardColumns, spacing: PoirotTheme.Spacing.md) {
            StatCard(
                title: "Total Sessions",
                value: "\(stats.totalSessions)",
                icon: "rectangle.stack.fill",
                color: PoirotTheme.Colors.accent
            )
            .frame(height: cardRowHeight)

            StatCard(
                title: "Total Messages",
                value: AnalyticsFormatters.formatLargeNumber(stats.totalMessages),
                icon: "message.fill",
                color: PoirotTheme.Colors.blue
            )
            .frame(height: cardRowHeight)

            StatCard(
                title: "Longest Session",
                value: stats.longestSessionFormatted,
                subtitle: "\(stats.longestSession.messageCount) messages",
                icon: "timer",
                color: PoirotTheme.Colors.orange
            )
            .frame(height: cardRowHeight)

            StatCard(
                title: "First Session",
                value: AnalyticsFormatters.formatFirstSessionDate(stats.firstSessionParsedDate),
                icon: "calendar",
                color: PoirotTheme.Colors.green
            )
            .frame(height: cardRowHeight)

            StatCard(
                title: "Total Cost",
                value: viewModel.hasCostData ? AnalyticsFormatters.formatCost(viewModel.totalCost) : "—",
                subtitle: viewModel.hasCostData ? nil : "included in subscription",
                icon: "dollarsign.circle.fill",
                color: PoirotTheme.Colors.green,
                dimmed: !viewModel.hasCostData
            )
            .frame(height: cardRowHeight)

            StatCard(
                title: "Total Tokens",
                value: AnalyticsFormatters.formatLargeNumber(viewModel.totalTokens),
                icon: "number.circle.fill",
                color: PoirotTheme.Colors.purple
            )
            .frame(height: cardRowHeight)

            StatCard(
                title: "Tool Calls",
                value: AnalyticsFormatters.formatLargeNumber(viewModel.totalToolCalls),
                icon: "wrench.and.screwdriver.fill",
                color: PoirotTheme.Colors.teal
            )
            .frame(height: cardRowHeight)

            StatCard(
                title: "Time Saved",
                value: viewModel.timeSavedFormatted,
                subtitle: viewModel.hasTimeSavedData ? "speculation cache" : "no cache data",
                icon: "clock.arrow.2.circlepath",
                color: PoirotTheme.Colors.blue,
                dimmed: !viewModel.hasTimeSavedData
            )
            .frame(height: cardRowHeight)
        }
    }

    // MARK: - Static Heatmap (ImageRenderer-compatible, no ScrollView/GeometryReader)

    private var staticHeatmap: some View {
        ChartCard(title: "Activity Heatmap", subtitle: "Daily message intensity") {
            let entries = viewModel.heatmapData
            let grid = Self.computeGrid(entries: entries)
            let maxMessages = entries.map(\.messages).max() ?? 1
            let cellSize: CGFloat = 12
            let cellSpacing: CGFloat = 3
            let dayLabels = ["Mon", "", "Wed", "", "Fri", "", "Sun"]

            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: cellSpacing) {
                    ForEach(0 ..< 7, id: \.self) { row in
                        Text(dayLabels[row])
                            .font(PoirotTheme.Typography.pico)
                            .foregroundStyle(PoirotTheme.Colors.textTertiary)
                            .frame(width: 28, height: cellSize, alignment: .trailing)
                    }
                }
                .padding(.trailing, PoirotTheme.Spacing.xs)

                HStack(spacing: cellSpacing) {
                    ForEach(0 ..< grid.count, id: \.self) { week in
                        VStack(spacing: cellSpacing) {
                            ForEach(0 ..< 7, id: \.self) { day in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Self.heatmapColor(messages: grid[week][day]?.messages ?? 0, max: maxMessages))
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            }
            .frame(height: 7 * (cellSize + cellSpacing))
        }
    }

    private static func heatmapColor(messages: Int, max: Int) -> Color {
        guard messages > 0 else { return PoirotTheme.Colors.bgCard }
        let ratio = Double(messages) / Double(max)
        switch ratio {
        case 0 ..< 0.25: return PoirotTheme.Colors.accent.opacity(0.2)
        case 0.25 ..< 0.5: return PoirotTheme.Colors.accent.opacity(0.4)
        case 0.5 ..< 0.75: return PoirotTheme.Colors.accent.opacity(0.65)
        default: return PoirotTheme.Colors.accent
        }
    }

    private static func computeGrid(entries: [HeatmapEntry]) -> [[HeatmapEntry?]] {
        guard !entries.isEmpty else { return [] }

        let calendar = Calendar(identifier: .iso8601)
        let sorted = entries.sorted { $0.date < $1.date }
        guard let firstDate = sorted.first?.date, let lastDate = sorted.last?.date else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstDate)
        let totalDays = calendar.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0
        let adjustedFirstDay = (firstWeekday + 5) % 7
        let totalSlots = adjustedFirstDay + totalDays + 1
        let weekCount = (totalSlots + 6) / 7

        var result = Array(repeating: [HeatmapEntry?](repeating: nil, count: 7), count: weekCount)
        let lookup = Dictionary(uniqueKeysWithValues: sorted.map { ($0.dateString, $0) })

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        for dayOffset in 0 ... totalDays {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDate) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            let row = (weekday + 5) % 7
            let col = (adjustedFirstDay + dayOffset) / 7
            let dateString = formatter.string(from: date)
            result[col][row] = lookup[dateString]
        }

        return result
    }
}
