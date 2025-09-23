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

    // MARK: - Constants

    private enum DefaultValues {
        static let language = "en"
    }

    private enum Keys {
        static let selectedLanguage = "selectedLanguage"
        static let selectedTheme = "selectedTheme"
    }
}
