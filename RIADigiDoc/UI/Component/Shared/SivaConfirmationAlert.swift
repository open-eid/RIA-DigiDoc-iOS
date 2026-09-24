// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
