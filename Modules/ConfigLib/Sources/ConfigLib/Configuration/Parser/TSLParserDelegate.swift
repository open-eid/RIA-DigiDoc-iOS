import Foundation

class TSLParserDelegate: NSObject, XMLParserDelegate {
    private let sequenceNumberElement: String
    var currentElement: String?
    var foundSequenceNumber: Int?

    init(sequenceNumberElement: String) {
        self.sequenceNumberElement = sequenceNumberElement
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
        if elementName == sequenceNumberElement {
            parser.delegate = self
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == sequenceNumberElement, let number = Int(string) {
            foundSequenceNumber = number
        }
    }
}
