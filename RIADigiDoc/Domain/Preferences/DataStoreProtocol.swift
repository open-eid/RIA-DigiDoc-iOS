/// @mockable
public protocol DataStoreProtocol: Sendable {
    // MARK: - Language Methods
    func getSelectedLanguage() async -> String
    func setSelectedLanguage(newLanguageCode: String) async

    // MARK: - Theme Methods
    func getSelectedTheme() async -> Int
    func setSelectedTheme(_ rawValue: Int) async

    // MARK: - Validation Service Settings Methods
    func getValidationServiceURL() async -> String
    func setValidationServiceURL(validationServiceURL: String) async
    func getValidationServiceOption() async -> ServicesSettingsOption
    func setValidationServiceOption(_ option: ServicesSettingsOption) async

    // MARK: - TSA URL Methods
    func getTSAUrl() async -> String
    func setTSAUrl(tsaUrl: String) async
    func getTSAUrlOption() async -> ServicesSettingsOption
    func setTSAUrlOption(_ option: ServicesSettingsOption) async

    // MARK: - Relying Party UUID Methods
    func getRelyingPartyUUID() async -> String
    func setRelyingPartyUUID(relyingPartyUUID: String) async
    func getRelyingPartyOption() async -> ServicesSettingsOption
    func setRelyingPartyOption(_ option: ServicesSettingsOption) async
}
