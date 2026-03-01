import SwiftUI

struct ContributionHeatmap: View {
    let entries: [HeatmapEntry]

    @State
    private var hoveredEntry: HeatmapEntry?
    @State
    private var hoverAnchor: Anchor<CGPoint>?

    private let cellSize: CGFloat = 12
    private let cellSpacing: CGFloat = 3
    private let dayLabels = ["Mon", "", "Wed", "", "Fri", "", "Sun"]

    // Group entries by week column and day-of-week row
    private var grid: [[HeatmapEntry?]] {
        guard !entries.isEmpty else { return [] }

        let calendar = Calendar(identifier: .iso8601)
        let sorted = entries.sorted { $0.date < $1.date }
        guard let firstDate = sorted.first?.date, let lastDate = sorted.last?.date else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstDate)
        let totalDays = calendar.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0
        let adjustedFirstDay = (firstWeekday + 5) % 7 // Convert to Monday=0
        let totalSlots = adjustedFirstDay + totalDays + 1
        let weekCount = (totalSlots + 6) / 7

        var result = Array(repeating: [HeatmapEntry?](repeating: nil, count: 7), count: weekCount)
        let lookup = Dictionary(uniqueKeysWithValues: sorted.map { ($0.dateString, $0) })

        for dayOffset in 0 ... totalDays {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDate) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            let row = (weekday + 5) % 7 // Monday=0
            let col = (adjustedFirstDay + dayOffset) / 7

            let dateString = formatDateKey(date)
            result[col][row] = lookup[dateString]
        }

        return result
    }

    private var maxMessages: Int {
        entries.map(\.messages).max() ?? 1
    }

    var body: some View {
        ChartCard(title: "Activity Heatmap", subtitle: "Daily message intensity") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    // Day labels
                    VStack(spacing: cellSpacing) {
                        ForEach(0 ..< 7, id: \.self) { row in
                            Text(dayLabels[row])
                                .font(PoirotTheme.Typography.pico)
                                .foregroundStyle(PoirotTheme.Colors.textTertiary)
                                .frame(width: 28, height: cellSize, alignment: .trailing)
                        }
                    }
                    .padding(.trailing, PoirotTheme.Spacing.xs)

                    // Grid
                    HStack(spacing: cellSpacing) {
                        ForEach(0 ..< grid.count, id: \.self) { week in
                            VStack(spacing: cellSpacing) {
                                ForEach(0 ..< 7, id: \.self) { day in
                                    cellView(for: grid[week][day])
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 7 * (cellSize + cellSpacing))
            .overlayPreferenceValue(HeatmapAnchorKey.self) { anchors in
                GeometryReader { proxy in
                    if let hoveredEntry, let anchor = anchors[hoveredEntry.dateString] {
                        let point = proxy[anchor]
                        tooltipView(for: hoveredEntry)
                            .position(x: point.x, y: point.y - 40)
                    }
                }
            }
        }
    }

    // MARK: - Cell View

    private func cellView(for entry: HeatmapEntry?) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(cellColor(messages: entry?.messages ?? 0))
            .frame(width: cellSize, height: cellSize)
            .anchorPreference(key: HeatmapAnchorKey.self, value: .center) { anchor in
                if let entry {
                    return [entry.dateString: anchor]
                }
                return [:]
            }
            .onHover { isHovered in
                hoveredEntry = isHovered ? entry : nil
            }
    }

    // MARK: - Tooltip

    private func tooltipView(for entry: HeatmapEntry) -> some View {
        VStack(spacing: PoirotTheme.Spacing.xxs) {
            Text(entry.dateString)
                .font(PoirotTheme.Typography.micro)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
            Text("\(entry.messages) messages · \(entry.sessions) sessions")
                .font(PoirotTheme.Typography.microMedium)
                .foregroundStyle(PoirotTheme.Colors.textPrimary)
        }
        .padding(PoirotTheme.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: PoirotTheme.Radius.xs)
                .fill(PoirotTheme.Colors.bgElevated)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
        )
    }

    // MARK: - Color Scale

    private func cellColor(messages: Int) -> Color {
        guard messages > 0 else {
            return PoirotTheme.Colors.bgCard
        }
        let ratio = Double(messages) / Double(maxMessages)
        switch ratio {
        case 0 ..< 0.25:
            return PoirotTheme.Colors.accent.opacity(0.2)
        case 0.25 ..< 0.5:
            return PoirotTheme.Colors.accent.opacity(0.4)
        case 0.5 ..< 0.75:
            return PoirotTheme.Colors.accent.opacity(0.65)
        default:
            return PoirotTheme.Colors.accent
        }
    }

    // MARK: - Helpers

    private func formatDateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}

// MARK: - Anchor Preference Key

private struct HeatmapAnchorKey: PreferenceKey {
    static let defaultValue: [String: Anchor<CGPoint>] = [:]

    static func reduce(value: inout [String: Anchor<CGPoint>], nextValue: () -> [String: Anchor<CGPoint>]) {
        value.merge(nextValue()) { $1 }
    }
}
