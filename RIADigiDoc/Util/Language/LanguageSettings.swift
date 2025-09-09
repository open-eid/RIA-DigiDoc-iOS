import Foundation

@MainActor
public final class LanguageSettings: LanguageSettingsProtocol, ObservableObject {
    @Published private(set) var selectedLanguage: String = DefaultValues.language
    private let dataStore: DataStoreProtocol

    public init(
        dataStore: DataStoreProtocol
    ) {
        self.dataStore = dataStore
        Task {
            self.selectedLanguage = await dataStore.getSelectedLanguage()
        }
    }

    // MARK: - Public Methods

    public func getSelectedLanguage() -> String {
        return selectedLanguage
    }

    public func setSelectedLanguage(newLanguageCode: String) {
        selectedLanguage = newLanguageCode
        Task {
            await dataStore.setSelectedLanguage(newLanguageCode: newLanguageCode)
        }
    }

    public func localized(_ key: String) -> String {
        if let path = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(key, tableName: nil, bundle: bundle, comment: "")
        }
        return key
    }

    // MARK: - Constants

    private enum DefaultValues {
        static let language = "en"
    }
}
