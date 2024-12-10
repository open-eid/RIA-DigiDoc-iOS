import Foundation

public protocol ContainerWrapperProtocol: Sendable {
    func getSignatures() async -> [SignatureWrapper]
    func getDataFiles() async -> [DataFileWrapper]
    func getMimetype() async -> String
    func create(file: URL) async throws -> ContainerWrapper
    func open(containerFile: URL) async throws -> ContainerWrapper
    func addDataFiles(dataFiles: [URL?]) async throws
    func save(file: URL) async throws -> Bool
    func getContainer() async -> ContainerWrapper?
}
