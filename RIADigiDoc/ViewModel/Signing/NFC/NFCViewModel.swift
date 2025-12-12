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

import Foundation
import OSLog
import LibdigidocLibSwift
import CommonsLib

@Observable
@MainActor
class NFCViewModel: NFCViewModelProtocol {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "NFCViewModel")

    var canNumberErrorKey: String?
    var canNumberErrorExtraArguments: [String] = []

    private let dataStore: DataStoreProtocol

    init(
        dataStore: DataStoreProtocol
    ) {
        self.dataStore = dataStore
    }

    func isActionEnabled(canNumber: String) -> Bool {
        checkCANNumberValidity(canNumber: canNumber)
        return (!canNumber.isEmpty && canNumberErrorKey?.isEmpty == true)
    }

    func saveInputData(canNumber: String, rememberMe: Bool) async {
        await dataStore
            .setNFCInputData(
                NFCInputData(
                    canNumber: canNumber,
                    rememberMe: rememberMe
                )
            )
    }

    func getInputData() async -> NFCInputData {
        return await dataStore.getNFCInputData()
    }

    func resetErrors() {
        canNumberErrorKey = nil
        canNumberErrorExtraArguments = []
    }

    func loadPersonalData() {
        // TODO: Implement with My eID
    }

    func sign() async -> SignedContainerProtocol? {
        // TODO: Implement with NFC signing
        return nil
    }

    func isRoleDataEnabled() async -> Bool {
        await dataStore.getIsRoleAndAddressEnabled()
    }

    private func checkCANNumberValidity(canNumber: String) {
        guard canNumber.isEmpty || (
            canNumber.count == Constants.Validation.CANNumberLength &&
            canNumber.allSatisfy { $0.isNumber }
        ) else {
            canNumberErrorKey = "CAN length requirement"
            canNumberErrorExtraArguments = [String(
                Constants.Validation.CANNumberLength
            )]
            return
        }
        canNumberErrorKey = ""
    }
}
