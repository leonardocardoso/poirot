import SwiftUI
import Observation

@Observable
final class AppState {
    var selectedNav: NavigationItem = .sessions
    var selectedSession: Session?
    var selectedProject: String?
    var isSearchPresented: Bool = false
    var projects: [Project] = []

    enum NavigationItem: String, CaseIterable, Identifiable {
        case sessions
        case commands
        case skills
        case configuration

        var id: String { rawValue }

        var title: String {
            switch self {
            case .sessions: "Sessions"
            case .commands: "Commands"
            case .skills: "Skills"
            case .configuration: "Configuration"
            }
        }

        var systemImage: String {
            switch self {
            case .sessions: "rectangle.stack"
            case .commands: "terminal"
            case .skills: "bolt.circle"
            case .configuration: "gearshape"
            }
        }
    }
}
