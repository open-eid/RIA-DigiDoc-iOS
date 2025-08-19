import Foundation

public final class LanguageSettings: LanguageSettingsProtocol, ObservableObject {

    public var currentLanguage: String {
        if #available(iOS 16, *) {
            Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            Locale.current.languageCode ?? "en"
        }
    }

    public func localized(_ key: String) -> String {
        let language = currentLanguage
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(key, tableName: nil, bundle: bundle, comment: "")
        }
        return key
    }
}
