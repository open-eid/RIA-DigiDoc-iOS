struct SupportedLanguage: Identifiable, Equatable, Hashable {
    let code: String
    let titleKey: String
    var id: String { code }
}
