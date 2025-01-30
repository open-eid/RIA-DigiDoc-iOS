import Foundation

public protocol SignedContainerProtocol: Sendable {
    func getDataFiles() async -> [DataFileWrapper]
    func getSignatures() async -> [SignatureWrapper]
    func getContainerName() async -> String
    func getContainerMimetype() async -> String
}
