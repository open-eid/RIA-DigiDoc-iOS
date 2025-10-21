/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

import FactoryKit
import SwiftUI

struct ThemeChooserView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageSettings: LanguageSettings
    @EnvironmentObject private var themeSettings: ThemeSettings

    private let supportedThemes: [SupportedTheme] = [
        SupportedTheme(themeKey: .system, titleKey: "Main settings theme system"),
        SupportedTheme(themeKey: .light, titleKey: "Main settings theme light"),
        SupportedTheme(themeKey: .dark, titleKey: "Main settings theme dark")
    ]

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main settings menu appearance"),
            onLeftClick: {
                dismiss()
            },
            excludeDestinations: [.theme],
            content: {
                RadioButtonChooserView<SupportedTheme>(
                    options: supportedThemes,
                    isSelected: { themeOption in
                        themeOption.themeKey == themeSettings.getSelectedTheme()
                    },
                    titleKey: { themeOption in themeOption.titleKey },
                    onSelect: { themeOption in
                        Task {await themeSettings.setSelectedTheme(themeOption.themeKey)}
                    },
                    accessibilityLabel: { themeOption, isSelected in
                        let title = languageSettings.localized(themeOption.titleKey)
                        let selected = isSelected
                        ? languageSettings.localized("Menu theme selected")
                        : languageSettings.localized("Menu theme")
                        return "\(title) \(selected)"
                    }
                )
            }
        )
    }
}

// MARK: - Preview
#Preview {
    ThemeChooserView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
