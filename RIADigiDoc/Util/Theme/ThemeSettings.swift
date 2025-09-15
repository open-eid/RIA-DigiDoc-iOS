import Foundation
import Combine

@MainActor
public final class ThemeSettings: ThemeSettingsProtocol, ObservableObject {
    @Published private(set) var selectedTheme: Theme = .system
    private let dataStore: DataStoreProtocol

    public init(
        dataStore: DataStoreProtocol
    ) {
        self.dataStore = dataStore
        Task {
            let raw = await dataStore.getSelectedTheme()
            self.selectedTheme = Theme(rawValue: raw) ?? .system
        }
    }

    // MARK: - Public Methods

    public func getSelectedTheme() -> Theme {
        return selectedTheme
    }

    public func setSelectedTheme(_ theme: Theme) async {
        selectedTheme = theme
        await dataStore.setSelectedTheme(theme.rawValue)
    }
}
