import Foundation
import Testing
@testable import UtilsLib

final class XMLParserHandlerTests {

    let parserHandler: XMLParserHandler!
    let mockDelegate: MimeTypeDecoderProtocolMock!

    init() throws {
        mockDelegate = MimeTypeDecoderProtocolMock()
        parserHandler = XMLParserHandler()
        parserHandler.delegate = mockDelegate
    }

    @Test
    func parser_success() {
        mockDelegate.isElementFoundHandler = { @Sendable _, _ in
            return true
        }

        let attributes = ["format": "DIGIDOC-XML"]
        parserHandler
            .parser(
                XMLParser(),
                didStartElement: "SignedDoc",
                namespaceURI: nil,
                qualifiedName: nil,
                attributes: attributes
            )

        #expect(mockDelegate.isElementFoundCallCount == 1)
        #expect(mockDelegate.isElementFoundArgValues.first?.elementName == "SignedDoc")
        #expect(mockDelegate.isElementFoundArgValues.first?.attributes == attributes)

        #expect(mockDelegate.handleFoundElementCallCount == 1)
        #expect(mockDelegate.handleFoundElementArgValues.first == "SignedDoc")
    }

    @Test
    func parser_unknownElementNotFound() {
        mockDelegate.isElementFoundHandler = { _, _ in
            return false
        }

        parserHandler
            .parser(
                XMLParser(),
                didStartElement: "UnknownElement",
                namespaceURI: nil,
                qualifiedName: nil,
                attributes: [:]
            )

        #expect(mockDelegate.isElementFoundCallCount == 1)
        #expect(mockDelegate.isElementFoundArgValues.first?.elementName == "UnknownElement")
        #expect(mockDelegate.handleFoundElementArgValues.isEmpty)
    }

    @Test
    func parser_elementNotFoundWithEmptyAttributes() {
        mockDelegate.isElementFoundHandler = { _, _ in
            return false
        }

        parserHandler
            .parser(
                XMLParser(),
                didStartElement: "SignedDoc",
                namespaceURI: nil,
                qualifiedName: nil,
                attributes: [:]
            )

        #expect(mockDelegate.isElementFoundCallCount == 1)
        #expect(mockDelegate.isElementFoundArgValues.first?.elementName == "SignedDoc")
        #expect(mockDelegate.isElementFoundArgValues.first?.attributes == [:])
    }
}
