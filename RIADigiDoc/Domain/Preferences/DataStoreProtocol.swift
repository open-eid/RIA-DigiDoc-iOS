/// @mockable
public protocol DataStoreProtocol: Sendable {
    func getSelectedLanguage() async -> String
    func setSelectedLanguage(newLanguageCode: String) async
}
