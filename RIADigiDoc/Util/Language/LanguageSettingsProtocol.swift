import Foundation

/// @mockable
@MainActor
public protocol LanguageSettingsProtocol: Sendable {
    func getSelectedLanguage() -> String
    func setSelectedLanguage(newLanguageCode: String)
    func localized(_ key: String) -> String
}
