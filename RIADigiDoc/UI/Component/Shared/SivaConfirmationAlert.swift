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

extension View {
    /// Presents the shared SiVa confirmation alert. `onConfirm(true)` maps to OK (send to SiVa),
    /// `onConfirm(false)` to Cancel. `onReadMore` runs after opening the "read more" URL (e.g. to dismiss a view).
    func sivaConfirmationAlert(
        isPresented: Binding<Bool>,
        onConfirm: @escaping (Bool) -> Void,
        onReadMore: (() -> Void)? = nil
    ) -> some View {
        modifier(
            SivaConfirmationAlertModifier(
                isPresented: isPresented,
                onConfirm: onConfirm,
                onReadMore: onReadMore
            )
        )
    }
}

private struct SivaConfirmationAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let onConfirm: (Bool) -> Void
    let onReadMore: (() -> Void)?

    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(\.openURL) private var openURL

    private var sivaMessage: String {
        languageSettings.localized("Siva message")
    }

    private var sivaMessageUrl: String {
        languageSettings.localized("Siva message url")
    }

    func body(content: Content) -> some View {
        content.alert(sivaMessage, isPresented: $isPresented) {
            Button(languageSettings.localized("OK")) {
                onConfirm(true)
            }
            Button(languageSettings.localized("Cancel")) {
                onConfirm(false)
            }
            Button(languageSettings.localized("Read more here")) {
                if let url = URL(string: sivaMessageUrl),
                   UIApplication.shared.canOpenURL(url) {
                    openURL(url)
                }
                onReadMore?()
            }
        }
    }
}
