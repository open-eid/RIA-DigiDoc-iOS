// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import LibdigidocLibSwift
import CommonsLib

/// @mockable
@MainActor
public protocol MobileIdViewModelProtocol: Sendable {
    func isSigningEnabled(
        phoneNumber: String,
        personalCode: String,
    ) -> Bool
    func saveInputData(
        phoneNumber: String,
        personalCode: String,
        rememberMe: Bool
    ) async
    func getInputData() async -> MobileIdInputData
    func resetErrors()
    func sign(
        phoneNumber: String,
        personalCode: String,
        roleData: RoleData,
        signedContainer: SignedContainerProtocol
    ) async -> SignedContainerProtocol?
    func isRoleDataEnabled() async -> Bool
}
