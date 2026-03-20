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

class XmlParser: NSObject, XMLParserDelegate {
    private let tslSequenceNumberElement = "TSLSequenceNumber"
    private var sequenceNumber: Int?
    private var currentElement = ""
    private var currentValue = ""

    func readSequenceNumber(from inputStream: InputStream) throws -> Int {
        let parser = XMLParser(stream: inputStream)
        parser.delegate = self
        let isSuccess = parser.parse()

        if isSuccess, let number = sequenceNumber {
            return number
        } else {
            throw TSLParserError.errorReadingVersion
        }
    }

    // swiftlint:disable unused_parameter
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName
        currentValue = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == tslSequenceNumberElement {
            currentValue += string
        }
    }

    // swiftlint:disable:next blanket_disable_command
    // swiftlint:disable unused_parameter
    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == tslSequenceNumberElement, let number = Int(
            currentValue
        ) {
            sequenceNumber = number
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        sequenceNumber = nil
    }
}
