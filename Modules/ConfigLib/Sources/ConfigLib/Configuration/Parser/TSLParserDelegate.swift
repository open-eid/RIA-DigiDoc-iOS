// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
