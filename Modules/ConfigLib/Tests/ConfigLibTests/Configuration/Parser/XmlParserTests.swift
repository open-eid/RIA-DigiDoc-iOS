/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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

struct XmlParserTests {
    private let xmlParser: XmlParser!

    init() async throws {
        xmlParser = XmlParser()
    }

    @Test
    func readSequenceNumber_returnSequenceNumberWhenValidXml() async throws {
        let validXml = """
        <root>
            <TSLSequenceNumber>123</TSLSequenceNumber>
        </root>
        """
        let validXmlData = validXml.data(using: .utf8)

        guard let data = validXmlData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        let mockInputStream = InputStream(data: data)

        let result = try xmlParser.readSequenceNumber(from: mockInputStream)

        #expect(123 == result)
    }

    @Test
    func readSequenceNumber_throwErrorWhenNoSequenceNumber() async throws {
        let noSequenceNumberXml = """
        <root>
            <OtherElement>456</OtherElement>
        </root>
        """
        let noSequenceNumberXmlData = noSequenceNumberXml.data(using: .utf8)

        guard let data = noSequenceNumberXmlData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        let mockInputStream = InputStream(data: data)

        #expect(throws: TSLParserError.errorReadingVersion) {
            _ = try xmlParser.readSequenceNumber(from: mockInputStream)
        }
    }

    @Test
    func readSequenceNumber_throwErrorWhenInvalidXml() async throws {
        let invalidXml = """
        <root>
            <TSLSequenceNumber>123
        """
        let invalidXmlData = invalidXml.data(using: .utf8)

        guard let data = invalidXmlData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        let mockInputStream = InputStream(data: data)

        #expect(throws: TSLParserError.errorReadingVersion) {
            _ = try xmlParser.readSequenceNumber(from: mockInputStream)
        }
    }

    @Test
    func readSequenceNumber_throwErrorWhenSequenceNumberIsInvalid() async throws {
        let invalidSequenceNumberXml = """
        <root>
            <TSLSequenceNumber>InvalidNumber</TSLSequenceNumber>
        </root>
        """
        let invalidSequenceNumberXmlData = invalidSequenceNumberXml.data(using: .utf8)

        guard let data = invalidSequenceNumberXmlData else {
            Issue.record("Unable to get data from xml string")
            return
        }

        let mockInputStream = InputStream(data: data)

        #expect(throws: TSLParserError.errorReadingVersion) {
            _ = try xmlParser.readSequenceNumber(from: mockInputStream)
        }
    }
}
