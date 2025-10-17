import Foundation
import OSLog

@objc public class CdocInfo: NSObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "CdocInfo")

    @objc public let format: String
    @objc public let addressees: [Addressee]
    @objc public let dataFiles: [CryptoDataFile]

    public init(cdoc1Path path: String) throws {
        guard let parser = XMLParser(contentsOf: URL(fileURLWithPath: path)) else {
            CdocInfo.logger.error("Error: Unable to read file at \(path)")
            throw NSError(domain: XMLParser.errorDomain, code: XMLParser.ErrorCode.internalError.rawValue, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create XML parser for file at \(path)"
            ])
        }
        let delegate = CdocParserDelegate()
        parser.externalEntityResolvingPolicy = .never
        parser.delegate = delegate
        guard parser.parse() else {
            CdocInfo.logger.error("Error: Failed to parse XML")
            throw parser.parserError ?? NSError(
                domain: XMLParser.errorDomain,
                code: XMLParser.ErrorCode.internalError.rawValue,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unknown parsing error"
                ]
            )
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
    var data: String?
    var attr = String()

    func parser(
        _: XMLParser,
        didStartElement elementName: String,
        namespaceURI _: String?,
        qualifiedName _: String?,
        attributes attributeDict: [String: String]
    ) {
        switch elementName {
        case "ds:X509Certificate":
            data = String()
        case "denc:EncryptionProperty"
            where (attributeDict["Name"] == "orig_file"
                   || attributeDict["Name"] == "DocumentFormat"
            ):
            attr = attributeDict["Name"] ?? ""
            data = String()
        default: break
        }
    }

    func parser(_: XMLParser, foundCharacters string: String) {
        if var currentData = data {
            currentData += string
            data = currentData
        }
    }

    func parser(_: XMLParser, didEndElement elementName: String, namespaceURI _: String?, qualifiedName _: String?) {
        guard let currentData = data else { return }
        switch (elementName, attr) {
        case ("ds:X509Certificate", _):
            if let dataFromBase64 = Data(base64Encoded: currentData, options: .ignoreUnknownCharacters) {
                addressees.append(Addressee(cert: dataFromBase64))
            }
        case ("denc:EncryptionProperty", "orig_file"):
            if let filename = currentData.split(separator: "|").first {
                dataFiles.append(CryptoDataFile(filename: String(filename)))
            }
        case ("denc:EncryptionProperty", "DocumentFormat"):
            format = currentData
        default: break
        }
        data = nil
    }
}
