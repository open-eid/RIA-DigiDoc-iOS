import Foundation
import LibdigidocLibSwift

/// @mockable
public protocol SivaRepositoryProtocol: Sendable {
    func isSivaConfirmationNeeded(files: [URL]) async -> Bool
    func isTimestampedContainer(signedContainer: SignedContainerProtocol) async -> Bool
    func getTimestampedContainer(
        parentContainer: SignedContainerProtocol
    ) async throws -> SignedContainerProtocol
}
