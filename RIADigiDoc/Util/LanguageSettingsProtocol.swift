import Foundation

/// @mockable
public protocol LanguageSettingsProtocol: Sendable {
    var currentLanguage: String { get }
    func localized(_ key: String) -> String
}
