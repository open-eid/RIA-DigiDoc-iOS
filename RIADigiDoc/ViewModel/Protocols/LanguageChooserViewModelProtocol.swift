// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

/// @mockable
@MainActor
public protocol LanguageChooserViewModelProtocol: Sendable {
    // MARK: Published properties
    var selectedLanguage: String { get }

    // MARK: Actions
    func selectLanguage(code: String) async
}
