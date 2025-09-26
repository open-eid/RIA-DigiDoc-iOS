import Foundation

/// @mockable
public protocol AdvancedSettingsRepositoryProtocol: Sendable {
    func getCertificate(
        certificateFolder: String,
        certificateBaseName: String,
    ) async -> Data?

    func importCertificate(
        from url: URL,
        certificateFolder: String,
        certificateBaseName: String
    ) async -> Data?
}
