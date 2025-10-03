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
}
