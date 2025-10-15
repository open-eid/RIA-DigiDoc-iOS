import Foundation

/// @mockable
@MainActor
public protocol ValidationSettingsViewModelProtocol: Sendable {
    var validationServiceURL: String { get }
    var selectedOption: ServicesSettingsOption { get }
    var sivaCertData: Data? { get }
    var isImportingCert: Bool { get }
    var isLoading: Bool { get }

    // MARK: - Saving
    func saveSettings() async

    // MARK: - SiVa Cert Info Getters
    func getSiVaCertIssuer(testCert: Data?) -> String
    func getSiVaCertNotValidAfter(expiredLabel: String, testCert: Data?) -> String

    // MARK: - SiVa Cert Import
    func importSiVaCert(from url: URL) async

    func removeObservers() async
}
