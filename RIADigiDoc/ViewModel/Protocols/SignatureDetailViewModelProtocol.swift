import Foundation

/// @mockable
@MainActor
public protocol SignatureDetailViewModelProtocol: Sendable {
    func getIssuerName(cert: Data) -> String
    func getSubjectName(cert: Data) -> String
}
