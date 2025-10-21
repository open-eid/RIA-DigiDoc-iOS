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
@testable import ConfigLib

final class TSLParserDelegateTests {
    private var parserDelegate: TSLParserDelegate!
    private var xmlParser: XMLParser!

    init() async throws {
        parserDelegate = TSLParserDelegate(sequenceNumberElement: "TSLSequenceNumber")
    }

    deinit {
        parserDelegate = nil
        xmlParser = nil
    }

    @Test
    func parser_successFindingSequenceNumber() async throws {
        let xmlString = """
        <root>
            <TSLSequenceNumber>123</TSLSequenceNumber>
        </root>
        """
        let xmlStringData = xmlString.data(using: .utf8)

        guard let data = xmlStringData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        xmlParser = XMLParser(data: data)
        xmlParser.delegate = parserDelegate

        xmlParser.parse()

        #expect(123 == parserDelegate.foundSequenceNumber)
    }

    @Test
    func parser_doesNotSetFoundSequenceNumberWhenNoSequenceNumber() async throws {
        let xmlString = """
        <root>
            <otherElement>456</otherElement>
        </root>
        """
        let xmlStringData = xmlString.data(using: .utf8)

        guard let data = xmlStringData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        xmlParser = XMLParser(data: data)
        xmlParser.delegate = parserDelegate

        xmlParser.parse()

        #expect(parserDelegate.foundSequenceNumber == nil)
    }

    @Test
    func parser_doesNotSetFoundSequenceNumberWhenSequenceNumberWithInvalidValue() async throws {
        let xmlString = """
        <root>
            <sequenceNumber>NotANumber</sequenceNumber>
        </root>
        """
        let xmlStringData = xmlString.data(using: .utf8)

        guard let data = xmlStringData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        xmlParser = XMLParser(data: data)
        xmlParser.delegate = parserDelegate

        xmlParser.parse()

        #expect(parserDelegate.foundSequenceNumber == nil)
    }
}
