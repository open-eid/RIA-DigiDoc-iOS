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
import CommonsLib

struct MobileIdView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var phoneNumber = Constants.MobileId.DefaultCountryCode
    @State private var personalCode = ""
    @State private var rememberMe: Bool = true
    @State private var isSigningEnabled = false
    @State private var isSigning: Bool = false

    let onSuccess: () -> Void

    var body: some View {
        SignatureInputScreen(
            isSigningEnabled: $isSigningEnabled,
            isSigning: $isSigning,
            onBackClick: {
                guard isSigning else {
                    dismiss()
                    return
                }
                isSigning = false
            },
            onSign: {
                print("Sign via Mobile-ID")
                isSigning = true
            }
        ) {
            if isSigning {
                ControlCodeView(
                    icon: "mobile_id_logo",
                    onSuccess: {
                        isSigning = false
                        dismiss()
                        self.onSuccess()
                    }
                )
            } else {
                MobileIdInputView(
                    phoneNumber: $phoneNumber,
                    personalCode: $personalCode,
                    rememberMe: $rememberMe,
                    onFieldChange: {
                        validateFields()
                    }
                )
            }
        }
    }

    private func validateFields() {
        isSigningEnabled = !phoneNumber.isEmpty && !personalCode.isEmpty
    }
}

#Preview {
    MobileIdView(onSuccess: {})
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
