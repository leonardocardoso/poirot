import Charts
import SwiftUI

struct CostBreakdownView: View {
    let entries: [CostBreakdownEntry]
    let totalCost: Double

    private var hasCostData: Bool {
        totalCost > 0
    }

    var body: some View {
        ChartCard(title: "Cost & Token Breakdown", subtitle: "Per-model cost and token distribution") {
            if hasCostData {
                costAndTokenLayout
            } else {
                tokenOnlyLayout
            }
        }
    }

    // MARK: - Layout with cost data (API users)

    private var costAndTokenLayout: some View {
        HStack(alignment: .top, spacing: PoirotTheme.Spacing.xxl) {
            costDonut
                .frame(maxWidth: .infinity)
            tokenTable
                .frame(maxWidth: .infinity)
        }
        .frame(height: 280)
    }

    // MARK: - Layout without cost data (subscription users)

    private var tokenOnlyLayout: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.md) {
            HStack(spacing: PoirotTheme.Spacing.sm) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
                Text("Cost tracking is available for API users only")
                    .font(PoirotTheme.Typography.micro)
                    .foregroundStyle(PoirotTheme.Colors.textTertiary)
            }
            tokenTable
        }
    }

    // MARK: - Cost Donut

    private var costDonut: some View {
        VStack(spacing: PoirotTheme.Spacing.sm) {
            Chart(entries) { entry in
                SectorMark(
                    angle: .value("Cost", entry.cost),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Model", entry.model))
                .cornerRadius(4)
            }
            .chartForegroundStyleScale(
                domain: entries.map(\.model),
                range: AnalyticsColorPalette.colors(count: entries.count)
            )
            .chartBackground { _ in
                VStack(spacing: PoirotTheme.Spacing.xxs) {
                    Text("Total")
                        .font(PoirotTheme.Typography.micro)
                        .foregroundStyle(PoirotTheme.Colors.textTertiary)
                    Text(AnalyticsFormatters.formatCost(totalCost))
                        .font(PoirotTheme.Typography.heading)
                        .foregroundStyle(PoirotTheme.Colors.textPrimary)
                }
            }
            .chartLegend(.hidden)
            .frame(height: 180)

            // Legend
            HStack(spacing: PoirotTheme.Spacing.md) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    HStack(spacing: PoirotTheme.Spacing.xs) {
                        Circle()
                            .fill(AnalyticsColorPalette.colors(count: entries.count)[index])
                            .frame(width: 8, height: 8)
                        Text("\(entry.model) \(AnalyticsFormatters.formatCost(entry.cost))")
                            .font(PoirotTheme.Typography.micro)
                            .foregroundStyle(PoirotTheme.Colors.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Token Table

    private var tokenTable: some View {
        VStack(alignment: .leading, spacing: PoirotTheme.Spacing.xs) {
            // Header
            HStack {
                Text("Model")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Input")
                    .frame(width: 70, alignment: .trailing)
                Text("Output")
                    .frame(width: 70, alignment: .trailing)
                Text("Cache")
                    .frame(width: 70, alignment: .trailing)
            }
            .font(PoirotTheme.Typography.microSemibold)
            .foregroundStyle(PoirotTheme.Colors.textTertiary)

            Divider()
                .background(PoirotTheme.Colors.border)

            ForEach(entries) { entry in
                HStack {
                    Text(entry.model)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(AnalyticsFormatters.formatLargeNumber(entry.inputTokens))
                        .frame(width: 70, alignment: .trailing)
                    Text(AnalyticsFormatters.formatLargeNumber(entry.outputTokens))
                        .frame(width: 70, alignment: .trailing)
                    Text(AnalyticsFormatters.formatLargeNumber(entry.cacheTokens))
                        .frame(width: 70, alignment: .trailing)
                }
                .font(PoirotTheme.Typography.micro)
                .foregroundStyle(PoirotTheme.Colors.textSecondary)
            }
        }
        .padding(.top, PoirotTheme.Spacing.sm)
    }
}
