/// @mockable
@MainActor
public protocol MobileIDSmartIDSettingsViewModelProtocol: Sendable {
    var relyingPartyUUID: String { get }
    var selectedOption: ServicesSettingsOption { get }

    func saveSettings() async
}
