import Foundation

protocol MimeTypeDecoderProtocol: AnyObject {
    func isElementFound(named elementName: String, attributes: [String: String]) -> Bool
    func handleFoundElement(named elementName: String)
}
