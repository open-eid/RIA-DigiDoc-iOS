/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
