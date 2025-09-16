import Foundation

@objc public class CdocInfo: NSObject {
    @objc public let format: String
    @objc public let addressees: [Addressee]
    @objc public let dataFiles: [CryptoDataFile]

    public init(cdoc1Path path: String) throws {
        guard let parser = XMLParser(contentsOf: URL(fileURLWithPath: path)) else {
            NSLog("Error: Unable to read file at \(path)")
            throw NSError(domain: XMLParser.errorDomain, code: XMLParser.ErrorCode.internalError.rawValue, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create XML parser for file at \(path)"
            ])
        }
        let delegate = CdocParserDelegate()
        parser.externalEntityResolvingPolicy = .never
        parser.delegate = delegate;
        guard parser.parse() else {
            NSLog("Error: Failed to parse XML")
            throw parser.parserError!
        }
        format = delegate.format
        addressees = delegate.addressees
        dataFiles = delegate.dataFiles
    }
}

class CdocParserDelegate: NSObject, XMLParserDelegate {
    public var format = String()
    public var addressees: [Addressee] = []
    public var dataFiles: [CryptoDataFile] = []
    var data: String? = nil
    var attr = String()

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        switch elementName {
        case "ds:X509Certificate":
            data = String()
        case "denc:EncryptionProperty" where attributeDict["Name"] == "orig_file" || attributeDict["Name"] == "DocumentFormat":
            attr = attributeDict["Name"] ?? ""
            data = String()
        default: break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if data != nil {
            data! += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard data != nil else { return }
        switch (elementName, attr) {
        case ("ds:X509Certificate", _):
            if let data = Data(base64Encoded: data!, options: .ignoreUnknownCharacters) {
                addressees.append(Addressee(cert: data))
            }
        case ("denc:EncryptionProperty", "orig_file"):
            if let filename = data!.split(separator: "|").first {
                dataFiles.append(CryptoDataFile(filename: String(filename)))
            }
        case ("denc:EncryptionProperty", "DocumentFormat"):
            format = data!
        default: break
        }
        data = nil
    }
}
