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

                if let selectedDate {
                    RuleMark(x: .value("Selected", selectedDate))
                        .foregroundStyle(PoirotTheme.Colors.textTertiary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
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
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    if let selectedDate {
                        let entriesForDate = data.filter {
                            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                        }
                        if !entriesForDate.isEmpty, let xPos = proxy.position(forX: selectedDate) {
                            let clampedX = min(max(xPos, 90), geometry.size.width - 90)

                            VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xxs) {
                                Text(AnalyticsFormatters.formatLocalizedDate(
                                    AnalyticsFormatters.dateToString(selectedDate)
                                ))
                                .font(PoirotTheme.Typography.micro)
                                .foregroundStyle(PoirotTheme.Colors.textTertiary)

                                ForEach(entriesForDate, id: \.model) { entry in
                                    Text("\(entry.model): \(AnalyticsFormatters.formatLargeNumber(entry.tokens))")
                                        .font(PoirotTheme.Typography.microMedium)
                                        .foregroundStyle(PoirotTheme.Colors.textPrimary)
                                }
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
                }
                .allowsHitTesting(false)
            }
        }
    }
}
