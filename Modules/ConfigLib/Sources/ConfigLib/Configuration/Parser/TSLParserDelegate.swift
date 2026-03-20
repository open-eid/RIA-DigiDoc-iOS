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

class TSLParserDelegate: NSObject, XMLParserDelegate {
    private let sequenceNumberElements: [String]
    var currentElement: String?
    var foundSequenceNumber: Int?

    init(sequenceNumberElements: [String]) {
        self.sequenceNumberElements = sequenceNumberElements
    }

    // swiftlint:disable:next blanket_disable_command
    // swiftlint:disable unused_parameter
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName: String?,
        attributes: [String: String] = [:]
    ) {
        currentElement = elementName
        if sequenceNumberElements.contains(elementName) {
            parser.delegate = self
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if sequenceNumberElements.contains(currentElement ?? ""), let number = Int(string) {
            foundSequenceNumber = number
        }
    }
}
