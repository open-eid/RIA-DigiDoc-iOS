import Foundation
import Testing
import CommonsTestShared
import UtilsLibMocks

@testable import UtilsLib

import Foundation

struct XMLParserHandlerTests {

    @Test
    func xmlParserHandler_parser_successWithValidDdocFormat() async {
        let xml = """
        <?xml version="1.0"?>
        <SignedDoc format="DIGIDOC-XML"></SignedDoc>
        """
        let data = Data(xml.utf8)

        let result = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            let handler = XMLParserHandler(continuation: continuation)
            let parser = XMLParser(data: data)
            parser.delegate = handler
            parser.parse()
        }

        #expect(result == true)
    }

    @Test
    func xmlParserHandler_parser_returnFalseWithWrongSignedDocFormat() async {
        let xml = """
        <?xml version="1.0"?>
        <SignedDoc format="WRONG-FORMAT"></SignedDoc>
        """
        let data = Data(xml.utf8)

        let result = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            let handler = XMLParserHandler(continuation: continuation)
            let parser = XMLParser(data: data)
            parser.delegate = handler
            parser.parse()
        }

        #expect(result == false)
    }

    @Test
    func xmlParserHandler_parser_returnFalseWithNoSignedDocTag() async {
        let xml = """
        <?xml version="1.0"?>
        <OtherTag></OtherTag>
        """
        let data = Data(xml.utf8)

        let result = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            let handler = XMLParserHandler(continuation: continuation)
            let parser = XMLParser(data: data)
            parser.delegate = handler
            parser.parse()
        }

        #expect(result == false)
    }

    @Test
    func xmlParserHandler_parser_returnsFalseWhenXMLIsMalformed() async {
        let xml = """
        <?xml version="1.0"?>
        <SignedDoc format="DIGIDOC-XML"
        """

        let data = Data(xml.utf8)

        let result = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            let handler = XMLParserHandler(continuation: continuation)
            let parser = XMLParser(data: data)
            parser.delegate = handler
            parser.parse()
        }

        #expect(result == false)
    }
}
