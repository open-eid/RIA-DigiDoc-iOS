import Foundation

/// @mockable
public protocol ContainerWrapperProtocol: Sendable {
    func getVersion() async -> String
    func getSignatures() async -> [SignatureWrapper]
    func getDataFiles() async -> [DataFileWrapper]
    func getMimetype() async -> String
    func create(file: URL, dataFiles: [String]) async throws
    func open(containerFile: URL, isSivaConfirmed: Bool) async throws -> ContainerWrapper
    func addDataFiles(containerFile: URL, dataFiles: [URL]) async throws -> Bool
    func getContainer() async -> ContainerWrapper?
    func saveDataFile(containerFile: URL, dataFile: DataFileWrapper, to directory: URL?) async throws -> URL
}

extension ContainerWrapperProtocol {
    func saveDataFile(containerFile: URL, dataFile: DataFileWrapper) async throws -> URL {
        try await saveDataFile(containerFile: containerFile, dataFile: dataFile, to: nil)
    }
}
