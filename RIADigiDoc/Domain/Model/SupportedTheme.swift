struct SupportedTheme: Identifiable, Equatable, Hashable {
    let themeKey: Theme
    let titleKey: String
    var id: Theme { themeKey }
}
