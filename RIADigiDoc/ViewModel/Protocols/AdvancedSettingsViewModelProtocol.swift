// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

/// @mockable
@MainActor
public protocol AdvancedSettingsViewModelProtocol: Sendable {
    func restoreDefaultSettings() async
    func getIsRoleAndAddressEnabled() async -> Bool
    func setIsRoleAndAddressEnabled(_ isEnabled: Bool) async
}
