import Foundation

public struct MimeTypeDecoder: MimeTypeDecoderProtocol {

    public func parse(xmlData: Data) async -> ContainerType {
        await withCheckedContinuation { continuation in
            let parser = XMLParser(data: xmlData)
            let handler = XMLParserHandler(continuation: continuation)
            parser.delegate = handler
            parser.parse()
        } ? .ddoc : .none
    }
}
