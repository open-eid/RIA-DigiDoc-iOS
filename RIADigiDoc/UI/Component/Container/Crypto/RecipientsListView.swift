// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import CryptoObjCWrapper
import UtilsLib

struct RecipientsListView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let recipients: [Addressee]
    @Binding var selectedRecipient: Addressee?
    var showRemoveRecipientButton: Bool
    @Binding var showRemoveRecipientModal: Bool

    let nameUtil: NameUtilProtocol
    let recipientUtil: RecipientUtilProtocol

    var body: some View {
        LazyVStack {
            if #available(iOS 26.0, *) {
                ForEach(recipients.enumerated(), id: \.offset) { index, recipient in
                    RecipientView(
                        recipientIndex: index + 1,
                        recipient: recipient,
                        nameUtil: nameUtil,
                        recipientUtil: recipientUtil,
                        showRemoveRecipientButton: showRemoveRecipientButton,
                        showRemoveRecipientModal: $showRemoveRecipientModal,
                        onSelect: {
                            selectedRecipient = recipient
                        }
                    )
                }
            } else {
                ForEach(Array(recipients.enumerated()), id: \.offset) { index, recipient in
                    RecipientView(
                        recipientIndex: index + 1,
                        recipient: recipient,
                        isTimestamp: true,
                        nameUtil: nameUtil,
                        recipientUtil: recipientUtil,
                        showRemoveRecipientButton: showRemoveRecipientButton,
                        showRemoveRecipientModal: $showRemoveRecipientModal,
                        onSelect: {
                            selectedRecipient = recipient
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    let recipient = Addressee(
        data: Data(),
        cnVal: "String",
        givenName: "Bob",
        surname: "Grey",
        serialNumber: "38208263812",
        certType: CertType.iDCardType,
        validTo: Date.distantFuture
    )

    RecipientsListView(
        recipients: [recipient],
        selectedRecipient: .constant(recipient),
        showRemoveRecipientButton: true,
        showRemoveRecipientModal: .constant(false),
        nameUtil: Container.shared.nameUtil(),
        recipientUtil: Container.shared.recipientUtil()
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
