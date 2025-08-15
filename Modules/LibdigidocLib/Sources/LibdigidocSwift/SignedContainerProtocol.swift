import Foundation

/// @mockable
public protocol SignedContainerProtocol: Sendable {
    func getDataFiles() async -> [DataFileWrapper]
    func getSignatures() async -> [SignatureWrapper]
    func getContainerName() async -> String
    func getContainerMimetype() async -> String
    func getRawContainerFile() async -> URL?
    @discardableResult func renameContainer(to newName: String) async throws -> URL
    func saveDataFile(dataFile: DataFileWrapper) async throws -> URL
}
