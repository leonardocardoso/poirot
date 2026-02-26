import SwiftUI

// MARK: - Appearance Mode

enum AppearanceMode: String, CaseIterable {
    case auto
    case light
    case dark

    var label: String {
        switch self {
        case .auto: "Auto"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var appearance: NSAppearance? {
        switch self {
        case .auto: nil
        case .light: NSAppearance(named: .aqua)
        case .dark: NSAppearance(named: .darkAqua)
        }
    }
}

// MARK: - Appearance Picker

struct AppearancePicker: View {
    @Binding var selection: AppearanceMode

    var body: some View {
        HStack(spacing: 16) {
            ForEach(AppearanceMode.allCases, id: \.self) { mode in
                AppearanceOption(mode: mode, isSelected: selection == mode)
                    .onTapGesture { selection = mode }
            }
        }
    }
}

// MARK: - Option

private struct AppearanceOption: View {
    let mode: AppearanceMode
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            AppearanceThumbnail(mode: mode)
                .frame(width: 80, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2.5 : 0.5)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)

            Text(mode.label)
                .font(.system(size: 11, weight: isSelected ? .bold : .regular))
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Thumbnail

private struct AppearanceThumbnail: View {
    let mode: AppearanceMode

    var body: some View {
        switch mode {
        case .light:
            singleThumbnail(isDark: false)
        case .dark:
            singleThumbnail(isDark: true)
        case .auto:
            autoThumbnail
        }
    }

    private var autoThumbnail: some View {
        GeometryReader { geo in
            ZStack {
                singleThumbnail(isDark: true)
                singleThumbnail(isDark: false)
                    .mask(
                        HStack(spacing: 0) {
                            Rectangle()
                            Color.clear
                        }
                    )
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func singleThumbnail(isDark: Bool) -> some View {
        let desktop = isDark
            ? LinearGradient(colors: [Color(hex: 0x1C1C2E), Color(hex: 0x2A2040)], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(hex: 0xC8D0E0), Color(hex: 0xD8D0C8)], startPoint: .topLeading, endPoint: .bottomTrailing)

        let windowBg = isDark ? Color(hex: 0x2C2C30) : Color.white
        let titleBar = isDark ? Color(hex: 0x3C3C40) : Color(hex: 0xE6E6EA)

        return ZStack {
            Rectangle().fill(desktop)

            VStack(spacing: 0) {
                // Title bar
                HStack(spacing: 3) {
                    Circle().fill(Color(hex: 0xFF5F57)).frame(width: 5, height: 5)
                    Circle().fill(Color(hex: 0xFEBC2E)).frame(width: 5, height: 5)
                    Circle().fill(Color(hex: 0x28C840)).frame(width: 5, height: 5)
                    Spacer()
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 4)
                .background(titleBar)

                // Toolbar with accent bar
                HStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentColor.opacity(0.8))
                        .frame(height: 6)
                        .padding(.horizontal, 6)
                }
                .padding(.vertical, 3)
                .background(windowBg)

                // Content area
                Rectangle().fill(windowBg)
            }
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .shadow(color: .black.opacity(isDark ? 0.4 : 0.15), radius: 2, y: 1)
            .padding(8)
        }
    }
}
