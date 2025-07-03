import Foundation

/// @mockable
public protocol MimeTypeDecoderProtocol: Sendable {
    func parse(xmlData: Data) async -> ContainerType
}
