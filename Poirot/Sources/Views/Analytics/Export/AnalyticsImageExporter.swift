import AppKit
import SwiftUI

enum AnalyticsImageExporter {
    /// Renders the given SwiftUI view to a PNG `NSImage` with a Poirot branded header.
    @MainActor
    static func renderToImage<Content: View>(
        _ content: Content,
        width: CGFloat = 1280
    ) -> NSImage? {
        let compositeView = VStack(spacing: 0) {
            AnalyticsBrandHeader()
            content
        }
        .frame(width: width)
        .environment(\.colorScheme, .dark)
        .background(PoirotTheme.Colors.bgApp)

        let renderer = ImageRenderer(content: compositeView)
        renderer.scale = 2.0

        guard let cgImage = renderer.cgImage else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width / 2, height: cgImage.height / 2))
    }

    /// Shows NSSavePanel to save as PNG.
    @MainActor
    static func presentSavePanel(image: NSImage) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "poirot-analytics.png"
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return }
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:])
        else { return }

        try? pngData.write(to: url)
    }
}

// MARK: - Brand Header

struct AnalyticsBrandHeader: View {
    var body: some View {
        HStack(spacing: PoirotTheme.Spacing.sm) {
            Image("PoirotLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 24)

            Text("Poirot")
                .font(PoirotTheme.Typography.heading)
                .foregroundStyle(PoirotTheme.Colors.textPrimary)

            Text("·")
                .foregroundStyle(PoirotTheme.Colors.textTertiary)

            Text("poirot.fyi")
                .font(PoirotTheme.Typography.small)
                .foregroundStyle(PoirotTheme.Colors.accent)

            Spacer()

            Text("Claude Code Companion for macOS")
                .font(PoirotTheme.Typography.micro)
                .foregroundStyle(PoirotTheme.Colors.textTertiary)
        }
        .padding(.horizontal, PoirotTheme.Spacing.xxl)
        .padding(.vertical, PoirotTheme.Spacing.lg)
        .background(PoirotTheme.Colors.bgApp)
    }
}
