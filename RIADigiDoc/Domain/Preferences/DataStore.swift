import Foundation

public final actor DataStore: DataStoreProtocol {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Language Methods

    public func getSelectedLanguage() async -> String {
        return defaults.string(forKey: Keys.selectedLanguage) ?? DefaultValues.language
    }

    public func setSelectedLanguage(newLanguageCode: String) async {
        defaults.set(newLanguageCode, forKey: Keys.selectedLanguage)
    }

    // MARK: - Theme Methods

    public func getSelectedTheme() async -> Int {
        return defaults.integer(forKey: Keys.selectedTheme)
    }

    public func setSelectedTheme(_ rawValue: Int) async {
        defaults.set(rawValue, forKey: Keys.selectedTheme)
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
