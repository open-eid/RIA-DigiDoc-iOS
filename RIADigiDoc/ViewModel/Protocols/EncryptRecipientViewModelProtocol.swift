// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CryptoObjCWrapper
import CommonsLib

/// @mockable
@MainActor
public protocol EncryptRecipientViewModelProtocol: Sendable {
    func filteredRecipients() -> [Addressee]
    func filteredAddedRecipients() async -> [Addressee]
    func addRecipients(_ chosenRecipient: Addressee) async
    func loadRecipients() async
    func getContainerRecipientList() async -> [Addressee]
    func deleteRecipient(_ recipient: Addressee) async
    func encryptWithPassword(label: String, password: String) async throws
    func resetErrorMessage()
    func resetSuccessMessage()
}
