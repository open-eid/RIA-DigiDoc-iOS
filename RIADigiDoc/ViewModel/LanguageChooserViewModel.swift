import OSLog

@MainActor
class LanguageChooserViewModel: LanguageChooserViewModelProtocol, ObservableObject {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc", category: "LanguageChooserViewModel")

    @Published var selectedLanguage: String = "en"

    private let languageSettings: LanguageSettingsProtocol

    init(
        languageSettings: LanguageSettingsProtocol
    ) {
        self.languageSettings = languageSettings
        selectedLanguage = languageSettings.getSelectedLanguage()
    }

    func selectLanguage(code: String) {
        selectedLanguage = code
        languageSettings.setSelectedLanguage(newLanguageCode: code)
    }
}
