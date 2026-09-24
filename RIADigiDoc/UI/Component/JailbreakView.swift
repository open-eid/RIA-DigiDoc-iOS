// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct JailbreakView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        VStack {
            Spacer()

            Text(languageSettings.localized("This app cannot be used in jailbroken device"))
                .foregroundStyle(theme.onSurface)
                .font(typography.bodyLarge)
                .padding()

            Spacer()
        }
    }
}

#Preview {
    JailbreakView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
