// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import UtilsLib
import Foundation

@Observable
@MainActor
class LanguageChooserViewModel: LanguageChooserViewModelProtocol, Loggable {
    var selectedLanguage: String = "en"

    private let languageSettings: LanguageSettingsProtocol

    init(
        languageSettings: LanguageSettingsProtocol
    ) {
        self.languageSettings = languageSettings
        selectedLanguage = languageSettings.getSelectedLanguage()
    }

    func selectLanguage(code: String) async {
        selectedLanguage = code
        await languageSettings.setSelectedLanguage(newLanguageCode: code)
    }
}
