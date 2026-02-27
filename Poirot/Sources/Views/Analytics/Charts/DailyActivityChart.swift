import Charts
import SwiftUI

struct DailyActivityChart: View {
    let dailyActivity: [StatsCache.DailyActivity]
    @Binding
    var selectedDate: Date?

    var body: some View {
        ChartCard(title: "Daily Activity", subtitle: "Messages and sessions over time") {
            Chart {
                ForEach(dailyActivity) { day in
                    BarMark(
                        x: .value("Date", AnalyticsFormatters.parseDate(day.date)),
                        y: .value("Messages", day.messageCount)
                    )
                    .foregroundStyle(PoirotTheme.Colors.accent.opacity(0.8))
                    .cornerRadius(2)
                }

                if let selectedDate {
                    RuleMark(x: .value("Selected", selectedDate))
                        .foregroundStyle(PoirotTheme.Colors.textTertiary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .annotation(position: .top, alignment: .center) {
                            annotationView(for: selectedDate)
                        }
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
            .frame(height: 220)
        }
    }

    private func annotationView(for date: Date) -> some View {
        let entry = dailyActivity.first {
            Calendar.current.isDate(AnalyticsFormatters.parseDate($0.date), inSameDayAs: date)
        }
        return Group {
            if let entry {
                VStack(spacing: PoirotTheme.Spacing.xxs) {
                    Text(entry.date)
                        .font(PoirotTheme.Typography.micro)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    Text("\(entry.messageCount) msgs · \(entry.sessionCount) sessions")
                        .font(PoirotTheme.Typography.microMedium)
                        .foregroundStyle(PoirotTheme.Colors.textPrimary)
                }
                .padding(PoirotTheme.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: PoirotTheme.Radius.xs)
                        .fill(PoirotTheme.Colors.bgElevated)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                )
            }
        }
    }
}
