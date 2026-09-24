// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

struct InputModal: View {
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme

    var icon: String?
    var title: String
    var placeholder: String
    @Binding var text: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ModalContainer(
            icon: icon,
            title: title,
            onConfirm: onConfirm,
            onCancel: onCancel
        ) {
            FloatingLabelTextField(
                title: languageSettings.localized("Container name"),
                placeholder: placeholder,
                text: $text,
                identifier: "renameContainerInput"
            )
        }
    }
}
