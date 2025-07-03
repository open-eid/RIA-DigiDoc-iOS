import Foundation

class XMLParserHandler: NSObject, XMLParserDelegate {
    private var continuation: CheckedContinuation<Bool, Never>?
    private var foundElement = false

    init(continuation: CheckedContinuation<Bool, Never>) {
        self.continuation = continuation
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes attributeDict: [String: String]) {
        if elementName == "SignedDoc", attributeDict["format"] == "DIGIDOC-XML" {
            foundElement = true
            continuation?.resume(returning: true)
            continuation = nil
            parser.abortParsing()
        }
    }

    func parserDidEndDocument(_: XMLParser) {
        if continuation != nil {
            continuation?.resume(returning: foundElement)
            continuation = nil
        }
    }

    func parser(_: XMLParser, parseErrorOccurred _: Error) {
        if continuation != nil {
            continuation?.resume(returning: foundElement)
            continuation = nil
        }
    }
}
