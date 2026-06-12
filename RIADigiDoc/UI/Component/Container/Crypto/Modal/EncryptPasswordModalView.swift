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

struct EncryptPasswordModalView: View {
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @State private var keyLabel: String = ""
    @State private var password: String = ""
    @State private var repeatPassword: String = ""

    let onEncrypt: (String, String, String) -> Void
    let onCancel: () -> Void

    private var keyLabelTitle: String { languageSettings.localized("Crypto password key label") }
    private var passwordTitle: String { languageSettings.localized("Crypto password field label") }
    private var repeatTitle: String { languageSettings.localized("Crypto password repeat label") }

    var body: some View {
        PasswordModalCard {
            VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                ScrollView {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
                        PasswordModalTitleView(text: languageSettings.localized("Encrypt with password"))
                        keyLabelSection
                        infoBox
                        passwordSection
                        repeatPasswordSection
                    }
                    .padding(.vertical, Dimensions.Padding.MSPadding)
                }
                PasswordModalButtonRow(
                    cancelLabel: languageSettings.localized("Cancel"),
                    confirmLabel: languageSettings.localized("Encrypt"),
                    onCancel: onCancel,
                    onConfirm: { onEncrypt(keyLabel, password, repeatPassword) }
                )
            }
            .frame(maxHeight: .infinity)
        }
    }

    private var keyLabelSection: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
            FloatingLabelTextField(
                title: keyLabelTitle,
                placeholder: keyLabelTitle,
                text: $keyLabel,
                submitLabel: .next,
                identifier: "passwordKeyLabel",
                accessibilityHint: languageSettings.localized("Crypto password key label description")
            )
            Text(verbatim: languageSettings.localized("Crypto password key label description"))
                .font(typography.labelMedium)
                .foregroundStyle(theme.onSecondaryContainer)
                .padding(.top, Dimensions.Padding.XXSPadding)
                .accessibilityHidden(true)
        }
    }

    private var infoBox: some View {
        HStack(alignment: .center, spacing: Dimensions.Padding.SPadding) {
            Image("ic_m3_info_48pt_wght400")
                .resizable()
                .scaledToFit()
                .frame(
                    width: Dimensions.Icon.IconSizeXXS,
                    height: Dimensions.Icon.IconSizeXXS
                )
                .foregroundStyle(theme.primary)
                .accessibilityHidden(true)

            Text(verbatim: languageSettings.localized("Crypto password save warning"))
                .font(typography.bodyLarge)
                .foregroundStyle(theme.onSurface)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Dimensions.Padding.SPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.Corner.XSCornerRadius)
                .fill(theme.surfaceVariant)
        )
    }

    private let requirementKeys = [
        "Crypto password length requirement",
        "Crypto password number requirement",
        "Crypto password uppercase requirement",
        "Crypto password lowercase requirement"
    ]

    private var requirementsAccessibilityLabel: String {
        ([languageSettings.localized("Password requirements")]
            + requirementKeys.map { languageSettings.localized($0) })
            .joined(separator: ". ")
            .replacingOccurrences(
                of: "–",
                with: " \(languageSettings.localized("Password range to accessibility")) "
            )
    }

    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.MSPadding) {
            FloatingLabelTextField(
                title: passwordTitle,
                placeholder: passwordTitle,
                text: $password,
                isSecure: true,
                submitLabel: .next,
                identifier: "passwordInput",
                sortPriority: 0
            )
            VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                ForEach(requirementKeys, id: \.self) { key in
                    requirementRow(key)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(verbatim: requirementsAccessibilityLabel))
            .accessibilitySortPriority(1)
        }
        .accessibilityElement(children: .contain)
    }

    private var repeatPasswordSection: some View {
        FloatingLabelTextField(
            title: repeatTitle,
            placeholder: repeatTitle,
            text: $repeatPassword,
            isSecure: true,
            submitLabel: .done,
            identifier: "repeatPasswordInput"
        )
    }

    private func requirementRow(_ key: String) -> some View {
        Text(verbatim: "• \(languageSettings.localized(key))")
            .font(typography.labelMedium)
            .foregroundStyle(theme.onSecondaryContainer)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    EncryptPasswordModalView(
        onEncrypt: { _, _, _ in },
        onCancel: {}
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
