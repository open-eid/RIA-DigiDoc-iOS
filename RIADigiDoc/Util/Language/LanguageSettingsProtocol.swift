// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
@MainActor
public protocol LanguageSettingsProtocol: Sendable {
    func loadSelectedLanguage() async
    func getSelectedLanguage() -> String
    func setSelectedLanguage(newLanguageCode: String) async
    func localized(_ key: String, _ args: [CVarArg]) -> String
}

extension LanguageSettingsProtocol {
    func localized(_ key: String) -> String {
        return localized(key, [])
    }
}
