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
