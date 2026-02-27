import Charts
import SwiftUI

struct TokenUsageOverTimeChart: View {
    let data: [TokenTimeSeriesEntry]
    @Binding
    var selectedDate: Date?

    private var models: [String] {
        Array(Set(data.map(\.model))).sorted()
    }

    var body: some View {
        ChartCard(title: "Token Usage Over Time", subtitle: "Stacked by model") {
            Chart(data) { entry in
                AreaMark(
                    x: .value("Date", entry.date),
                    y: .value("Tokens", entry.tokens)
                )
                .foregroundStyle(by: .value("Model", entry.model))
                .interpolationMethod(.catmullRom)
                .opacity(0.3)

                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Tokens", entry.tokens)
                )
                .foregroundStyle(by: .value("Model", entry.model))
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 1.5))
            }
            .chartXSelection(value: $selectedDate)
            .chartForegroundStyleScale(
                domain: models,
                range: AnalyticsColorPalette.colors(count: models.count)
            )
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 14)) { _ in
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
            .chartLegend(position: .bottom, alignment: .center, spacing: PoirotTheme.Spacing.sm)
            .chartPlotStyle { plotArea in
                plotArea.background(PoirotTheme.Colors.bgCard.opacity(0.3))
            }
            .frame(height: 240)
        }
    }
}
