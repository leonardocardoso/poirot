import Charts
import SwiftUI

struct ToolCallsOverTimeChart: View {
    let dailyActivity: [StatsCache.DailyActivity]
    @Binding
    var selectedDate: Date?

    var body: some View {
        ChartCard(title: "Tool Calls Over Time", subtitle: "Daily tool call volume") {
            Chart(dailyActivity) { day in
                let date = AnalyticsFormatters.parseDate(day.date)

                AreaMark(
                    x: .value("Date", date),
                    y: .value("Tool Calls", day.toolCallCount)
                )
                .foregroundStyle(PoirotTheme.Colors.teal.opacity(0.15))
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", date),
                    y: .value("Tool Calls", day.toolCallCount)
                )
                .foregroundStyle(PoirotTheme.Colors.teal)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2))

                if let selectedDate {
                    RuleMark(x: .value("Selected", selectedDate))
                        .foregroundStyle(PoirotTheme.Colors.textTertiary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
            }
            .chartXSelection(value: $selectedDate)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: max(dailyActivity.count / 8, 7))) { _ in
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
            .frame(height: 200)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    if let selectedDate,
                       let entry = dailyActivity.first(where: {
                           Calendar.current.isDate(AnalyticsFormatters.parseDate($0.date), inSameDayAs: selectedDate)
                       }),
                       let xPos = proxy.position(forX: selectedDate) {
                        let clampedX = min(max(xPos, 80), geometry.size.width - 80)

                        VStack(spacing: PoirotTheme.Spacing.xxs) {
                            Text(AnalyticsFormatters.formatLocalizedDate(entry.date))
                                .font(PoirotTheme.Typography.micro)
                                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                            Text("\(entry.toolCallCount) tool calls")
                                .font(PoirotTheme.Typography.microMedium)
                                .foregroundStyle(PoirotTheme.Colors.textPrimary)
                        }
                        .padding(PoirotTheme.Spacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: PoirotTheme.Radius.xs)
                                .fill(PoirotTheme.Colors.bgElevated)
                                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                        )
                        .position(x: clampedX, y: 12)
                    }
                }
                .allowsHitTesting(false)
            }
        }
    }
}
