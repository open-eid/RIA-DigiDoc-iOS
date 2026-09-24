// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import FactoryKit
import SwiftUI

struct RadioButtonChooserView<T: Equatable & Identifiable>: View where T: Hashable {
    @AppTheme private var theme
    @Environment(LanguageSettings.self) private var languageSettings

    let options: [T]
    let isSelected: (T) -> Bool
    let titleKey: (T) -> String
    let onSelect: (T) -> Void
    let accessibilityLabel: (T, Bool) -> String
    let accessibilityInputLabel: (T) -> String?
    let trailingSpacer: Bool

    init(
        options: [T],
        isSelected: @escaping (T) -> Bool,
        titleKey: @escaping (T) -> String,
        onSelect: @escaping (T) -> Void,
        accessibilityLabel: @escaping (T, Bool) -> String,
        accessibilityInputLabel: @escaping (T) -> String? = {_ in nil},
        trailingSpacer: Bool = true,
    ) {
        self.options = options
        self.isSelected = isSelected
        self.titleKey = titleKey
        self.onSelect = onSelect
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityInputLabel = accessibilityInputLabel
        self.trailingSpacer = trailingSpacer
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
                        accessibilityLabel: accessibilityLabel(option, isSelected(option)),
                        accessibilityInputLabel: accessibilityInputLabel(option)
                    )
                    .accessibilityIdentifier(String(describing: option))
                    Divider()
                }
                if trailingSpacer {
                    Spacer()
                }
            }
        )
    }
}
