import Foundation

/// @mockable
public protocol SignedContainerProtocol: Sendable, AnyObject {
    func getDataFiles() async -> [DataFileWrapper]
    func getSignatures() async -> [SignatureWrapper]
    func getTimestamps() async -> [SignatureWrapper]
    func getContainerName() async -> String
    func getContainerMimetype() async -> String
    func getRawContainerFile() async -> URL?
    @discardableResult func renameContainer(to newName: String) async throws -> URL
    func saveDataFile(
        dataFile: DataFileWrapper,
        to directory: URL?
    ) async throws -> URL
    func isExistingContainer() async -> Bool
    func getNestedTimestampedContainer() async throws -> SignedContainerProtocol?
}

extension SignedContainerProtocol {
    func saveDataFile(dataFile: DataFileWrapper) async throws -> URL {
        try await saveDataFile(dataFile: dataFile, to: nil)
    }
}
