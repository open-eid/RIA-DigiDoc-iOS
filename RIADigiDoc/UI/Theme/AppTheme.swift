// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

@MainActor
@propertyWrapper
struct AppTheme: DynamicProperty {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeSettings.self) private var themeSettings

    var wrappedValue: ColorPalette {
        Theme.getCurrentColorPalette(for: colorScheme, currentTheme: themeSettings.getSelectedTheme())
    }
}
