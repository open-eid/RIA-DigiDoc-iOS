/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

@MainActor
public final class LanguageSettings: LanguageSettingsProtocol, ObservableObject {
    @Published private(set) var selectedLanguage: String = DefaultValues.language
    private let dataStore: DataStoreProtocol

    public init(
        dataStore: DataStoreProtocol
    ) {
        self.dataStore = dataStore
        Task {
            self.selectedLanguage = await dataStore.getSelectedLanguage()
        }
    }

    // MARK: - Public Methods

    public func getSelectedLanguage() -> String {
        return selectedLanguage
    }

    public func setSelectedLanguage(newLanguageCode: String) async {
        selectedLanguage = newLanguageCode
        await dataStore.setSelectedLanguage(newLanguageCode: newLanguageCode)
    }

    public func localized(_ key: String, _ args: [CVarArg] = []) -> String {
        guard let path = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key
        }

        let format = bundle.localizedString(forKey: key, value: nil, table: nil)
        return String.localizedStringWithFormat(format, args)
    }

    // MARK: - Constants

    private enum DefaultValues {
        static let language = "en"
    }
}
