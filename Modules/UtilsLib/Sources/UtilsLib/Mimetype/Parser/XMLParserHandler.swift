import Foundation

class XMLParserHandler: NSObject, XMLParserDelegate {

    weak var delegate: MimeTypeDecoderProtocol?

    // swiftlint:disable:next blanket_disable_command
    // swiftlint:disable unused_parameter
    public func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String]
    ) {
        if delegate?.isElementFound(named: elementName, attributes: attributeDict) == true {
            delegate?.handleFoundElement(named: elementName)
        }
    }
}
