// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

@Observable
@MainActor
public final class LanguageSettings: LanguageSettingsProtocol {
    private(set) var selectedLanguage: String = DefaultValues.language
    private let dataStore: DataStoreProtocol

    private var localizedBundle = Bundle.main.path(forResource: "en", ofType: "lproj").flatMap(Bundle.init)

    public let supportedLanguages: [SupportedLanguage] = [
        SupportedLanguage(code: "et", titleKey: "Init lang locale et", accessibilityInputLabel: "Estonian"),
        SupportedLanguage(code: "en", titleKey: "Init lang locale en", accessibilityInputLabel: "English")
    ]

    public init(
        dataStore: DataStoreProtocol
    ) {
        self.dataStore = dataStore
    }

    // MARK: - Public Methods

    public func loadSelectedLanguage() async {
        self.selectedLanguage = await dataStore.getSelectedLanguage()
        localizedBundle = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj").flatMap(Bundle.init)
    }

    public func getSelectedLanguage() -> String {
        return selectedLanguage
    }

    public func setSelectedLanguage(newLanguageCode: String) async {
        selectedLanguage = newLanguageCode
        localizedBundle = Bundle.main.path(forResource: newLanguageCode, ofType: "lproj").flatMap(Bundle.init)
        await dataStore.setSelectedLanguage(newLanguageCode: newLanguageCode)
    }

    public func localized(_ key: String, _ args: [CVarArg] = []) -> String {
        let bundle = localizedBundle ??
        Bundle.main.path(forResource: selectedLanguage, ofType: "lproj").flatMap(Bundle.init) ?? Bundle.main
        let format = bundle.localizedString(forKey: key, value: nil, table: nil)
        return args.isEmpty ? format : String.localizedStringWithFormat(format, args)
    }

    // MARK: - Constants

    private enum DefaultValues {
        static let language = "en"
    }
}
