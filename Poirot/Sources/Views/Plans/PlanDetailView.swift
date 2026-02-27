@preconcurrency import MarkdownUI
import SwiftUI

struct PlanDetailView: View {
    let plan: Plan

    var body: some View {
        ConfigItemDetailView(
            title: plan.name,
            icon: "list.bullet.clipboard.fill",
            iconColor: PoirotTheme.Colors.teal,
            markdownBody: plan.content,
            filePath: plan.fileURL.path
        ) {
            ConfigBadge(
                text: plan.fileURL.lastPathComponent,
                fg: PoirotTheme.Colors.teal,
                bg: PoirotTheme.Colors.teal.opacity(0.15)
            )
        }
    }
}
