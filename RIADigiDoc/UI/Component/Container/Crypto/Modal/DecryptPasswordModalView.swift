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
import FactoryKit

struct DecryptPasswordModalView: View {
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @State private var password: String = ""

    let keyLabel: String
    let onDecrypt: (String) -> Void
    let onCancel: () -> Void

    private var passwordFieldTitle: String {
        languageSettings.localized("Crypto password field label")
    }

    var body: some View {
        PasswordModalCard {
            VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
                ViewThatFits(in: .vertical) {
                    dialogContent

                    ScrollView {
                        dialogContent
                    }
                }
                PasswordModalButtonRow(
                    cancelLabel: languageSettings.localized("Cancel"),
                    confirmLabel: languageSettings.localized("Decrypt"),
                    onCancel: onCancel,
                    onConfirm: { onDecrypt(password) }
                )
            }
        }
    }

    private var dialogContent: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
            PasswordModalTitleView(text: languageSettings.localized("Decrypt"))
            keyLabelSection
            passwordSection
        }
    }

    private var keyLabelTitle: String {
        languageSettings.localized("Crypto password key label")
    }

    private var keyLabelSection: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
            Text(verbatim: keyLabelTitle)
                .font(typography.bodyLarge)
                .foregroundStyle(theme.onSurfaceVariant)
                .accessibilityHidden(true)
            Text(verbatim: keyLabel)
                .font(typography.bodyLarge)
                .foregroundStyle(theme.onSurface)
                .fontWeight(.bold)
                .accessibilityLabel(Text(verbatim: "\(keyLabelTitle) \(keyLabel)"))
        }
    }

    private var passwordSection: some View {
        FloatingLabelTextField(
            title: passwordFieldTitle,
            placeholder: passwordFieldTitle,
            text: $password,
            isSecure: true,
            submitLabel: .done,
            identifier: "decryptPasswordInput"
        )
    }
}

#Preview {
    DecryptPasswordModalView(
        keyLabel: "Allkirjastamata lepingud 2026",
        onDecrypt: { _ in },
        onCancel: {}
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
