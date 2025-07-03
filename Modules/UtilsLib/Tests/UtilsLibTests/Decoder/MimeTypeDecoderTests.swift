import Foundation
import Testing
import CommonsTestShared
import UtilsLibMocks

@testable import UtilsLib

struct MimeTypeDecoderTests {
    private let mimeTypeDecoder: MimeTypeDecoder!

    init() async throws {
        mimeTypeDecoder = MimeTypeDecoder()
    }

    @Test
    func mimeTypeDecoder_parse_successReturningDdocWithValidDdocFormat() async {
        let xml = """
            <?xml version="1.0"?>
            <SignedDoc format="DIGIDOC-XML"></SignedDoc>
            """
        let data = Data(xml.utf8)

        let result = await mimeTypeDecoder.parse(xmlData: data)

        #expect(result == .ddoc)
    }

    @Test
    func mimeTypeDecoder_parse_successReturningNoneWithWrongFormat() async {
        let xml = """
            <?xml version="1.0"?>
            <SignedDoc format="WRONG-FORMAT"></SignedDoc>
            """
        let data = Data(xml.utf8)

        let result = await mimeTypeDecoder.parse(xmlData: data)

        #expect(result == .none)
    }

    @Test
    func mimeTypeDecoder_parse_returnNoneWithNoSignedDocTag() async {
        let xml = """
            <?xml version="1.0"?>
            <OtherTag></OtherTag>
            """
        let data = Data(xml.utf8)

        let result = await mimeTypeDecoder.parse(xmlData: data)

        #expect(result == .none)
    }

    @Test
    func mimeTypeDecoder_parse_returnsNoneWhenXMLIsMalformed() async {
        let xml = """
            <?xml version="1.0"?>
            <SignedDoc format="DIGIDOC-XML"
            """

        let data = Data(xml.utf8)

        let result = await mimeTypeDecoder.parse(xmlData: data)

        #expect(result == .none)
    }
}
