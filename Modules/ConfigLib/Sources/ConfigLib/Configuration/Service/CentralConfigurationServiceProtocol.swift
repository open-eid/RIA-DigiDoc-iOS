import Foundation
import Alamofire

public protocol CentralConfigurationServiceProtocol: Sendable {
    func fetchConfiguration() async throws -> String
    func fetchPublicKey() async throws -> String
    func fetchSignature() async throws -> String
}
