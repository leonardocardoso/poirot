@testable import Poirot
import Foundation
import Testing

/// The `strippingXMLTags()` regex `<[^>]+>` removes tag markers (e.g. `<tag>`, `</tag>`)
/// but preserves any text content between them. The result is then trimmed.
/// If trimming yields empty, the original string is returned.
@Suite("Session XML Stripping")
struct SessionXMLStrippingTests {
    private func sessionWithTitle(_ text: String) -> Session {
        Session(
            id: "test",
            projectPath: "/path",
            messages: [
                Message(
                    id: "m1", role: .user,
                    content: [.text(text)],
                    timestamp: .now, model: nil, tokenUsage: nil
                ),
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0
        )
    }

    private func sessionWithCachedTitle(_ title: String) -> Session {
        Session(
            id: "test",
            projectPath: "/path",
            messages: [],
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            cachedTitle: title
        )
    }

    private func sessionWithPreview(_ text: String) -> Session {
        Session(
            id: "test",
            projectPath: "/path",
            messages: [
                Message(
                    id: "m1", role: .assistant,
                    content: [.text(text)],
                    timestamp: .now, model: nil, tokenUsage: nil
                ),
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0
        )
    }

    // MARK: - Title Stripping

    @Test
    func title_stripsTagMarkers_preservesInnerText() {
        // Tags are removed but "ignored" text between them is kept
        let session = sessionWithTitle("<system-reminder>ignored</system-reminder>Fix the bug")
        #expect(session.title == "ignoredFix the bug")
    }

    @Test
    func title_stripsMultipleTagMarkers() {
        let session = sessionWithTitle("<tag1>a</tag1>Hello<tag2>b</tag2> world")
        #expect(session.title == "aHellob world")
    }

    @Test
    func title_stripsNestedTagMarkers() {
        let session = sessionWithTitle("<outer><inner>content</inner></outer>Clean text")
        #expect(session.title == "contentClean text")
    }

    @Test
    func title_preservesPlainText() {
        let session = sessionWithTitle("No XML here, just plain text")
        #expect(session.title == "No XML here, just plain text")
    }

    @Test
    func title_stripsTagMarkersFromCachedTitle() {
        let session = sessionWithCachedTitle("<reminder>junk</reminder>Actual title")
        #expect(session.title == "junkActual title")
    }

    @Test
    func title_onlyTagMarkers_innerTextPreserved() {
        // After stripping tags, "content" remains — non-empty so it's returned
        let session = sessionWithTitle("<tag>content</tag>")
        #expect(session.title == "content")
    }

    @Test
    func title_onlyEmptyTags_fallsBackToOriginal() {
        // After stripping, only whitespace remains → returns original
        let session = sessionWithTitle("<tag> </tag>")
        #expect(session.title == "<tag> </tag>")
    }

    @Test
    func title_trimsWhitespaceAfterStripping() {
        let session = sessionWithTitle("  <tag>x</tag>  Hello  ")
        #expect(session.title == "x  Hello")
    }

    @Test
    func title_selfClosingTags_stripped() {
        let session = sessionWithTitle("Hello<br/>world")
        #expect(session.title == "Helloworld")
    }

    @Test
    func title_angledBracketsMatchedAsTag() {
        // `<[^>]+>` matches any `<...>` sequence including `< b and c >`
        let session = sessionWithTitle("a < b and c > d")
        #expect(session.title == "a  d")
    }

    // MARK: - Preview Stripping

    @Test
    func preview_stripsTagMarkers_preservesContent() {
        let session = sessionWithPreview("<system>ctx</system>Here is the answer")
        #expect(session.preview == "ctxHere is the answer")
    }

    @Test
    func preview_plainTextUnchanged() {
        let session = sessionWithPreview("Simple response")
        #expect(session.preview == "Simple response")
    }

    @Test
    func preview_nilWhenNoAssistantMessage() {
        let session = Session(
            id: "test",
            projectPath: "/path",
            messages: [
                Message(
                    id: "m1", role: .user,
                    content: [.text("Hello")],
                    timestamp: .now, model: nil, tokenUsage: nil
                ),
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0
        )
        #expect(session.preview == nil)
    }

    @Test
    func preview_cachedPreviewTakesPriority() {
        let session = Session(
            id: "test",
            projectPath: "/path",
            messages: [
                Message(
                    id: "m1", role: .assistant,
                    content: [.text("From message")],
                    timestamp: .now, model: nil, tokenUsage: nil
                ),
            ],
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            cachedPreview: "From cache"
        )
        #expect(session.preview == "From cache")
    }

    @Test
    func preview_cachedPreviewAlsoStripsTagMarkers() {
        let session = Session(
            id: "test",
            projectPath: "/path",
            messages: [],
            startedAt: .now,
            model: nil,
            totalTokens: 0,
            cachedPreview: "<tag>junk</tag>Clean preview"
        )
        #expect(session.preview == "junkClean preview")
    }

    @Test
    func preview_nilForEmptyMessages() {
        let session = Session(
            id: "test",
            projectPath: "/path",
            messages: [],
            startedAt: .now,
            model: nil,
            totalTokens: 0
        )
        #expect(session.preview == nil)
    }
}
