import CommonsLib
import Foundation
import Testing

@MainActor
final class MobileIDSmartIDSettingsViewModelTests {
    private let viewModel: MobileIDSmartIDSettingsViewModel!

    private let mockDataStore: DataStoreProtocolMock!

    init() {
        mockDataStore = DataStoreProtocolMock()

        mockDataStore.getRelyingPartyUUIDHandler = {
            return "12300000-0000-0000-0000-000000000000"
        }
        mockDataStore.getRelyingPartyOptionHandler = {
            return .defaultSetting
        }

        viewModel = MobileIDSmartIDSettingsViewModel(dataStore: mockDataStore)
    }

    // MARK: - Tests

    @Test
    func saveSettings_successDefaultSetting() async throws {
        viewModel.selectedOption = .defaultSetting
        let testUUID = "00000000-0000-0000-0000-000000000001"
        viewModel.relyingPartyUUID = testUUID

        await viewModel.saveSettings()

        #expect(mockDataStore.setRelyingPartyUUIDCallCount == 1)
        #expect(mockDataStore.setRelyingPartyOptionCallCount == 1)

        #expect(viewModel.relyingPartyUUID != testUUID)
    }

    @Test
    func saveSettings_successWithManualSettingWithEmptyString() async throws {
        await viewModel.loadSettings()

        viewModel.selectedOption = .manualSetting
        let testUUID = ""
        viewModel.relyingPartyUUID = testUUID

        await viewModel.saveSettings()

        #expect(mockDataStore.setRelyingPartyUUIDCallCount == 1)
        #expect(mockDataStore.setRelyingPartyOptionCallCount == 1)

        #expect(viewModel.relyingPartyUUID == Constants.Configuration.RelyingPartyUUID)
    }

    @Test
    func saveSettings_successWithManualSettingWithValidUUID() async throws {
        mockDataStore.getRelyingPartyOptionHandler = {
            return .manualSetting
        }

        await viewModel.loadSettings()

        viewModel.selectedOption = .manualSetting
        let testUUID = "00000000-0000-0000-0000-000000000001"
        viewModel.relyingPartyUUID = testUUID

        await viewModel.saveSettings()

        #expect(mockDataStore.setRelyingPartyUUIDCallCount == 1)
        #expect(mockDataStore.setRelyingPartyOptionCallCount == 1)

        #expect(viewModel.relyingPartyUUID == testUUID)
    }
}
