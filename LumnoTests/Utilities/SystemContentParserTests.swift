@testable import Lumno
import Testing

@Suite("SystemContentParser")
struct SystemContentParserTests {
    @Test
    func parse_plainText_returnsFullTextNoBlocks() {
        let result = SystemContentParser.parse("Hello, can you fix this bug?")
        #expect(result.userText == "Hello, can you fix this bug?")
        #expect(result.systemBlocks.isEmpty)
    }

    @Test
    func parse_singleXMLTag_extractsBlock() {
        let input = """
        Fix the login flow
        <system-reminder>You are a helpful assistant</system-reminder>
        """
        let result = SystemContentParser.parse(input)
        #expect(result.userText == "Fix the login flow")
        #expect(result.systemBlocks.count == 1)
        #expect(result.systemBlocks[0].tagName == "system-reminder")
        #expect(result.systemBlocks[0].content == "You are a helpful assistant")
    }

    @Test
    func parse_multipleXMLTags_extractsAllBlocks() {
        let input = """
        Please help
        <system-reminder>Context A</system-reminder>
        <context>Context B</context>
        """
        let result = SystemContentParser.parse(input)
        #expect(result.userText == "Please help")
        #expect(result.systemBlocks.count == 2)
        #expect(result.systemBlocks[0].tagName == "system-reminder")
        #expect(result.systemBlocks[1].tagName == "context")
    }

    @Test
    func parse_textBetweenTags_preservesAllUserText() {
        let input = """
        First part
        <tag1>System 1</tag1>
        Middle part
        <tag2>System 2</tag2>
        Last part
        """
        let result = SystemContentParser.parse(input)
        #expect(result.userText == "First part\n\nMiddle part\n\nLast part")
        #expect(result.systemBlocks.count == 2)
    }

    @Test
    func parse_onlyXMLTags_returnsEmptyUserText() {
        let input = "<system-reminder>Only system content</system-reminder>"
        let result = SystemContentParser.parse(input)
        #expect(result.userText.isEmpty)
        #expect(result.systemBlocks.count == 1)
        #expect(result.systemBlocks[0].content == "Only system content")
    }

    @Test
    func parse_emptyInput_returnsEmptyResult() {
        let result = SystemContentParser.parse("")
        #expect(result.userText.isEmpty)
        #expect(result.systemBlocks.isEmpty)
    }

    @Test
    func parse_unmatchedTags_treatsAsPlainText() {
        let input = "Some <unclosed text here"
        let result = SystemContentParser.parse(input)
        #expect(result.userText == "Some <unclosed text here")
        #expect(result.systemBlocks.isEmpty)
    }

    @Test
    func parse_multilineTagContent_preservesContent() {
        let input = """
        Help me
        <system-reminder>
        Line 1
        Line 2
        Line 3
        </system-reminder>
        """
        let result = SystemContentParser.parse(input)
        #expect(result.userText == "Help me")
        #expect(result.systemBlocks.count == 1)
        #expect(result.systemBlocks[0].content == "Line 1\nLine 2\nLine 3")
    }

    @Test
    func parse_trimsWhitespace_inSystemContent() {
        let input = "<tag>  content with spaces  </tag>"
        let result = SystemContentParser.parse(input)
        #expect(result.systemBlocks[0].content == "content with spaces")
    }
}
