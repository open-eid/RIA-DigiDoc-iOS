// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct AccessibilityView: View {
    @AppTheme private var theme

    @Environment(LanguageSettings.self) private var languageSettings

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main home menu accessibility"),
            onLeftClick: {
                dismiss()
            },
            content: {
                ScrollView {
                    VStack(
                        spacing: Dimensions.Padding.MPadding,
                        content: {
                            AccessibilityHeader()
                            AccessibilityScreenReaderSection()
                            AccessibilityScreenMagnificationSection()
                        }
                    ).padding(.horizontal, Dimensions.Padding.SPadding)
                }
            }
        )
    }
}

// MARK: - Preview
#Preview {
    AccessibilityView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
