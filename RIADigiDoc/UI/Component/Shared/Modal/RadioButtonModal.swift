// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

public struct RadioButtonModal<Option: Identifiable & Hashable>: View {
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @State private var selectedOption: Option

    private var icon: String?
    private var title: String
    private var options: [Option]
    private var titleKeyPath: KeyPath<Option, String>
    private var confirmButtonTitle: String
    private var onConfirm: (Option) -> Void
    private var onCancel: () -> Void

    init(
        icon: String? = nil,
        title: String,
        options: [Option],
        titleKeyPath: KeyPath<Option, String>,
        confirmButtonTitle: String = "Choose button",
        selectedOption: Option,
        onConfirm: @escaping (Option) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.options = options
        self.titleKeyPath = titleKeyPath
        self.confirmButtonTitle = confirmButtonTitle
        self.selectedOption = selectedOption
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    public var body: some View {
        ModalContainer(
            icon: icon,
            title: title,
            confirmButtonTitle: confirmButtonTitle,
            onConfirm: {
                onConfirm(selectedOption)
            },
            onCancel: onCancel,
            content: {
                RadioButtonChooserView<Option>(
                    options: options,
                    isSelected: { chosenOption in
                        selectedOption == chosenOption
                    },
                    titleKey: { chosenOption in chosenOption[keyPath: titleKeyPath] },
                    onSelect: { chosenOption in
                        selectedOption = chosenOption
                    },
                    accessibilityLabel: { chosenOption, isSelected in
                        let title = languageSettings.localized(chosenOption[keyPath: titleKeyPath])
                        let selected = isSelected
                        ? languageSettings.localized("Radiobutton selected")
                        : languageSettings.localized("Radiobutton unselected")
                        return "\(title) \(selected)"
                    },
                    trailingSpacer: false
                )
            }
        )
    }
}
