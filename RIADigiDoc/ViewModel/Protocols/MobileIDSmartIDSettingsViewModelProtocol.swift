/// @mockable
@MainActor
public protocol MobileIDSmartIDSettingsViewModelProtocol: Sendable {
    var relyingPartyUUID: String { get }
    var selectedOption: ServicesSettingsOption { get }

    func loadSettings() async
    func saveSettings() async
}
