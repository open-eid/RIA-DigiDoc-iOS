import Foundation

public final actor DataStore: DataStoreProtocol {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Public Methods

    public func getSelectedLanguage() async -> String {
        return defaults.string(forKey: Keys.selectedLanguage) ?? DefaultValues.language
    }

    public func setSelectedLanguage(newLanguageCode: String) async {
        defaults.set(newLanguageCode, forKey: Keys.selectedLanguage)
    }

    // MARK: - Constants

    private enum DefaultValues {
        static let language = "en"
    }

    private enum Keys {
        static let selectedLanguage = "selectedLanguage"
    }
}
