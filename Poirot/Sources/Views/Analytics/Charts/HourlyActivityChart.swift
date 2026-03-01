import Charts
import SwiftUI

struct HourlyActivityChart: View {
    let hourCounts: [(hour: Int, count: Int)]

    @State
    private var selectedHour: Int?

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

                if let selectedHour, selectedHour == entry.hour {
                    RuleMark(x: .value("Selected", selectedHour))
                        .foregroundStyle(PoirotTheme.Colors.textTertiary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
            }
            .chartXSelection(value: $selectedHour)
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
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    if let selectedHour,
                       let entry = hourCounts.first(where: { $0.hour == selectedHour }),
                       let xPos = proxy.position(forX: selectedHour) {
                        let clampedX = min(max(xPos, 70), geometry.size.width - 70)

                        VStack(spacing: PoirotTheme.Spacing.xxs) {
                            Text(AnalyticsFormatters.formatHour(entry.hour))
                                .font(PoirotTheme.Typography.micro)
                                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                            Text("\(entry.count) sessions")
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
