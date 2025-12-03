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
