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

import SwiftUI
import FactoryKit
import IdCardLib
import CommonsLib

struct IdCardInputView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    private var pinError: String?

    @Binding var isActionEnabled: Bool
    let personIdentifier: String
    @Binding var pinNumber: String
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

    private var pinLengthRequirementMessage: String {
        languageSettings.localized(
            "PIN length requirement",
            [pinType.name, String(pinType.minimumLength), String(Constants.Validation.PinMaximumLength)]
        )
    }

    private var isPinError: Bool {
        let hasPinErrorText = !(pinError?.isEmpty ?? true)

        let pinLength = pinNumber.count
        let isPinLengthInvalid =
            pinLength < pinType.minimumLength ||
            pinLength > Constants.Validation.PinMaximumLength

        return hasPinErrorText || isPinLengthInvalid
    }

    init(
        personIdentifier: String,
        isActionEnabled: Binding<Bool>,
        pinNumber: Binding<String>,
        actionType: ActionType,
        pinType: CodeType,
        onInputChange: @escaping () -> Void
    ) {
        self.personIdentifier = personIdentifier
        self._isActionEnabled = isActionEnabled
        self._pinNumber = pinNumber
        self.actionType = actionType
        self.pinType = pinType
        self.onInputChange = onInputChange
   }

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
            Text(verbatim: actionMessage)
                .font(typography.labelLarge)
                .foregroundStyle(theme.onSurfaceVariant)

            Text(verbatim: personIdentifier)
                .font(typography.bodyLarge)
                .foregroundStyle(theme.onSurface)

            FloatingLabelTextField(
                title: pinNumberTitle,
                placeholder: pinNumberTitle,
                text: $pinNumber,
                isSecure: true,
                isError: isPinError,
                errorText: pinError ?? "",
                keyboardType: .numberPad,
                identifier: "idCardPinNumberField"
            )
            .onChange(of: pinNumber) {
                onInputChange()
            }

            if isPinError {
                Text(verbatim: pinLengthRequirementMessage)
                    .font(typography.bodySmall)
                    .foregroundStyle(theme.error)
            }
        }
    }
}

#Preview {
    IdCardInputView(
        personIdentifier: "Test User, 12345678901",
        isActionEnabled: .constant(true),
        pinNumber: .constant("123"),
        actionType: .signing,
        pinType: CodeType.pin2,
        onInputChange: {},
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
