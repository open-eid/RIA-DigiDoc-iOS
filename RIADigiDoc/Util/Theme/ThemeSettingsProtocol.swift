// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

/// @mockable
@MainActor
public protocol ThemeSettingsProtocol: Sendable {
    func getSelectedTheme() -> Theme
    func setSelectedTheme(_ theme: Theme) async
}
