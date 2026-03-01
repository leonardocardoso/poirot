import SwiftUI

/// Displays a dynamic status indicator for an MCP server using
/// SF Symbols with appropriate colors, animations, and accessibility.
struct MCPServerStatusIndicator: View {
    let status: MCPServerStatus

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    var body: some View {
        Image(systemName: status.symbolName)
            .font(.system(size: 8))
            .foregroundStyle(status.color)
            .symbolEffect(
                .pulse,
                isActive: status == .starting && !reduceMotion
            )
            .accessibilityLabel(Text(status.accessibilityLabel))
    }
}

// MARK: - MCPServerStatus UI Properties

extension MCPServerStatus {
    var symbolName: String {
        switch self {
        case .connected: "circle.fill"
        case .needsAuth: "exclamationmark.triangle.fill"
        case .failed: "xmark.circle.fill"
        case .unreachable: "bolt.horizontal.circle.fill"
        case .starting: "circle.fill"
        case .unknown: "questionmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .connected: PoirotTheme.Colors.green
        case .needsAuth: PoirotTheme.Colors.orange
        case .failed: PoirotTheme.Colors.red
        case .unreachable: PoirotTheme.Colors.red
        case .starting: PoirotTheme.Colors.blue
        case .unknown: PoirotTheme.Colors.textTertiary
        }
    }

    var label: String {
        switch self {
        case .connected: "Connected"
        case .needsAuth: "Needs Auth"
        case .failed: "Failed"
        case .unreachable: "Unreachable"
        case .starting: "Starting"
        case .unknown: "Unknown"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .connected:
            "Server is connected and running"
        case .needsAuth:
            "Server requires authentication"
        case .failed:
            "Server failed to start"
        case .unreachable:
            "Server is unreachable"
        case .starting:
            "Server is starting up"
        case .unknown:
            "Server status is unknown"
        }
    }
}
