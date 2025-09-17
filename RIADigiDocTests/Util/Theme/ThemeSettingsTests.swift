import Testing

struct ThemeSettingsTests {
    private let mockDataStore: DataStoreProtocolMock

    private let themeSettings: ThemeSettingsProtocol

    init() async {
        mockDataStore = DataStoreProtocolMock()

        themeSettings = await ThemeSettings(dataStore: mockDataStore)
    }

    // MARK: - Tests

    @Test
    func getSelectedTheme_success() async throws {
        let allowedThemeRawValues: [Theme] = [Theme.light, Theme.dark, Theme.system]
        let selectedTheme: Theme = await themeSettings.getSelectedTheme()
        #expect(allowedThemeRawValues.contains(selectedTheme))
    }

    @Test
    func setSelectedTheme_success() async throws {
        let testTheme: Theme = Theme.dark
        await themeSettings.setSelectedTheme(testTheme)
        #expect(mockDataStore.setSelectedThemeCallCount == 1)
    }
}
