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

    public func setSelectedLanguage(newLanguageCode: String) async {
        selectedLanguage = newLanguageCode
        await dataStore.setSelectedLanguage(newLanguageCode: newLanguageCode)
    }

    public func localized(_ key: String, _ args: [CVarArg] = []) -> String {
        guard let path = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key
        }

        let format = bundle.localizedString(forKey: key, value: nil, table: nil)
        return String.localizedStringWithFormat(format, args)
    }

    // MARK: - Constants

    private enum DefaultValues {
        static let language = "en"
    }
}
