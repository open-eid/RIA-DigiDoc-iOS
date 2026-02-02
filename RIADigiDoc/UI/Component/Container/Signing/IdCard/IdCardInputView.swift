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

struct IdCardInputView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    @Binding var isActionEnabled: Bool

    @Binding var pinNumber: String
    @Binding var pinError: String?
    var pinType: CodeType?

    let onInputChange: () -> Void

    private var pinNumberTitle: String {
        languageSettings.localized("PIN code", [pinType?.name ?? ""])
    }

    init(
        isActionEnabled: Binding<Bool>,
        pinNumber: Binding<String>,
        pinError: Binding<String?>,
        pinType: CodeType?,
        onInputChange: @escaping () -> Void
    ) {
        self._isActionEnabled = isActionEnabled
        self._pinNumber = pinNumber
        self._pinError = pinError
        self.pinType = pinType
        self.onInputChange = onInputChange
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
                VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                    FloatingLabelTextField(
                        title: pinNumberTitle,
                        placeholder: pinNumberTitle,
                        text: $pinNumber,
                        isSecure: true,
                        isError: !(pinError?.isEmpty ?? true),
                        errorText: pinError ?? "",
                        keyboardType: .numberPad
                    )
                    .onChange(of: pinNumber) {
                        onInputChange()
                    }
                }
            }
            .padding(.vertical, Dimensions.Padding.MPadding)
        }
    }
}

#Preview {
    IdCardInputView(
        isActionEnabled: .constant(true),
        pinNumber: .constant("123"),
        pinError: .constant(nil),
        pinType: CodeType.pin2,
        onInputChange: {},
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
