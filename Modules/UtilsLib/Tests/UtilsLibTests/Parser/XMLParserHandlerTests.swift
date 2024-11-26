import Foundation
import Testing
import Cuckoo
@testable import UtilsLib

final class XMLParserHandlerTests {

    var parserHandler: XMLParserHandler!
    var mockDelegate: MockMimeTypeDecoderProtocol!

    init() async throws {
        mockDelegate = MockMimeTypeDecoderProtocol()
        parserHandler = XMLParserHandler()
        parserHandler.delegate = mockDelegate
    }

    deinit {
        parserHandler = nil
        mockDelegate = nil
    }

    @Test
    func parser_success() {
        stub(mockDelegate) { mock in
            when(mock.isElementFound(named: equal(to: "SignedDoc"), attributes: any())).thenReturn(true)
            when(mock.handleFoundElement(named: equal(to: "SignedDoc"))).thenDoNothing()
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

        verify(mockDelegate).isElementFound(named: equal(to: "SignedDoc"), attributes: equal(to: attributes))
        verify(mockDelegate).handleFoundElement(named: equal(to: "SignedDoc"))
    }

    @Test
    func parser_unknownElementNotFound() {
        stub(mockDelegate) { mock in
            when(mock.isElementFound(named: equal(to: "UnknownElement"), attributes: any())).thenReturn(false)
        }

        parserHandler
            .parser(
                XMLParser(),
                didStartElement: "UnknownElement",
                namespaceURI: nil,
                qualifiedName: nil,
                attributes: [:]
            )

        verify(mockDelegate).isElementFound(named: equal(to: "UnknownElement"), attributes: any())
        verify(mockDelegate, never()).handleFoundElement(named: any())
    }

    @Test
    func parser_elementNotFoundWithEmptyAttributes() {
        stub(mockDelegate) { mock in
            when(mock.isElementFound(named: equal(to: "SignedDoc"), attributes: equal(to: [:]))).thenReturn(false)
        }

        parserHandler
            .parser(
                XMLParser(),
                didStartElement: "SignedDoc",
                namespaceURI: nil,
                qualifiedName: nil,
                attributes: [:]
            )

        verify(mockDelegate).isElementFound(named: equal(to: "SignedDoc"), attributes: equal(to: [:]))
    }
}
