// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct RenameModalView: View {
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @State private var containerName: String
    @State private var keyboardHeight: CGFloat = 0
    let onConfirm: (String) -> Void
    let onCancel: () -> Void

    private var title: String {
        languageSettings.localized("Change container name")
    }

    private var placeholder: String {
        containerName.isEmpty ? languageSettings.localized("Container name") : containerName
    }

    init(
        containerName: String,
        onConfirm: @escaping (String) -> Void,
        onCancel: @escaping () -> Void,
    ) {
        self.containerName = containerName
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    var body: some View {
        ZStack {
            // Make the background darker to focus on the dialog
            Color.black
                .opacity(Dimensions.Shadow.LOpacity)
                .ignoresSafeArea()

            InputModal(
                icon: "ic_m3_edit_48pt_wght400",
                title: title,
                placeholder: placeholder,
                text: $containerName,
                onConfirm: { onConfirm(containerName) },
                onCancel: onCancel
            )
            .offset(y: -keyboardHeight / 2)
            .animation(.easeOut(duration: Dimensions.Duration.focusAnimation), value: keyboardHeight)
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        ) { notification in
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            keyboardHeight = frame.height
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }
}
