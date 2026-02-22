import SwiftUI

struct ConfigurationItem: Identifiable {
    let id: String
    let icon: String
    let iconColor: Color
    let title: String
    let count: String
    let description: String
    let requiredCapability: ProviderCapability
}
