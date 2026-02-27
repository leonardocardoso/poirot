import Charts
import SwiftUI

struct HourlyActivityChart: View {
    let hourCounts: [(hour: Int, count: Int)]

    var body: some View {
        ChartCard(title: "Activity by Hour", subtitle: "Session start times (UTC)") {
            Chart(hourCounts, id: \.hour) { entry in
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
                            Text(AnalyticsFormatters.formatHour(hour))
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
}
