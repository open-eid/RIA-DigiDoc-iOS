import Foundation

public class MimeTypeDecoder: MimeTypeDecoderProtocol {

    weak var delegate: MimeTypeDecoderProtocol?

    var isDdoc: Bool = false

    func isElementFound(named elementName: String, attributes: [String: String]) -> Bool {
        if elementName == "SignedDoc", attributes["format"] == "DIGIDOC-XML" {
            return true
        }

        return false
    }

    func handleFoundElement(named elementName: String) {
        if elementName == "SignedDoc" {
            isDdoc = true
        }
    }

    public func parse(xmlData: Data) -> ContainerType {
        let parserHandler = XMLParserHandler()
        parserHandler.delegate = self

        let parser = XMLParser(data: xmlData)
        parser.delegate = parserHandler

        let success = parser.parse()

        if success && isDdoc {
            return .ddoc
        }

        return .none
    }
}
