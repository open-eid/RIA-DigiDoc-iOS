// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
