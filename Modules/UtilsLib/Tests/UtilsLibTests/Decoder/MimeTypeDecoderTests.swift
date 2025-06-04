import Foundation
import Testing
@testable import UtilsLib

@MainActor
struct MimeTypeDecoderTests {

    private let mockMimeTypeDecoderDelegate: MimeTypeDecoderProtocolMock!
    private let mimeTypeDecoder: MimeTypeDecoder!

    init() async throws {
        await UtilsLibAssembler.shared.initialize()

        mockMimeTypeDecoderDelegate = MimeTypeDecoderProtocolMock()
        mimeTypeDecoder = MimeTypeDecoder()
        mimeTypeDecoder.delegate = mockMimeTypeDecoderDelegate
    }

    @Test
    func isElementFound_success() {
        let elementName = "SignedDoc"
        let attributes = ["format": "DIGIDOC-XML"]

        #expect(mimeTypeDecoder.isElementFound(named: elementName, attributes: attributes))
    }

    @Test
    func isElementFound_unknownElementNotFound() {
        let elementName = "OtherElement"
        let attributes = ["format": "DIGIDOC-XML"]

        #expect(!mimeTypeDecoder.isElementFound(named: elementName, attributes: attributes))
    }

    @Test
    func isDdoc_success() {
        mimeTypeDecoder.handleFoundElement(named: "SignedDoc")

        #expect(mimeTypeDecoder.isDdoc)
    }

    @Test
    func parse_success() {
        mockMimeTypeDecoderDelegate.isElementFoundHandler = { _, _ in
            return true
        }

        let xmlString = """
            <SignedDoc format="DIGIDOC-XML"></SignedDoc>
            """
        let xmlData = xmlString.data(using: .utf8) ?? Data()

        let result = mimeTypeDecoder.parse(xmlData: xmlData)

        #expect(result == .ddoc)
    }

    @Test
    func parse_returnNoneResultForUnknownElement() {
        let xmlString = """
            <OtherElement format="DIGIDOC-XML"></OtherElement>
            """
        let xmlData = xmlString.data(using: .utf8) ?? Data()

        let result = mimeTypeDecoder.parse(xmlData: xmlData)

        #expect(result == .none)
    }
}
