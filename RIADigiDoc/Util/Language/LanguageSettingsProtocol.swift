import Foundation

/// @mockable
@MainActor
public protocol LanguageSettingsProtocol: Sendable {
    func getSelectedLanguage() -> String
    func setSelectedLanguage(newLanguageCode: String) async
    func localized(_ key: String, _ args: [CVarArg]) -> String
}

extension LanguageSettingsProtocol {
    func localized(_ key: String) -> String {
        return localized(key, [])
    }
}
