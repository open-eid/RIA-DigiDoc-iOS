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

final class XMLParserHandler: NSObject, XMLParserDelegate {

    private let continuation: CheckedContinuation<ContainerType, Never>
    private var didResume = false
    private var foundElement: ContainerType = .none

    init(continuation: CheckedContinuation<ContainerType, Never>) {
        self.continuation = continuation
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI _: String?,
        qualifiedName _: String?,
        attributes attributeDict: [String: String]
    ) {
        let formatAttribute = attributeDict["format"]
        let nameAttribute = attributeDict["Name"]
        if elementName == "SignedDoc", formatAttribute == "DIGIDOC-XML" || formatAttribute == "SK-XML" {
            foundElement = .ddoc
            parser.abortParsing()
        } else if elementName == "denc:EncryptionProperty" &&
                    nameAttribute == "DocumentFormat" {
            foundElement = .cdoc
            parser.abortParsing()
        }
    }

    // swiftlint:disable:next unused_parameter
    func parserDidEndDocument(_ parser: XMLParser) {
        resume(foundElement)
    }

    // swiftlint:disable:next unused_parameter
    func parser(_ parser: XMLParser, parseErrorOccurred error: Error) {
        resume(foundElement)
    }

    func finishIfNeeded() {
        resume(foundElement)
    }

    private func resume(_ value: ContainerType) {
        guard !didResume else { return }
        didResume = true
        continuation.resume(returning: value)
    }
}
