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

import Foundation
import FactoryKit
import CommonsLib
import CryptoSwift
import CryptoObjCWrapper
import UtilsLib

@Observable
@MainActor
class EncryptRecipientViewModel: EncryptRecipientViewModelProtocol, Loggable {

    var isImporting = false
    var recipients: [Addressee] = []
    var searchText: String = ""
    var errorMessage: String?

    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let openLdap: OpenLdapProtocol

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        openLdap: OpenLdapProtocol
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
        self.openLdap = openLdap
    }

    func filteredRecipients() -> [Addressee] {
        let sortedRecipients = recipients.sorted { $0.identifier > $1.identifier }
        return sortedRecipients
    }

    func filteredAddedRecipients() async -> [Addressee] {
        let sortedRecipients = await getContainerRecipientList().sorted { $0.identifier > $1.identifier }
        return sortedRecipients
    }

    func addRecipients(_ chosenRecipient: Addressee) async {
        let cryptoContainer = sharedContainerViewModel.currentContainer() as? any CryptoContainerProtocol

        guard let cryptoContainer else {
            EncryptRecipientViewModel.logger().error("Cannot load container data. Crypto container is nil.")
            return
        }
        let recipients = await cryptoContainer.getRecipients()

        for recipient in recipients where chosenRecipient.data == recipient.data {
            errorMessage = "Recipient already exists in the container"
            EncryptRecipientViewModel.logger().error("Recipient already exists in the container")
            return
        }

        await cryptoContainer.addRecipients([chosenRecipient])
    }

    func loadRecipients() async {
        if !searchText.isEmpty {
            let result = await openLdap.search(identityCode: searchText)
            if result.tooManyResults {
                recipients = []
                errorMessage = "Too many results"
                EncryptRecipientViewModel.logger().error("Too many results for \(self.searchText)")
            } else if result.addressees.isEmpty {
                recipients = []
                errorMessage = "No recipients found"
                EncryptRecipientViewModel.logger().error("No recipients found for \(self.searchText)")
            } else {
                recipients = result.addressees
            }
        } else {
            recipients = []
        }
    }

    func handleSearchTextChange() {
        recipients = []
    }

    func getContainerRecipientList() async -> [Addressee] {
        let cryptoContainer = sharedContainerViewModel.currentContainer() as? any CryptoContainerProtocol

        guard let cryptoContainer else {
            EncryptRecipientViewModel.logger().error("Cannot load container data. Crypto container is nil.")
            return []
        }

        var recipients: [Addressee] = []
        recipients = await cryptoContainer.getRecipients()

        return recipients
    }

    func deleteRecipient(_ recipient: Addressee) async {
        do {
            let cryptoContainer = sharedContainerViewModel.currentContainer() as? any CryptoContainerProtocol

            guard let cryptoContainer else {
                EncryptRecipientViewModel.logger().error("Cannot load container data. Crypto container is nil.")
                return
            }

            try await cryptoContainer.removeRecipient(recipient)
        } catch {
            errorMessage = "Failed to remove recipient"
            EncryptRecipientViewModel.logger().error("Unable to delete recipient: \(error)")
        }
    }
}
