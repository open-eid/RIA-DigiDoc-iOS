import Foundation

public protocol CentralConfigurationRepositoryProtocol: Sendable {
    func fetchConfiguration() async throws -> String
    func fetchPublicKey() async throws -> String
    func fetchSignature() async throws -> String
}
