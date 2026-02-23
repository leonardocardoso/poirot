@testable import Poirot
import Foundation
import Testing

@Suite("JSONBeautifier")
struct JSONBeautifierTests {
    // MARK: - Valid JSON

    @Test
    func beautify_validObject_prettyPrints() {
        let input = #"{"b":1,"a":2}"#
        let result = JSONBeautifier.beautify(input)
        #expect(result.contains("\"a\" : 2"))
        #expect(result.contains("\"b\" : 1"))
    }

    @Test
    func beautify_validArray_prettyPrints() {
        let input = "[1,2,3]"
        let result = JSONBeautifier.beautify(input)
        #expect(result.contains("1"))
        #expect(result.contains("2"))
        #expect(result.contains("3"))
        #expect(result.contains("\n"))
    }

    // MARK: - Non-JSON

    @Test
    func beautify_nonJSON_returnsOriginal() {
        let input = "just plain text"
        let result = JSONBeautifier.beautify(input)
        #expect(result == input)
    }

    // MARK: - Doubly Encoded

    @Test
    func beautify_doublyEncoded_decodesAndFormats() throws {
        let inner = #"{"key":"value"}"#
        let encoded = try JSONSerialization.data(withJSONObject: inner, options: .fragmentsAllowed)
        let doublyEncoded = try #require(String(data: encoded, encoding: .utf8))
        let result = JSONBeautifier.beautify(doublyEncoded)
        #expect(result.contains("\"key\" : \"value\""))
    }

    // MARK: - Edge Cases

    @Test
    func beautify_emptyString_returnsOriginal() {
        let result = JSONBeautifier.beautify("")
        #expect(result == "")
    }

    @Test
    func beautify_whitespaceOnly_returnsOriginal() {
        let input = "   \n  "
        let result = JSONBeautifier.beautify(input)
        #expect(result == input)
    }

    // MARK: - Sorted Keys

    @Test
    func beautify_sortedKeys_verified() {
        let input = #"{"zebra":1,"apple":2,"mango":3}"#
        let result = JSONBeautifier.beautify(input)
        let lines = result.components(separatedBy: "\n")
        let keyLines = lines.filter { $0.contains(":") }
        let keys = keyLines.compactMap { line -> String? in
            let trimmed = line.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")
            return trimmed.components(separatedBy: " : ").first
        }
        #expect(keys == ["apple", "mango", "zebra"])
    }
}
