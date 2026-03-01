import Charts
import SwiftUI

struct ModelUsageChart: View {
    let modelUsage: [String: StatsCache.ModelUsage]
    @Binding
    var selectedAngle: Int?

    private var modelData: [ModelChartEntry] {
        modelUsage.map { key, value in
            ModelChartEntry(
                model: StatsCache.friendlyModelName(key),
                tokens: value.outputTokens + value.inputTokens
            )
        }
        .sorted { $0.tokens > $1.tokens }
    }

    var body: some View {
        ChartCard(title: "Model Usage", subtitle: "Token distribution by model") {
            Chart(modelData, id: \.model) { entry in
                SectorMark(
                    angle: .value("Tokens", entry.tokens),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Model", entry.model))
                .cornerRadius(4)
                .opacity(selectedModel(entry) ? 1 : 0.7)
            }
            .chartAngleSelection(value: $selectedAngle)
            .chartForegroundStyleScale(
                domain: modelData.map(\.model),
                range: AnalyticsColorPalette.colors(count: modelData.count)
            )
            .chartLegend(position: .bottom, alignment: .center, spacing: PoirotTheme.Spacing.sm) {
                HStack(spacing: PoirotTheme.Spacing.md) {
                    ForEach(Array(modelData.enumerated()), id: \.element.model) { index, entry in
                        HStack(spacing: PoirotTheme.Spacing.xs) {
                            Circle()
                                .fill(AnalyticsColorPalette.colors(count: modelData.count)[index])
                                .frame(width: 8, height: 8)
                            Text(entry.model)
                                .font(PoirotTheme.Typography.micro)
                                .foregroundStyle(PoirotTheme.Colors.textSecondary)
                        }
                    }
                }
            }
            .chartBackground { _ in
                if let selectedAngle, let entry = findEntry(at: selectedAngle) {
                    VStack(spacing: PoirotTheme.Spacing.xxs) {
                        Text(entry.model)
                            .font(PoirotTheme.Typography.microMedium)
                            .foregroundStyle(PoirotTheme.Colors.textPrimary)
                        Text(AnalyticsFormatters.formatLargeNumber(entry.tokens))
                            .font(PoirotTheme.Typography.caption)
                            .foregroundStyle(PoirotTheme.Colors.textSecondary)
                    }
                }
            }
            .frame(height: 200)
        }
    }

    private func selectedModel(_ entry: ModelChartEntry) -> Bool {
        guard let selectedAngle else { return true }
        return findEntry(at: selectedAngle)?.model == entry.model
    }

    private func findEntry(at angle: Int) -> ModelChartEntry? {
        var cumulative = 0
        for entry in modelData {
            cumulative += entry.tokens
            if angle <= cumulative {
                return entry
            }
        }
        return modelData.last
    }
}

struct ModelChartEntry {
    let model: String
    let tokens: Int
}
