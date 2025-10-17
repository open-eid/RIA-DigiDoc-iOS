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

struct RadioButtonChooserView<T: Equatable & Identifiable>: View where T: Hashable {
    @AppTheme private var theme
    @EnvironmentObject private var languageSettings: LanguageSettings

    let options: [T]
    let isSelected: (T) -> Bool
    let titleKey: (T) -> String
    let onSelect: (T) -> Void
    let accessibilityLabel: (T, Bool) -> String
    let trailingSpacer: Bool
    let backgroundColor: Color?

    init(
        options: [T],
        isSelected: @escaping (T) -> Bool,
        titleKey: @escaping (T) -> String,
        onSelect: @escaping (T) -> Void,
        accessibilityLabel: @escaping (T, Bool) -> String,
        trailingSpacer: Bool = true,
        backgroundColor: Color? = nil
    ) {
        self.options = options
        self.isSelected = isSelected
        self.titleKey = titleKey
        self.onSelect = onSelect
        self.accessibilityLabel = accessibilityLabel
        self.trailingSpacer = trailingSpacer
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        VStack(
            spacing: Dimensions.Padding.ZeroPadding,
            content: {
                ForEach(options, id: \.id) { option in
                    RadioButtonRow<T>(
                        title: languageSettings.localized(titleKey(option)),
                        isSelected: isSelected(option),
                        onTap: { onSelect(option) },
                        accessibilityLabel: accessibilityLabel(option, isSelected(option))
                    )
                    Divider()
                }
                if trailingSpacer {
                    Spacer()
                }
            }
        )
        .background(backgroundColor ?? theme.surface)
    }
}
