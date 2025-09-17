import Foundation

/// @mockable
public protocol ContainerUtilProtocol: Sendable {
    func getSignatureContainerFile(for fileURL: URL, in directory: URL) -> URL
    func getContainerDataFilesDir(containerFile: URL?) throws -> URL
    func getSignatureContainersDir() throws -> URL
}
