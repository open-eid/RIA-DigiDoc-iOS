import Foundation

/// @mockable
@MainActor
public protocol ValidationSettingsViewModelProtocol: Sendable {
    var validationServiceURL: String { get }
    var selectedOption: ServicesSettingsOption { get }
    var sivaCertData: Data? { get }
    var isImportingCert: Bool { get }
    var isLoading: Bool { get }

    // MARK: - Init helpers
    func initializeSettings() async

    // MARK: - Saving
    func saveSettings() async

    // MARK: - SiVa Cert Info Getters
    func getSiVaCertIssuer() -> String
    func getSiVaCertNotValidAfter(expiredLabel: String) -> String

    // MARK: - SiVa Cert Import
    func importSiVaCert(from url: URL) async

    // MARK: - Observer
    func observeConfigurationUpdates() async throws
    func removeObservers() async
}
