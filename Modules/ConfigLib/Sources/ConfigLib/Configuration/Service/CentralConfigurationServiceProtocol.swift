import Foundation
import Alamofire

/// @mockable
public protocol CentralConfigurationServiceProtocol: Sendable {
    func fetchConfiguration() async throws -> String
    func fetchPublicKey() async throws -> String
    func fetchSignature() async throws -> String
}
