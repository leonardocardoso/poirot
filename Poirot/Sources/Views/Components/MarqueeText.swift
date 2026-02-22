import SwiftUI

struct MarqueeText: View {
    let text: String
    let font: Font
    var highlightQuery: String = ""

    @State
    private var isHovered = false

    @State
    private var offset: CGFloat = 0

    @State
    private var textWidth: CGFloat = 0

    @State
    private var containerWidth: CGFloat = 0

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    private var overflow: CGFloat {
        max(0, textWidth - containerWidth)
    }

    private var isHighlighting: Bool { !highlightQuery.isEmpty }

    private var displayText: Text {
        if isHighlighting {
            Text(HighlightedText.fuzzyAttributedString(text, query: highlightQuery))
        } else {
            Text(text)
        }
    }

    var body: some View {
        Text(text)
            .font(font)
            .lineLimit(1)
            .hidden()
            .overlay(alignment: .leading) {
                displayText
                    .font(font)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .offset(x: offset)
                    .onGeometryChange(for: CGFloat.self, of: { $0.size.width }, action: {
                        textWidth = $0
                    })
            }
            .onGeometryChange(for: CGFloat.self, of: { $0.size.width }, action: {
                containerWidth = $0
            })
            .mask {
                HStack(spacing: 0) {
                    Rectangle()
                    if overflow > 0 {
                        LinearGradient(
                            colors: [.black, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 24)
                    }
                }
            }
            .onHover { isHovered = $0 }
            .task(id: isHovered) {
                guard isHovered, overflow > 0, !reduceMotion else {
                    withAnimation(.easeOut(duration: 0.15)) { offset = 0 }
                    return
                }
                try? await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled else { return }
                while !Task.isCancelled {
                    let scrollDuration = max(1.0, Double(overflow) / 30.0)
                    withAnimation(.linear(duration: scrollDuration)) {
                        offset = -overflow
                    }
                    try? await Task.sleep(for: .milliseconds(Int(scrollDuration * 1000) + 600))
                    guard !Task.isCancelled else { break }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        offset = 0
                    }
                    try? await Task.sleep(for: .milliseconds(1000))
                    guard !Task.isCancelled else { break }
                }
            }
    }
}
