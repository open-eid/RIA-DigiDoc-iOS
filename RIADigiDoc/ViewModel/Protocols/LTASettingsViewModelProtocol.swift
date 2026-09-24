// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

/// @mockable
@MainActor
public protocol LTASettingsViewModelProtocol: Sendable {
    var isDefaultLTAEnabled: Bool { get }

    func loadSettings() async
    func saveSettings() async
}
