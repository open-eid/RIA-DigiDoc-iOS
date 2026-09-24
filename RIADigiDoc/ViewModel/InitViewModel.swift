// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import UtilsLib
import Foundation

@MainActor
class InitViewModel: InitViewModelProtocol, ObservableObject, Loggable {
    private let languageSettings: LanguageSettingsProtocol
    private let dataStore: DataStoreProtocol

    init(
        languageSettings: LanguageSettingsProtocol,
        dataStore: DataStoreProtocol
    ) {
        self.languageSettings = languageSettings
        self.dataStore = dataStore
    }

    func selectLanguage(code: String) async {
        await languageSettings.setSelectedLanguage(newLanguageCode: code)
        await dataStore.setIsInitialLanguageSelected(true)
    }
}
