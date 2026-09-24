// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
        if elementName == "SignedDoc",
           formatAttribute == "DIGIDOC-XML" || formatAttribute == "SK-XML" {
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
