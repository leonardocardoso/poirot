@testable import Poirot
import Testing

@Suite("FrontmatterParser")
struct FrontmatterParserTests {
    // MARK: - No Frontmatter

    @Test
    func parse_noFrontmatter_returnsOriginalBody() {
        let input = "Just some plain text"
        let result = FrontmatterParser.parse(input)
        #expect(result.metadata.isEmpty)
        #expect(result.body == input)
    }

    // MARK: - Unclosed Frontmatter

    @Test
    func parse_unclosedFrontmatter_returnsOriginalBody() {
        let input = "---\nkey: value\nno closing marker"
        let result = FrontmatterParser.parse(input)
        #expect(result.metadata.isEmpty)
        #expect(result.body == input)
    }

    // MARK: - Well-Formed

    @Test
    func parse_wellFormed_extractsMetadata() {
        let input = """
        ---
        title: Hello World
        ---
        Body content here
        """
        let result = FrontmatterParser.parse(input)
        #expect(result.metadata["title"] == "Hello World")
        #expect(result.body == "Body content here")
    }

    // MARK: - Colon In Value

    @Test
    func parse_colonInValue_preservesFullValue() {
        let input = """
        ---
        description: foo: bar
        ---
        Body
        """
        let result = FrontmatterParser.parse(input)
        #expect(result.metadata["description"] == "foo: bar")
    }

    // MARK: - Empty Lines In YAML

    @Test
    func parse_emptyLinesInYAML_skipped() {
        let input = """
        ---
        key1: value1

        key2: value2
        ---
        Body
        """
        let result = FrontmatterParser.parse(input)
        #expect(result.metadata.count == 2)
        #expect(result.metadata["key1"] == "value1")
        #expect(result.metadata["key2"] == "value2")
    }

    // MARK: - Body Trimmed

    @Test
    func parse_bodyTrimmed_whitespaceRemoved() {
        let input = """
        ---
        key: val
        ---

          Body with surrounding whitespace

        """
        let result = FrontmatterParser.parse(input)
        #expect(result.body == "Body with surrounding whitespace")
    }

    // MARK: - Multiple Keys

    @Test
    func parse_multipleKeys_allExtracted() {
        let input = """
        ---
        title: Test
        author: Alice
        version: 3
        ---
        Content
        """
        let result = FrontmatterParser.parse(input)
        #expect(result.metadata.count == 3)
        #expect(result.metadata["title"] == "Test")
        #expect(result.metadata["author"] == "Alice")
        #expect(result.metadata["version"] == "3")
    }

    // MARK: - Empty Body After Frontmatter

    @Test
    func parse_emptyBody_afterFrontmatter() {
        let input = """
        ---
        key: value
        ---
        """
        let result = FrontmatterParser.parse(input)
        #expect(result.metadata["key"] == "value")
        #expect(result.body.isEmpty)
    }

    // MARK: - Block Scalar Folded (>)

    @Test
    func parse_foldedBlockScalar_joinsWithSpaces() {
        let input = "---\nname: my-skill\ndescription: >\n  Multi-line description\n  goes here\n---\nBody"
        let result = FrontmatterParser.parse(input)
        #expect(result.metadata["name"] == "my-skill")
        #expect(result.metadata["description"] == "Multi-line description goes here")
        #expect(result.body == "Body")
    }

    // MARK: - Block Scalar Literal (|)

    @Test
    func parse_literalBlockScalar_joinsWithNewlines() {
        let input = "---\nname: my-skill\ndescription: |\n  Line one\n  Line two\n---\nBody"
        let result = FrontmatterParser.parse(input)
        #expect(result.metadata["name"] == "my-skill")
        #expect(result.metadata["description"] == "Line one\nLine two")
    }

    // MARK: - Block Scalar Followed By Another Key

    @Test
    func parse_blockScalarFollowedByKey_bothExtracted() {
        let input = "---\ndescription: >\n  A long\n  description\nmodel: opus\n---\nBody"
        let result = FrontmatterParser.parse(input)
        #expect(result.metadata["description"] == "A long description")
        #expect(result.metadata["model"] == "opus")
    }

    // MARK: - Block Scalar At End Of YAML

    @Test
    func parse_blockScalarAtEnd_extracted() {
        let input = "---\nname: test\nallowed-tools: >\n  Bash, Read,\n  Glob, Grep\n---\nBody"
        let result = FrontmatterParser.parse(input)
        #expect(result.metadata["name"] == "test")
        #expect(result.metadata["allowed-tools"] == "Bash, Read, Glob, Grep")
    }
}
