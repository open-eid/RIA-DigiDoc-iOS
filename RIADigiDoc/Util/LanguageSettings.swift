import Foundation

final class LanguageSettings: LanguageSettingsProtocol, ObservableObject {

    var currentLanguage: String {
        Locale.current.languageCode ?? "en"
    }

    func localized(_ key: String) -> String {
        let language = currentLanguage
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(key, tableName: nil, bundle: bundle, comment: "")
        }
        return key
    }
}
