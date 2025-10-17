import CommonsLib
import OSLog

@MainActor
class MobileIDSmartIDSettingsViewModel: MobileIDSmartIDSettingsViewModelProtocol,
                                        ObservableObject {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc", category: "MobileIDAndSmartIDServicesSettingsViewModel")

    @Published var relyingPartyUUID: String = ""
    @Published var selectedOption: ServicesSettingsOption = .defaultSetting

    private let dataStore: DataStoreProtocol

    init(
        dataStore: DataStoreProtocol
    ) {
        self.dataStore = dataStore

        Task {
            await loadSettings()
        }
    }

    // MARK: - Loading

    public func loadSettings() async {
        self.relyingPartyUUID = await dataStore.getRelyingPartyUUID()
        self.selectedOption = await dataStore.getRelyingPartyOption()
    }

    // MARK: - Setters

    public func saveSettings() async {
        await dataStore.setRelyingPartyOption(selectedOption)
        relyingPartyUUID = relyingPartyUUID.trimmingCharacters(in: .whitespacesAndNewlines)

        if selectedOption == .defaultSetting || relyingPartyUUID.isEmpty {
            relyingPartyUUID = Constants.Configuration.RelyingPartyUUID
        }

        await dataStore.setRelyingPartyUUID(relyingPartyUUID: relyingPartyUUID)
    }
}
