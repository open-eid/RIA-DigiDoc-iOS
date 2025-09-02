import CommonsLib
import Foundation

/// @mockable
public protocol TSLUtilProtocol: Sendable {
    func setupTSLFiles(
        tsls: [String],
        destinationDir: URL,
    ) throws

    func readSequenceNumber(from inputStreamURL: URL) throws -> Int
}
