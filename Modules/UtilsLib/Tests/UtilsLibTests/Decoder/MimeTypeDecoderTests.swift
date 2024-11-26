import Foundation
import Testing
import Cuckoo
@testable import UtilsLib

final class MimeTypeDecoderTests {

    var mockMimeTypeDecoderDelegate: MockMimeTypeDecoderProtocol!
    var mimeTypeDecoder: MimeTypeDecoder!

    init() async throws {
        await UtilsLibAssembler.shared.initialize()

        mockMimeTypeDecoderDelegate = MockMimeTypeDecoderProtocol()
        mimeTypeDecoder = MimeTypeDecoder()
        mimeTypeDecoder.delegate = mockMimeTypeDecoderDelegate
    }

    deinit {
        mockMimeTypeDecoderDelegate = nil
        mimeTypeDecoder = nil
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
        stub(mockMimeTypeDecoderDelegate) { mockDelegate in
            when(mockDelegate.isElementFound(named: anyString(), attributes: any())).thenReturn(true)
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
