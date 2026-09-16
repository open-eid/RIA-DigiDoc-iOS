/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
        guard format != key else { return key }

        return args.isEmpty ? format : String.localizedStringWithFormat(format, args)
    }

    // MARK: - Constants

    private enum DefaultValues {
        static let language = "en"
    }
}
