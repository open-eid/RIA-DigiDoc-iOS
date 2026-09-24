// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing
import CommonsTestShared
import UtilsLibMocks

@testable import UtilsLib

struct XMLParserHandlerTests {

    @Test
    func xmlParserHandler_parser_successWithValidDdocFormat() async {
        let xml = """
        <?xml version="1.0"?>
        <SignedDoc format="DIGIDOC-XML"></SignedDoc>
        """
        let data = Data(xml.utf8)

        let result = await withCheckedContinuation { (continuation: CheckedContinuation<ContainerType, Never>) in
            let handler = XMLParserHandler(continuation: continuation)
            let parser = XMLParser(data: data)
            parser.delegate = handler
            parser.parse()
        }

        #expect(result == .ddoc)
    }

    @Test
    func xmlParserHandler_parser_returnNoneResultWithWrongSignedDocFormat() async {
        let xml = """
        <?xml version="1.0"?>
        <SignedDoc format="WRONG-FORMAT"></SignedDoc>
        """
        let data = Data(xml.utf8)

        let result = await withCheckedContinuation { (continuation: CheckedContinuation<ContainerType, Never>) in
            let handler = XMLParserHandler(continuation: continuation)
            let parser = XMLParser(data: data)
            parser.delegate = handler
            parser.parse()
        }

        #expect(result == .none)
    }

    @Test
    func xmlParserHandler_parser_returnNoneResultWithNoSignedDocTag() async {
        let xml = """
        <?xml version="1.0"?>
        <OtherTag></OtherTag>
        """
        let data = Data(xml.utf8)

        let result = await withCheckedContinuation { (continuation: CheckedContinuation<ContainerType, Never>) in
            let handler = XMLParserHandler(continuation: continuation)
            let parser = XMLParser(data: data)
            parser.delegate = handler
            parser.parse()
        }

        #expect(result == .none)
    }

    @Test
    func xmlParserHandler_parser_returnsNoneResultWhenXMLIsMalformed() async {
        let xml = """
        <?xml version="1.0"?>
        <SignedDoc format="DIGIDOC-XML"
        """

        let data = Data(xml.utf8)

        let result = await withCheckedContinuation { (continuation: CheckedContinuation<ContainerType, Never>) in
            let handler = XMLParserHandler(continuation: continuation)
            let parser = XMLParser(data: data)
            parser.delegate = handler
            parser.parse()
        }

        #expect(result == .none)
    }
}
