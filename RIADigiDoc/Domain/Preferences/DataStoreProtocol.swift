/// @mockable
public protocol DataStoreProtocol: Sendable {
    // MARK: - Language Methods
    func getSelectedLanguage() async -> String
    func setSelectedLanguage(newLanguageCode: String) async

    // MARK: - Theme Methods
    func getSelectedTheme() async -> Int
    func setSelectedTheme(_ rawValue: Int) async
}
