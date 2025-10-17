import Foundation

/// @mockable
@MainActor
public protocol TimeStampSettingsViewModelProtocol: Sendable {
    var tsaUrl: String { get }
    var selectedOption: ServicesSettingsOption { get }
    var tsaCertData: Data? { get }
    var isImportingTSACert: Bool { get }
    var isLoading: Bool { get }

    // MARK: - Init helpers
    func initializeSettings() async

    // MARK: Saving
    func saveSettings() async

    // MARK: TSA Cert Info Getters
    func getTSACertIssuer() -> String
    func getTSACertNotValidAfter(expiredLabel: String) -> String

    // MARK: - TSA Cert Import
    func importTSACert(from url: URL) async

    // MARK: - Observer
    func observeConfigurationUpdates() async throws
    func removeObservers() async
}
