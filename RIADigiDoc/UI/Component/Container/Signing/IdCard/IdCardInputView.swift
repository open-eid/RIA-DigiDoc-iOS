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
import IdCardLib
import CommonsLib

struct IdCardInputView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    @AccessibilityFocusState private var isActionMessageFocused: Bool

    let personIdentifier: String
    @Binding var pinNumber: String
    @Binding var pinError: String
    var actionType: ActionType
    var pinType: CodeType

    let onInputChange: () -> Void

    private var pinNumberTitle: String {
        languageSettings.localized("PIN code", [pinType.name])
    }

    private var actionMessage: String {
        let messageKey = actionType == .decrypt
            ? "Ready to decrypt message"
            : "Ready to sign message"

        return languageSettings.localized(messageKey)
    }

    private var isPinError: Bool {
        !pinError.isEmpty
    }

    init(
        personIdentifier: String,
        pinNumber: Binding<String>,
        pinError: Binding<String>,
        actionType: ActionType,
        pinType: CodeType,
        onInputChange: @escaping () -> Void
    ) {
        self.personIdentifier = personIdentifier
        self._pinNumber = pinNumber
        self._pinError = pinError
        self.actionType = actionType
        self.pinType = pinType
        self.onInputChange = onInputChange
   }

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
            Text(verbatim: actionMessage)
                .font(typography.labelLarge)
                .foregroundStyle(theme.onSurfaceVariant)
                .accessibilityFocused($isActionMessageFocused)

            Text(verbatim: personIdentifier)
                .font(typography.bodyLarge)
                .foregroundStyle(theme.onSurface)

            FloatingLabelTextField(
                title: pinNumberTitle,
                placeholder: pinNumberTitle,
                text: $pinNumber,
                isSecure: true,
                isError: isPinError,
                keyboardType: .numberPad,
                identifier: "idCardPinNumberField"
            )
            .onChange(of: pinNumber) {
                onInputChange()
            }

            if isPinError {
                Text(verbatim: pinError)
                    .font(typography.bodySmall)
                    .foregroundStyle(theme.error)
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                isActionMessageFocused = true
            }
        }
    }
}

#Preview {
    IdCardInputView(
        personIdentifier: "Test User, 12345678901",
        pinNumber: .constant("123"),
        pinError: .constant("PIN length requirement"),
        actionType: .signing,
        pinType: CodeType.pin2,
        onInputChange: {},
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
