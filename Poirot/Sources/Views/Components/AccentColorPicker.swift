import SwiftUI

struct AccentColorPicker: View {
    @Binding
    var selection: AccentColor
    @State
    private var preHoverSelection: AccentColor?

    var body: some View {
        HStack(spacing: 10) {
            ForEach(AccentColor.allCases, id: \.self) { color in
                AccentColorSwatch(
                    color: color,
                    isSelected: selection == color
                )
                .onTapGesture {
                    preHoverSelection = nil
                    selection = color
                }
                .onHover { hovering in
                    if hovering {
                        if preHoverSelection == nil {
                            preHoverSelection = selection
                        }
                        AccentColorStorage.current = color
                    }
                }
            }
        }
        .onHover { hovering in
            if !hovering, let original = preHoverSelection {
                AccentColorStorage.current = original
                preHoverSelection = nil
            }
        }
    }
}

// MARK: - Swatch

private struct AccentColorSwatch: View {
    let color: AccentColor
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(color.swatchColor)
                .frame(width: 22, height: 22)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .shadow(color: isSelected ? color.swatchColor.opacity(0.4) : .clear, radius: 3, y: 1)
        .contentShape(Circle())
        .accessibilityLabel(color.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
