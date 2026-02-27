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
        }
    }
}
