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

import SwiftUI

struct LanguageButtonChooserView<T: Equatable & Identifiable>: View {
    @Environment(LanguageSettings.self) private var languageSettings

    let options: [T]
    let titleKey: (T) -> String
    let onTap: (T) -> Void
    let accessibilityLabel: (T) -> String
    let accessibilityInputLabel: (T) -> String?

    init(
        options: [T],
        titleKey: @escaping (T) -> String,
        onTap: @escaping (T) -> Void,
        accessibilityLabel: @escaping (T) -> String,
        accessibilityInputLabel: @escaping (T) -> String?,
    ) {
        self.options = options
        self.titleKey = titleKey
        self.onTap = onTap
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityInputLabel = accessibilityInputLabel
    }

    var body: some View {
        VStack(
            spacing: Dimensions.Padding.MPadding,
            content: {
                ForEach(options, id: \.id) { option in
                    LanguageButton<T>(
                        title: languageSettings.localized(titleKey(option)),
                        onTap: { onTap(option) },
                        accessibilityLabel: accessibilityLabel(option),
                        accessibilityInputLabel: accessibilityInputLabel(option)
                    )
                }
            }
        )
    }
}
