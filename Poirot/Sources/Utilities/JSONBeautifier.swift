import Foundation

enum JSONBeautifier {
    /// Attempts to pretty-print the string as JSON.
    /// Returns the formatted string if valid JSON, otherwise returns the original.
    static func beautify(_ string: String) -> String {
        var trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

        // Handle doubly-encoded JSON: a JSON string value containing JSON.
        // e.g. `"{\"key\":\"value\"}"` — JSONSerialization decodes the
        // outer string, unescaping \" → " and \n → newline, giving us
        // the inner JSON to then pretty-print.
        if trimmed.hasPrefix("\""), trimmed.hasSuffix("\""), trimmed.count > 2,
           let data = trimmed.data(using: .utf8),
           let decoded = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? String {
            trimmed = decoded
        }

        guard trimmed.hasPrefix("{") || trimmed.hasPrefix("["),
              let data = trimmed.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(
                  withJSONObject: object,
                  options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
              ),
              let result = String(data: pretty, encoding: .utf8)
        else {
            return string
        }
        return result
    }
}
