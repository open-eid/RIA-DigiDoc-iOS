import OSLog

@MainActor
class LanguageChooserViewModel: LanguageChooserViewModelProtocol, ObservableObject {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc", category: "LanguageChooserViewModel")

    @Published var selectedLanguage: String = "en"

    private let langaugeSettings: LanguageSettingsProtocol

    init(
        languageSettings: LanguageSettingsProtocol
    ) {
        self.langaugeSettings = languageSettings
        selectedLanguage = languageSettings.getSelectedLanguage()
    }

    func selectLanguage(code: String) {
        selectedLanguage = code
        langaugeSettings.setSelectedLanguage(newLanguageCode: code)
    }
}
