// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import CryptoObjCWrapper

struct DecryptKeyLabelModalView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    let recipients: [Addressee]
    let onConfirm: (Addressee) -> Void
    let onCancel: () -> Void

    @State private var selectedIndex: Int = 0

    private func accessibilityLabel(keyLabel: String, isSelected: Bool) -> String {
        let state = isSelected
            ? languageSettings.localized("Radiobutton selected")
            : languageSettings.localized("Radiobutton unselected")
        return "\(keyLabel) \(state)"
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(Dimensions.Shadow.LOpacity)
                .ignoresSafeArea()
                .accessibilityHidden(true)
                .allowsHitTesting(true)

            ModalContainer(
                title: languageSettings.localized("Choose key label"),
                confirmButtonTitle: "Choose button",
                onConfirm: {
                    guard recipients.indices.contains(selectedIndex) else { return }
                    onConfirm(recipients[selectedIndex])
                },
                onCancel: onCancel,
                content: {
                    VStack(spacing: Dimensions.Padding.ZeroPadding) {
                        ForEach(Array(recipients.enumerated()), id: \.offset) { index, recipient in
                            RadioButtonRow<Int>(
                                title: recipient.identifier,
                                isSelected: index == selectedIndex,
                                onTap: { selectedIndex = index },
                                accessibilityLabel: accessibilityLabel(
                                    keyLabel: recipient.identifier,
                                    isSelected: index == selectedIndex
                                ),
                                accessibilityInputLabel: recipient.identifier
                            )
                            .accessibilityIdentifier("decryptKeyLabelOption\(index)")
                            Divider()
                        }
                    }
                }
            )
            .accessibilityAddTraits(.isModal)
            .accessibilityElement(children: .contain)
        }
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    DecryptKeyLabelModalView(
        recipients: [
            Addressee(data: Data(), cnVal: "Allkirjastamata lepingud 2026"),
            Addressee(data: Data(), cnVal: "Raamatupidamine")
        ],
        onConfirm: { _ in },
        onCancel: {}
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
