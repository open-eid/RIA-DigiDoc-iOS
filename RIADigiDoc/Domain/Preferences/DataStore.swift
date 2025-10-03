import Foundation

public final actor DataStore: DataStoreProtocol {
    public init() {}

    // MARK: - Language Methods

    public func getSelectedLanguage() async -> String {
        UserDefaults.standard.string(forKey: Keys.selectedLanguage) ?? DefaultValues.language
    }

    public func setSelectedLanguage(newLanguageCode: String) async {
        UserDefaults.standard.set(newLanguageCode, forKey: Keys.selectedLanguage)
    }

    // MARK: - Theme Methods

    public func getSelectedTheme() async -> Int {
        return UserDefaults.standard.integer(forKey: Keys.selectedTheme)
    }

    public func setSelectedTheme(_ rawValue: Int) async {
        UserDefaults.standard.set(rawValue, forKey: Keys.selectedTheme)
    }

    // MARK: - Validation Service Settings Methods

    public func getValidationServiceURL() async -> String {
        return UserDefaults.standard.string(forKey: Keys.validationServiceURL) ?? DefaultValues.validationServiceURL
    }

    public func setValidationServiceURL(validationServiceURL: String) async {
        UserDefaults.standard.set(validationServiceURL, forKey: Keys.validationServiceURL)
    }

    public func getValidationServiceOption() async -> ServicesSettingsOption {
        let raw = UserDefaults.standard.integer(forKey: Keys.validationServiceOption)
        return ServicesSettingsOption(rawValue: raw) ?? ServicesSettingsOption.defaultSetting
    }

    public func setValidationServiceOption(_ option: ServicesSettingsOption) async {
            UserDefaults.standard.set(option.rawValue, forKey: Keys.validationServiceOption)
    }

    // MARK: - Constants

    private enum DefaultValues {
        static let language = "en"
        static let validationServiceURL = ""
    }

    private enum Keys {
        static let selectedLanguage = "selectedLanguage"
        static let selectedTheme = "selectedTheme"
        static let validationServiceURL = "validationServiceURL"
        static let validationServiceOption = "validationServiceOption"
    }
}
