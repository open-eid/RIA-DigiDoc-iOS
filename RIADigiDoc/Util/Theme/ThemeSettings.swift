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
public final class ThemeSettings: ThemeSettingsProtocol {
    private(set) var selectedTheme: Theme = .system
    private let dataStore: DataStoreProtocol

    public init(
        dataStore: DataStoreProtocol
    ) {
        self.dataStore = dataStore
        Task {
            let raw = await dataStore.getSelectedTheme()
            self.selectedTheme = Theme(rawValue: raw) ?? .system
        }
    }

    // MARK: - Public Methods

    public func getSelectedTheme() -> Theme {
        return selectedTheme
    }

    public func setSelectedTheme(_ theme: Theme) async {
        selectedTheme = theme
        await dataStore.setSelectedTheme(theme.rawValue)
    }
}
