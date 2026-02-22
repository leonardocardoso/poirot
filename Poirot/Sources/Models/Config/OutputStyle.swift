import Foundation

struct OutputStyle: Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let filename: String
    let body: String
    let filePath: String
    let scope: ConfigScope
}
