/// @mockable
@MainActor
public protocol ThemeSettingsProtocol: Sendable {
    func getSelectedTheme() -> Theme
    func setSelectedTheme(_ theme: Theme) async
}
