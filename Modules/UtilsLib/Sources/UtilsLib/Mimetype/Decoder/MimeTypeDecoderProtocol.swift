import Foundation

public protocol MimeTypeDecoderProtocol: AnyObject {
    func isElementFound(named elementName: String, attributes: [String: String]) -> Bool
    func handleFoundElement(named elementName: String)
    func parse(xmlData: Data) -> ContainerType
}
