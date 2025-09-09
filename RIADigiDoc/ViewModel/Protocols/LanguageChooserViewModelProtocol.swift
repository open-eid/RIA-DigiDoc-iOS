/// @mockable
@MainActor
public protocol LanguageChooserViewModelProtocol: Sendable {
    // MARK: Published properties
    var selectedLanguage: String { get }

    // MARK: Actions
    func selectLanguage(code: String)
}
