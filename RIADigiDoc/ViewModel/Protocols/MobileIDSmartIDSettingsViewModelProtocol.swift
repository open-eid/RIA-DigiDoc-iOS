// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib

/// @mockable
@MainActor
public protocol MobileIDSmartIDSettingsViewModelProtocol: Sendable {
    var relyingPartyUUID: String { get }
    var selectedOption: ServicesSettingsOption { get }

    func loadSettings() async
    func saveSettings() async
}
