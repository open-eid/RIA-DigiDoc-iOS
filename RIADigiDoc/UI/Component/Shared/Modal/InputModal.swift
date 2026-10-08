// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import UtilsLib

struct InputModal: View {
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme

    var icon: String?
    var title: String
    var placeholder: String
    @Binding var text: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    private var isNameEntered: Bool {
        text.sanitizedOrNil() != nil
    }

    var body: some View {
        ModalContainer(
            icon: icon,
            title: title,
            isConfirmButtonEnabled: isNameEntered,
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
